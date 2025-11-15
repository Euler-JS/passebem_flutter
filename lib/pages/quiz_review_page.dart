import 'package:flutter/material.dart';
import 'package:news_app/Model/tema_model.dart';

class QuizReviewPage extends StatefulWidget {
  final TemaModel tema;
  final String tipo;
  final List<Map<String, dynamic>> respostas;

  const QuizReviewPage({
    super.key,
    required this.tema,
    required this.tipo,
    required this.respostas,
  });

  @override
  State<QuizReviewPage> createState() => _QuizReviewPageState();
}

class _QuizReviewPageState extends State<QuizReviewPage> {
  int currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final questao = widget.respostas[currentIndex];
    final respostaUsuario = questao['respostaUsuario'] as String?;
    final respostaCorreta = questao['answer'] as String;
    final acertou = respostaUsuario == respostaCorreta;
    
    return Scaffold(
      backgroundColor: const Color(0xFFf0f4fd),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFFDDD)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Revisão - Questão ${currentIndex + 1} de ${widget.respostas.length}',
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
                value: (currentIndex + 1) / widget.respostas.length,
                backgroundColor: const Color(0xFFE0E0E0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFffc107)),
                minHeight: 8,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.flag, color: Color(0xFFDDD)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Imagem da questão
                  if (questao['image_url'] != null && questao['image_url'] != '')
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
                              questao['image_url'],
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
                              questao['question'],
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
                  ...List.generate(
                    (questao['options'] as List<dynamic>).length,
                    (index) {
                      final opcao = (questao['options'] as List<dynamic>)[index] as String;
                      final isRespostaUsuario = opcao == respostaUsuario;
                      final isRespostaCorreta = opcao == respostaCorreta;
                      
                      Color backgroundColor;
                      Color borderColor;
                      Widget? trailingIcon;
                      
                      if (isRespostaUsuario && acertou) {
                        // Resposta do usuário e está correta
                        backgroundColor = const Color(0xFF00E640).withOpacity(0.2);
                        borderColor = const Color(0xFF00E640);
                        trailingIcon = const Icon(
                          Icons.check,
                          color: Color(0xFF00E640),
                          size: 24,
                        );
                      } else if (isRespostaUsuario && !acertou) {
                        // Resposta do usuário e está errada
                        backgroundColor = const Color(0xFFCF000F).withOpacity(0.1);
                        borderColor = const Color(0xFFCF000F);
                        trailingIcon = null;
                      } else if (isRespostaCorreta) {
                        // Resposta correta (quando usuário errou)
                        backgroundColor = Colors.white;
                        borderColor = Colors.transparent;
                        trailingIcon = const Icon(
                          Icons.check,
                          color: Color(0xFF00E640),
                          size: 24,
                        );
                      } else {
                        // Outras opções
                        backgroundColor = Colors.white;
                        borderColor = Colors.transparent;
                        trailingIcon = null;
                      }
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: borderColor,
                            width: borderColor == Colors.transparent ? 0 : 2,
                          ),
                          boxShadow: borderColor == Colors.transparent
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: ListTile(
                          title: Text(
                            opcao,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF212121),
                            ),
                          ),
                          trailing: trailingIcon,
                        ),
                      );
                    },
                  ),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: currentIndex > 0
                      ? () {
                          setState(() {
                            currentIndex--;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Anterior'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF607d8b),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                ),
                Text(
                  '${currentIndex + 1}/${widget.respostas.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF607d8b),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: currentIndex < widget.respostas.length - 1
                      ? () {
                          setState(() {
                            currentIndex++;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Próxima'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF607d8b),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
