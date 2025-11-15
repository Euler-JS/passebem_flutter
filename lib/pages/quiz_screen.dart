import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:news_app/Model/tema_model.dart';
import 'package:news_app/services/auth_service.dart';
import 'package:news_app/pages/quiz_results_page.dart';

class Questao {
  final String id;
  final String question;
  final List<String> options;
  final String answer;
  final String? imageUrl;

  Questao({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
    this.imageUrl,
  });

  factory Questao.fromJson(Map<String, dynamic> json) {
    final incorrectAlternatives = List<String>.from(json['incorecta_alternativas'] ?? []);
    final correctAlternative = json['alternativa_correta']?.toString() ?? '';
    
    // Combinar e embaralhar alternativas
    final allOptions = [...incorrectAlternatives, correctAlternative];
    allOptions.sort(); // Embaralhar simples
    
    return Questao(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      question: json['questao']?.toString() ?? '',
      options: allOptions,
      answer: correctAlternative,
      imageUrl: 'http://mowosocw4sgwsk84kw4ks40c.62.171.183.132.sslip.io/files/' + (json['imagem']?.toString() ?? ''),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final TemaModel tema;
  final String tipo;

  const QuizScreen({
    super.key,
    required this.tema,
    required this.tipo,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Questao> questoes = [];
  int currentQuestion = 0;
  String? selectedOption;
  bool isLoading = true;
  String? provaId;
  Map<int, String> respostasUsuario = {};
  
  // Temporizador
  int segundosRestantes = 1800; // 30 minutos = 1800 segundos
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _carregarPerguntas();
  }
  
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  
  void _iniciarTemporizador() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (segundosRestantes > 0) {
        setState(() {
          segundosRestantes--;
        });
        
        // Aviso quando faltam 5 minutos
        if (segundosRestantes == 300) {
          _mostrarAvisoTempo('Faltam 5 minutos!', 'Você tem apenas 5 minutos restantes para concluir o teste.');
        }
        
        // Aviso quando falta 1 minuto
        if (segundosRestantes == 60) {
          _mostrarAvisoTempo('Falta 1 minuto!', 'Você tem apenas 1 minuto restante para concluir o teste.');
        }
      } else {
        timer.cancel();
        // Tempo esgotado, finalizar quiz automaticamente
        _mostrarTempoEsgotado();
      }
    });
  }
  
