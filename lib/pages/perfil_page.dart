import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/auth_service.dart';
import '../Model/user_model.dart';
import 'perfil_sub_pages.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({Key? key}) : super(key: key);

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  UserModel? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final storedUser = await AuthService.getStoredUser();
      setState(() {
        user = storedUser;
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _onShare() async {
    try {
      await Share.share(
        'Já está disponível a nova versão da "Passe Bem", encontre:\n'
        '* Apontamentos para leitura antes e depois de realizar os testes temáticos;\n'
        '* Acesso a video aulas online, de código de estrada (condições já criadas para arranque em datas a anunciar);\n'
        '* Partilha de vídeos do primeiro carro/primeira condução com habilitação para conduzir;\n'
        '* Acompanhamento através de gráficos do domínio dos temas e dos testes em geral;\n'
        '* Actualização da transitabilidade das vias em tempo real através de um mural;\n'
        'https://play.google.com/store/apps/details?id=mz.co.passebem.passebem2',
      );
    } catch (e) {
      print('Erro ao compartilhar: $e');
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('Deseja realmente sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        // Navegar para tela de login
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF0F4FD),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: height * 0.04),
              // Perfil Header
              Container(
                width: width * 0.9,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: width * 0.13,
                      backgroundImage: NetworkImage(
                        user?.profileImageUrl ?? 
                        'https://oolhar.com.br/wp-content/uploads/2020/09/perfil-candidatos.jpg',
                      ),
                      onBackgroundImageError: (exception, stackTrace) {
                        print('Erro ao carregar imagem de perfil');
                      },
                    ),
                    SizedBox(height: height * 0.01),
                    Text(
                      user?.fullName ?? 'Usuário',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                    Text(
                      user?.displayEmail ?? 'example@gmail.com',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: height * 0.014),
                    // Botão PRO (desabilitado)
                    Container(
                      width: width * 0.45,
                      height: height * 0.04,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Upgrade to PRO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.03),
              // Menu Options
              Container(
                width: width * 0.9,
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.shield,
                      label: 'Privacidade',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditPerfilPage(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: height * 0.01),
                    _buildMenuItem(
                      icon: Icons.file_copy,
                      label: 'Material Didáctico',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CategoriaDidaticaPage(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: height * 0.01),
                    _buildMenuItem(
                      icon: Icons.history,
                      label: 'Histórico Académico',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoricoAcademicoPage(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: height * 0.01),
                    _buildMenuItem(
                      icon: Icons.history,
                      label: 'Histórico de Compras',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoricoComprasPage(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: height * 0.01),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      label: 'Ajuda e Suporte',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupportPage(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: height * 0.01),
                    _buildMenuItem(
                      icon: Icons.settings,
                      label: 'Definições',
                      onTap: null, // Desabilitado
                      isDisabled: true,
                    ),
                    SizedBox(height: height * 0.01),
                    _buildMenuItem(
                      icon: Icons.person_add_alt_1,
                      label: 'Convidar um amigo',
                      onTap: _onShare,
                    ),
                    SizedBox(height: height * 0.02),
                    // Botão de Logout
                    GestureDetector(
                      onTap: _handleLogout,
                      child: Container(
                        width: width * 0.3,
                        height: height * 0.058,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.logout,
                              color: Color(0xFF607D8B),
                              size: 30,
                            ),
                            SizedBox(width: width * 0.02),
                            const Text(
                              'Sair',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF607D8B),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: width * 0.9,
        height: height * 0.058,
        padding: EdgeInsets.symmetric(horizontal: width * 0.03),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[300] : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF607D8B),
                  size: 24,
                ),
                SizedBox(width: width * 0.07),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF607D8B),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.keyboard_arrow_right,
              color: Color(0xFF607D8B),
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
