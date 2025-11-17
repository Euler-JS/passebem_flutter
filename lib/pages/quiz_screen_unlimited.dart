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
    allOptions.shuffle();
    
    return Questao(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      question: json['questao']?.toString() ?? '',
      options: allOptions,
      answer: correctAlternative,
      imageUrl: json['imagem'] != null 
          ? 'http://mowosocw4sgwsk84kw4ks40c.62.171.183.132.sslip.io/files/${json['imagem']}'
          : null,
    );
  }
}

class QuizScreenUnlimited extends StatefulWidget {
  final TemaModel tema;
  final String tipo;

  const QuizScreenUnlimited({
    super.key,
    required this.tema,
    required this.tipo,
  });

  @override
  State<QuizScreenUnlimited> createState() => _QuizScreenUnlimitedState();
}

class _QuizScreenUnlimitedState extends State<QuizScreenUnlimited> {
  List<Questao> questoes = [];
  int currentQuestion = 0;
  String? selectedOption;
  bool isLoading = true;
  String? provaId;
  Map<int, String> respostasUsuario = {};
  
  // Temporizador - limite de 1 hora (3600 segundos)
  int segundosRestantes = 3600; // 1 hora = 3600 segundos
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
        
        // Aviso quando faltam 15 minutos
        if (segundosRestantes == 900) {
          _mostrarAvisoTempo('Faltam 15 minutos!', 'Você tem apenas 15 minutos restantes para concluir o teste.');
        }
        
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
          // CARREGAR TODAS AS QUESTÕES - SEM LIMITE
          questoes = results.map((q) => Questao.fromJson(q)).toList();
          provaId = data['prova']?['_id']?.toString() ?? data['prova']?['id']?.toString();
          isLoading = false;
        });

        print('Carregadas ${questoes.length} questões (SEM LIMITE)');
        
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
      if (currentQuestion < questoes.length - 1) {
        currentQuestion++;
        selectedOption = respostasUsuario[currentQuestion];
      }
    });
  }

  void _questaoAnterior() {
    setState(() {
      if (currentQuestion > 0) {
        currentQuestion--;
        selectedOption = respostasUsuario[currentQuestion];
      }
    });
  }
  
  Future<String?> _mostrarDialogoSair() async {
    final totalRespondidas = respostasUsuario.length;
    final totalQuestoes = questoes.length;
    final percentualCompleto = ((totalRespondidas / totalQuestoes) * 100).toStringAsFixed(0);
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.exit_to_app, color: Color(0xFF607d8b)),
            const SizedBox(width: 8),
            const Text('Sair do Teste?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Você respondeu $totalRespondidas de $totalQuestoes questões ($percentualCompleto% completo).',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'O que deseja fazer?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Continuar Teste'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'sair'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sair sem Salvar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'finalizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF607d8b),
            ),
            child: const Text(
              'Finalizar e Ver Resultado',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }

  Future<void> _finalizarQuiz() async {
    timer?.cancel();

    // Calcular pontuação e preparar dados APENAS DAS QUESTÕES RESPONDIDAS
    int pontuacaoFinal = 0;
    List<Map<String, dynamic>> respostas = [];
    
    // IMPORTANTE: Iterar apenas sobre as questões que o usuário RESPONDEU
    // Se parou na pergunta 100, mostra revisão apenas até a 100
    respostasUsuario.forEach((index, respostaUsuario) {
      final questao = questoes[index];
      
      // Contar acertos
      if (respostaUsuario == questao.answer) {
        pontuacaoFinal++;
      }
      
      // Adicionar dados da questão respondida
      respostas.add({
        'question': questao.question,
        'image_url': questao.imageUrl,
        'options': questao.options,
        'answer': questao.answer,
        'respostaUsuario': respostaUsuario,
      });
    });

    // Total de perguntas = quantas foram RESPONDIDAS, não o total disponível
    final totalRespondidas = respostas.length;

    // Navegar para tela de resultados (MESMO FORMATO DO QUIZ NORMAL)
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultsPage(
            tema: widget.tema,
            tipo: widget.tipo,
            pontuacao: pontuacaoFinal,
            totalPerguntas: totalRespondidas, // Apenas as respondidas
            respostas: respostas,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F4FD),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF607d8b),
              ),
              const SizedBox(height: 20),
              Text(
                'Carregando questões...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (questoes.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F4FD),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFC107),
          title: const Text('Quiz'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              const Text(
                'Nenhuma questão disponível',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

    final questao = questoes[currentQuestion];

    return WillPopScope(
      onWillPop: () async {
        final result = await _mostrarDialogoSair();
        if (result == 'finalizar') {
          _finalizarQuiz();
          return false;
        } else if (result == 'sair') {
          return true;
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4FD),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFC107),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () async {
              final result = await _mostrarDialogoSair();
              if (result == 'finalizar') {
                _finalizarQuiz();
              } else if (result == 'sair') {
                Navigator.pop(context);
              }
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.tema.nome,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              Text(
                'Questão ${currentQuestion + 1} de ${questoes.length}',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
          actions: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: segundosRestantes <= 300 ? Colors.red : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: segundosRestantes <= 300 ? Colors.white : const Color(0xFF607d8b),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatarTempo(segundosRestantes),
                      style: TextStyle(
                        color: segundosRestantes <= 300 ? Colors.white : const Color(0xFF607d8b),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Barra de progresso
            LinearProgressIndicator(
              value: (currentQuestion + 1) / questoes.length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF607d8b)),
              minHeight: 6,
            ),
            
            // Indicador de respostas
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${respostasUsuario.length} respondidas',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.hourglass_empty,
                    size: 16,
                    color: Colors.orange[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${questoes.length - respostasUsuario.length} restantes',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagem da questão (se existir)
                    if (questao.imageUrl != null && questao.imageUrl!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            questao.imageUrl!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.image_not_supported, size: 48),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    
                    // Questão
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        questao.question,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                          height: 1.5,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Opções
                    ...questao.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final isSelected = selectedOption == option;
                      final optionLetter = String.fromCharCode(65 + index); // A, B, C, D
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = option;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF607d8b).withOpacity(0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF607d8b) : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: const Color(0xFF607d8b).withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF607d8b) : Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    optionLetter,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isSelected ? const Color(0xFF607d8b) : const Color(0xFF212121),
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
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
            
            // Botões de navegação
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botão Finalizar Teste (sempre visível)
                  if (respostasUsuario.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final confirmar = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Finalizar Teste?'),
                              content: Text(
                                'Você respondeu ${respostasUsuario.length} de ${questoes.length} questões.\n\n'
                                'Deseja finalizar o teste e ver os resultados?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF607d8b),
                                  ),
                                  child: const Text(
                                    'Finalizar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirmar == true) {
                            _finalizarQuiz();
                          }
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(
                          'Finalizar Teste (${respostasUsuario.length}/${questoes.length})',
                          style: const TextStyle(fontSize: 14),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF607d8b),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFF607d8b)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  
                  // Botões de navegação
                  Row(
                    children: [
                      if (currentQuestion > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _questaoAnterior,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFF607d8b)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Anterior',
                              style: TextStyle(
                                color: Color(0xFF607d8b),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      
                      if (currentQuestion > 0) const SizedBox(width: 12),
                      
                      Expanded(
                        flex: currentQuestion > 0 ? 1 : 1,
                        child: ElevatedButton(
                          onPressed: selectedOption != null ? _responderQuestao : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF607d8b),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: Colors.grey[300],
                          ),
                          child: Text(
                            currentQuestion >= questoes.length - 1 ? 'Última Questão' : 'Próxima',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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
