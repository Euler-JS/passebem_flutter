import 'package:flutter/material.dart';
import 'package:news_app/Model/tema_model.dart';
import 'package:news_app/pages/quiz_review_page.dart';
import 'package:news_app/pages/quiz_screen.dart';

class QuizResultsPage extends StatelessWidget {
  final TemaModel tema;
  final String tipo;
  final int pontuacao;
  final int totalPerguntas;
  final List<Map<String, dynamic>> respostas;

  const QuizResultsPage({
    super.key,
    required this.tema,
    required this.tipo,
    required this.pontuacao,
    required this.totalPerguntas,
    required this.respostas,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf0f4fd),
      appBar: AppBar(
        backgroundColor: const Color(0xFFffc107),
        title: const Text(
          'Resultados do Teste',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Parabéns!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Na vida, tudo é passageiro, menos o cobrador e o motorista.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Pontuação
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'SUA PONTUAÇÃO',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$pontuacao/$totalPerguntas',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'MOEDAS GANHAS',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: Colors.amber[700],
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          '+2',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Botões
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizReviewPage(
                            tema: tema,
                            tipo: tipo,
                            respostas: respostas,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, color: Colors.black),
                    label: const Text(
                      'Revisar Avaliação',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E640),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Navegar para novo teste
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(
                            tema: tema,
                            tipo: tipo,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Fazer novo Teste',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E640),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Botão Home
              IconButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                icon: const Icon(
                  Icons.home,
                  color: Color(0xFFffc107),
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
