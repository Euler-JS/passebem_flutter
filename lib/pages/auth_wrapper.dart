// lib/pages/auth_wrapper.dart
import 'package:flutter/material.dart';
import '../services/auth_provider.dart';
import '../main_navigation.dart';
import 'onboarding_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthProvider _authProvider = AuthProvider.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Dar um tempo para o AuthProvider inicializar
    await Future.delayed(const Duration(milliseconds: 1500));
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFC7A87B),
          ),
        ),
      );
    }

    // Se estiver logado, vai para a navegação principal
    // Se não estiver logado, vai para o onboarding
    return _authProvider.isLoggedIn 
        ? const MainNavigationPage()
        : const OnboardingPage();
  }
}
