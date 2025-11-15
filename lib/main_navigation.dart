import 'package:flutter/material.dart';
import 'package:news_app/news_home_page.dart';
import 'package:news_app/pages/chat_page.dart';
import 'package:news_app/pages/curso_page.dart';
import 'package:news_app/pages/qp_page.dart';
import 'package:news_app/pages/perfil_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const NewsHomePage(),
    const ChatPage(),
    const CursoPage(),
    const QpPage(),
    const PerfilPage(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.flag_outlined,
      activeIcon: Icons.flag,
      label: 'Partida',
    ),
    NavigationItem(
      icon: Icons.forum_outlined,
      activeIcon: Icons.forum,
      label: 'Chat',
    ),
    NavigationItem(
      icon: Icons.tv,
      activeIcon: Icons.tv,
      label: 'Aulas',
    ),
    NavigationItem(
      icon: Icons.help_outline,
      activeIcon: Icons.help,
      label: 'P&F',
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Perfil',
    ),
  ];

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: IndexedStack(
      index: _currentIndex,
      children: _pages,
    ),
    bottomNavigationBar: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8), // Reduzido de 8 para 4
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Mudado para spaceEvenly
            children: _navigationItems.asMap().entries.map((entry) {
              int index = entry.key;
              NavigationItem item = entry.value;
              bool isActive = index == _currentIndex;

              return Expanded( // Adicionado Expanded para distribuir igualmente
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4, // Reduzido de 12 para 4
                      vertical: 6,   // Reduzido de 8 para 6
                    ),
                    decoration: BoxDecoration(
                      color: isActive 
                          ? const Color(0xFFFFA000).withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8), // Reduzido de 12 para 8
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? item.activeIcon : item.icon,
                          color: isActive 
                              ? const Color(0xFFFFA000)
                              : const Color(0xFFDDDDDD),
                          size: 22, // Reduzido de 24 para 22
                        ),
                        const SizedBox(height: 2), // Reduzido de 4 para 2
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 9, // Reduzido de 11 para 9
                            fontWeight: isActive 
                                ? FontWeight.w600 
                                : FontWeight.normal,
                            color: isActive 
                                ? const Color(0xFFFFA000)
                                : const Color(0xFFDDDDDD),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    ),
  );
}
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}