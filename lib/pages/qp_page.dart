import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class QpPage extends StatelessWidget {
  const QpPage({Key? key}) : super(key: key);

  Future<void> _sendMail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'delciopluis@gmail.com',
      query: 'subject=Usuário do aplicativo Passe-Bem questiona:',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      print('Não foi possível abrir o cliente de email');
    }
  }

  void _navigateToCategory(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QpCategoriaPage(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: height * 0.07,
                width: width,
                color: const Color(0xFF607D8B),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 10),
                child: const Text(
                  'Perguntas Frequentes',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: height * 0.04),
              const Text(
                'Como podemos ajudar você ?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              SizedBox(height: height * 0.03),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCategoryCard(
                      context,
                      'Sinais',
                      'assets/image/traffic.png',
                      width,
                      height,
                    ),
                    _buildCategoryCard(
                      context,
                      'Carreira',
                      'assets/image/driver.png',
                      width,
                      height,
                    ),
                    _buildCategoryCard(
                      context,
                      'Manuais',
                      'assets/image/stop.png',
                      width,
                      height,
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.03),
              GestureDetector(
                onTap: _sendMail,
                child: Container(
                  width: width * 0.9,
                  height: height * 0.07,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECB3),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '+ Submeta sua questão',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF757575),
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.04),
              Container(
                width: width * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.02, bottom: height * 0.025),
                      child: const Text(
                        'Top Questões',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE9E9EB)),
                      ),
                      child: ListTile(
                        title: const Text(
                          'A visão em túnel manifesta-se de que modo?',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF212121),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFFFFA000),
                          size: 20,
                        ),
                        onTap: () {
                          // Navegar para tela de resposta
                          print('Navegando para resposta');
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    String imagePath,
    double width,
    double height,
  ) {
    return GestureDetector(
      onTap: () => _navigateToCategory(context, title),
      child: Container(
        height: height * 0.15,
        width: width * 0.28,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 60,
              height: 60,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.help_outline,
                  size: 60,
                  color: Colors.grey,
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Página de Categoria de Perguntas
class QpCategoriaPage extends StatelessWidget {
  final String category;

  const QpCategoriaPage({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF607D8B),
        title: Text(
          category,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perguntas sobre $category',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildQuestionCard(
                    'O que são sinais de trânsito?',
                    'Sinais de trânsito são placas, semáforos e marcações viárias que...',
                  ),
                  _buildQuestionCard(
                    'Como identificar sinais de perigo?',
                    'Os sinais de perigo são geralmente triangulares e...',
                  ),
                  _buildQuestionCard(
                    'Qual a importância dos sinais?',
                    'Os sinais de trânsito são essenciais para...',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
