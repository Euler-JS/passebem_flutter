import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import '../main_navigation.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late PageController _pageController;
  int currentPage = 0;

  final List<OnboardingItem> onboardingItems = [
    OnboardingItem(
      title: "Bem-vindo ao\nPasse Bem",
      subtitle: "Prepare-se para o exame de condução com questões atualizadas, simulados e conteúdo didático completo.",
      iconData: Icons.directions_car,
      gradientColors: [const Color(0xFFffc107), const Color(0xFFffa000)],
    ),
    OnboardingItem(
      title: "Testes e\nSimulados",
      subtitle: "Pratique com milhares de questões organizadas por tema e faça simulados completos para testar seus conhecimentos.",
      iconData: Icons.quiz,
      gradientColors: [const Color(0xFFffa000), const Color(0xFFff8f00)],
    ),
    OnboardingItem(
      title: "Conteúdo\nDidático",
      subtitle: "Acesse vídeo-aulas, materiais de apoio e acompanhe seu progresso para garantir sua aprovação.",
      iconData: Icons.school,
      gradientColors: [const Color(0xFFff8f00), const Color(0xFFf57c00)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: onboardingItems[currentPage].gradientColors,
          ),
        ),
        child: Stack(
          children: [
            // Formas geométricas de fundo
            _buildBackgroundShapes(),
            
            // Conteúdo principal
            SafeArea(
              child: Column(
                children: [
                  // Skip button
                  Padding(
                    padding: const EdgeInsets.only(top: 20, right: 20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => _navigateToLogin(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Pular',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },
                      itemCount: onboardingItems.length,
                      itemBuilder: (context, index) {
                        return buildOnboardingPage(onboardingItems[index]);
                      },
                    ),
                  ),

                  // Bottom section
                  Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        // Page indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            onboardingItems.length,
                            (index) => buildDot(index),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Buttons row
                        Row(
                          children: [
                            // Sign in button
                            Expanded(
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: () => _navigateToLogin(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Sign up button
                            Expanded(
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (currentPage < onboardingItems.length - 1) {
                                      _pageController.nextPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    } else {
                                      _navigateToSignUp();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    currentPage < onboardingItems.length - 1 
                                        ? 'Continuar' 
                                        : 'Começar',
                                    style: TextStyle(
                                      color: onboardingItems[currentPage].gradientColors[0],
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Botão "Continuar sem login" (modo guest)
                        GestureDetector(
                          onTap: () => _navigateToAppAsGuest(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Continuar sem login',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white.withOpacity(0.9),
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
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundShapes() {
    return Stack(
      children: [
        // Círculo grande superior esquerdo
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        
        // Círculo médio superior direito
        Positioned(
          top: 100,
          right: -50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
        
        // Círculo pequeno centro esquerdo
        Positioned(
          top: 300,
          left: 30,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        
        // Círculo grande inferior direito
        Positioned(
          bottom: -150,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        
        // Forma fluida adicional
        Positioned(
          bottom: 200,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Colors.white.withOpacity(0.04),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildOnboardingPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(70),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  item.iconData,
                  size: 50,
                  color: item.gradientColors[0],
                ),
              ),
            ),
          ),

          const SizedBox(height: 60),

          // Title
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Subtitle
          Text(
            item.subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: currentPage == index ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: currentPage == index 
            ? Colors.white 
            : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  void _navigateToSignUp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(), // Pode alterar para SignUpPage se preferir
      ),
    );
  }
  
  void _navigateToAppAsGuest() async {
    // Marcar que viu o onboarding
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    
    // Ir direto para o app sem login
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigationPage(),
        ),
      );
    }
  }
}

class OnboardingItem {
  final String title;
  final String subtitle;
  final IconData iconData;
  final List<Color> gradientColors;

  OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.gradientColors,
  });
}