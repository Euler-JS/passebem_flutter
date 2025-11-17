import 'package:flutter/material.dart';
import 'dart:async';

class AdvertisementSlider extends StatefulWidget {
  final List<Map<String, dynamic>>? publicidades;
  
  const AdvertisementSlider({
    super.key,
    this.publicidades,
  });

  @override
  State<AdvertisementSlider> createState() => _AdvertisementSliderState();
}

class _AdvertisementSliderState extends State<AdvertisementSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // Lista de imagens PADRÃO de publicidade (mesmas do React Native)
  final List<Map<String, String>> _defaultAdvertisements = [
    {
      'id': '1',
      'imagem': 'https://image.freepik.com/fotos-gratis/mulher-alegre-e-satisfeita-com-cabelo-encaracolado-segura-o-celular-e-envia-mensagens-de-texto-com-amigos-nas-redes-sociais-usa-um-aplicativo-especial-assiste-a-um-video-interessante-isolado-na-parede-azul-pessoas-e-tecnologia_273609-39465.jpg',
    },
    {
      'id': '2',
      'imagem': 'https://image.freepik.com/fotos-gratis/mulher-jovem-de-pele-escura-positiva-e-homem-batem-os-punhos-concordam-em-ser-uma-equipe-olham-felizes-um-para-o-outro-comemora-a-tarefa-concluida-usa-roupas-rosa-e-verdes-posa-em-ambientes-fechados-tem-um-negocio-bem-sucedido_273609-42756.jpg',
    },
    {
      'id': '3',
      'imagem': 'https://image.freepik.com/vetores-gratis/modelo-de-folheto-plano-de-vacinacao-com-coronavirus_23-2148918696.jpg',
    },
    {
      'id': '4',
      'imagem': 'https://image.freepik.com/fotos-gratis/sumo-delicioso-feito-de-laranjas_23-2148256169.jpg',
    },
  ];
  
  List<Map<String, dynamic>> get _advertisements {
    // Usa publicidades da API se disponível, senão usa as padrão
    return widget.publicidades ?? _defaultAdvertisements;
  }

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < _advertisements.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      height: 200,
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
      child: Stack(
        children: [
          // PageView com publicidades
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _advertisements.length,
            itemBuilder: (context, index) {
              final ad = _advertisements[index];
              return _buildAdvertisementCard(ad);
            },
          ),

          // Indicadores de página
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _advertisements.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvertisementCard(Map<String, dynamic> ad) {
    // Pega a URL da imagem (campo 'imagem' da API ou 'image' local)
    final imageUrl = ad['imagem'] as String?;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagem de fundo (da URL)
            if (imageUrl != null && imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: const Color(0xFF4A90E2),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF4A90E2),
                          Color(0xFF357ABD),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 64,
                        color: Colors.white54,
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4A90E2),
                      Color(0xFF357ABD),
                    ],
                  ),
                ),
              ),

            // Gradiente overlay suave
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
