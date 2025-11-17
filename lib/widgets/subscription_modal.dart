import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubscriptionModal extends StatelessWidget {
  final Function(String pacote) onComprarPacote;
  
  const SubscriptionModal({
    Key? key,
    required this.onComprarPacote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_MZ',
      symbol: 'MTn',
      decimalDigits: 2,
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header com logo e título
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Logo M-pesa
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'M',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Loja Passe Bem',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                        Text(
                          'm-pesa',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF607d8b),
                    size: 30,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          
          // Pacotes
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Pacote Diário
                  _buildPackageCard(
                    context: context,
                    image: 'assets/image/manual.png',
                    title: 'Pacote Diário',
                    description: 'O pacote diário permite manter-te conectado com todas modalidades de avaliação durante um dia.\nPagamento: Mpesa',
                    price: 28.00,
                    currencyFormatter: currencyFormatter,
                    onPressed: () => onComprarPacote('Diario'),
                    size: size,
                  ),
                  
                  // Pacote Semanal
                  _buildPackageCard(
                    context: context,
                    image: 'assets/image/eletric.png',
                    title: 'Pacote Semanal',
                    description: 'O pacote semanal permite manter-te conectado com todas modalidades de avaliação durante uma semana.\nPagamento: Mpesa',
                    price: 70.00,
                    currencyFormatter: currencyFormatter,
                    onPressed: () => onComprarPacote('Semanal'),
                    size: size,
                  ),
                  
                  // Pacote Mensal
                  _buildPackageCard(
                    context: context,
                    image: 'assets/image/carwife.png',
                    title: 'Pacote Mensal',
                    description: 'O pacote mensal permite manter-te conectado com todas modalidades de avaliação durante um mês.\nPagamento: Mpesa',
                    price: 215.00,
                    currencyFormatter: currencyFormatter,
                    onPressed: () => onComprarPacote('Mensal'),
                    size: size,
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard({
    required BuildContext context,
    required String image,
    required String title,
    required String description,
    required double price,
    required NumberFormat currencyFormatter,
    required VoidCallback onPressed,
    required Size size,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFf0f4fd), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem do pacote
          Image.asset(
            image,
            height: size.height * 0.14,
            width: size.height * 0.14,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: size.height * 0.14,
                width: size.height * 0.14,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.image_not_supported,
                  size: 40,
                  color: Colors.grey,
                ),
              );
            },
          ),
          
          const SizedBox(width: 15),
          
          // Conteúdo do pacote
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF9999a6),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Botão Abastecer
                SizedBox(
                  width: double.infinity,
                  height: size.height * 0.045,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF607d8b),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Abastecer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.album,
                          color: Color(0xFFffc107),
                          size: 24,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          currencyFormatter.format(price),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
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