  void _mostrarAvisoTempo(String titulo, String mensagem) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8),
              Text(titulo),
            ],
          ),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
  
  void _mostrarTempoEsgotado() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.timer_off, color: Colors.red),
              SizedBox(width: 8),
              Text('Tempo Esgotado!'),
            ],
          ),
          content: const Text('O tempo para realizar o teste acabou. Suas respostas serão enviadas automaticamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _finalizarQuiz();
              },
              child: const Text('Ver Resultado'),
            ),
          ],
        ),
      );
    }
  }
  
  String _formatarTempo(int segundos) {
    final minutos = segundos ~/ 60;
    final segs = segundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segs.toString().padLeft(2, '0')}';
  }

  Future<void> _carregarPerguntas() async {
    try {
      setState(() {
        isLoading = true;
      });

      final user = await AuthService.getStoredUser();
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/apptemas'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': user.id,
        },
        body: json.encode({
          'item': {
            '_id': widget.tema.id,
            'nome': widget.tema.nome,
          },
          'tipo': widget.tipo,
        }),
      );

      print('Resposta API questões: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        setState(() {
          // Limitar a 25 questões
          questoes = results.take(25).map((q) => Questao.fromJson(q)).toList();
          provaId = data['prova']?['_id']?.toString() ?? data['prova']?['id']?.toString();
          isLoading = false;
        });

        print('Carregadas ${questoes.length} questões');
        
        // Iniciar temporizador
        _iniciarTemporizador();
      } else {
        throw Exception('Erro ao carregar perguntas: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar perguntas: $e');
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erro'),
            content: Text('Não foi possível carregar as perguntas: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Voltar'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _responderQuestao() {
    if (selectedOption == null) return;

    // Salvar resposta do usuário
    setState(() {
      respostasUsuario[currentQuestion] = selectedOption!;
    });

    // Se for a última questão, finalizar
    if (currentQuestion >= questoes.length - 1) {
      _finalizarQuiz();
    } else {
      // Senão, ir para próxima questão
      _proximaQuestao();
    }
  }

  void _proximaQuestao() {
    setState(() {
      currentQuestion++;
      selectedOption = respostasUsuario[currentQuestion];
    });
  }
  
  void _questaoAnterior() {
    if (currentQuestion > 0) {
      setState(() {
        currentQuestion--;
        selectedOption = respostasUsuario[currentQuestion];
      });
    }
  }

  void _finalizarQuiz() {
    // Calcular pontuação e preparar dados para a tela de resultados
    int pontuacaoFinal = 0;
    List<Map<String, dynamic>> respostas = [];
    
    for (int i = 0; i < questoes.length; i++) {
      final questao = questoes[i];
      final respostaUsuario = respostasUsuario[i];
      
      // Contar acertos
      if (respostaUsuario == questao.answer) {
        pontuacaoFinal++;
      }
      
      respostas.add({
        'question': questao.question,
        'image_url': questao.imageUrl,
        'options': questao.options,
        'answer': questao.answer,
        'respostaUsuario': respostaUsuario,
      });
    }
    
    // Navegar para tela de resultados
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultsPage(
          tema: widget.tema,
          tipo: widget.tipo,
          pontuacao: pontuacaoFinal,
          totalPerguntas: questoes.length,
          respostas: respostas,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (questoes.isNotEmpty && currentQuestion < questoes.length) {
          final perguntasRestantes = questoes.length - respostasUsuario.length;
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Terminar teste?'),
              content: Text('Ainda ${perguntasRestantes > 0 ? "tem $perguntasRestantes perguntas não respondidas" : "há perguntas"}. Deseja realmente terminar o teste?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Não'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Sim'),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFf0f4fd),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Color(0xFFDDD)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sair do Quiz?'),
                  content: const Text('Seu progresso será perdido.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Sair',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          title: Column(
            children: [
              Text(
                'Questão ${currentQuestion + 1} de ${questoes.length}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF607d8b),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (currentQuestion + 1) / questoes.length,
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFffc107)),
                  minHeight: 8,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            // Temporizador
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: segundosRestantes < 300 
                    ? Colors.red.withOpacity(0.1) 
                    : const Color(0xFFffc107).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: segundosRestantes < 300 
                      ? Colors.red 
                      : const Color(0xFFffc107),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 18,
                    color: segundosRestantes < 300 
                        ? Colors.red 
                        : const Color(0xFF607d8b),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatarTempo(segundosRestantes),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: segundosRestantes < 300 
                          ? Colors.red 
                          : const Color(0xFF607d8b),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF607d8b),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Carregando perguntas...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              )
            : questoes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 80,
                          color: Color(0xFF757575),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Nenhuma pergunta encontrada',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF757575),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Voltar'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Imagem da questão
                              if (questoes[currentQuestion].imageUrl != null && 
                                  questoes[currentQuestion].imageUrl!.isNotEmpty)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                        child: Image.network(
                                          questoes[currentQuestion].imageUrl!,
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: 200,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          questoes[currentQuestion].question,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF607d8b),
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              
                              const SizedBox(height: 24),
                              
                              // Opções de resposta
                              ...questoes[currentQuestion].options.map((opcao) {
                                final isSelected = selectedOption == opcao;
                                
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedOption = opcao;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFffc107).withOpacity(0.2)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFFffc107)
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            opcao,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF212121),
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFFffc107),
                                            size: 24,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                      
                      // Navegação
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            if (currentQuestion > 0)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _questaoAnterior,
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('Anterior'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF607d8b),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            if (currentQuestion > 0) const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: selectedOption != null ? _responderQuestao : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFffc107),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey[300],
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text(
                                  currentQuestion >= questoes.length - 1
                                      ? 'Finalizar'
                                      : 'Próxima',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
