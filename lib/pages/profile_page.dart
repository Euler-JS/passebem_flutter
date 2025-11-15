// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/subscription_provider.dart';
import '../Model/user_model.dart';
import '../widgets/subscription_status_widget.dart';
import 'login_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthProvider _authProvider = AuthProvider.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshProfile();
    // Listen for changes in AuthProvider
    _authProvider.addListener(_onAuthProviderChanged);
  }

  void _onAuthProviderChanged() {
    if (mounted) {
      setState(() {}); // Rebuild the widget when auth state changes
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthProviderChanged);
    super.dispose();
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _authProvider.refreshUser();
    } catch (e) {
      print('Error refreshing profile: $e');
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFC7A87B)),
            )
          : _authProvider.isLoggedIn
              ? _buildProfileContent()
              : _buildLoginPrompt(),
    );
  }

  Widget _buildProfileContent() {
    final user = _authProvider.user;
    if (user == null) {
      return _buildLoginPrompt();
    }

    return CustomScrollView(
      slivers: [
        // AppBar
        SliverAppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 100,
          elevation: 0,
          automaticallyImplyLeading: false,
          floating: false,
          pinned: false,
          snap: false,
          title: const Text(
            'Meu Perfil',
            style: TextStyle(
              color: Color(0xFF333333),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.edit,
                color: Color(0xFFC7A87B),
              ),
              onPressed: _showEditProfile,
              tooltip: 'Editar perfil',
            ),
          ],
        ),

        // Conteúdo
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildProfileHeader(user),
              _buildProfileInfo(user),
              ChangeNotifierProvider(
                create: (context) => SubscriptionProvider(),
                child: const SubscriptionStatusWidget(),
              ),
              _buildActionButtons(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFC7A87B),
            Color(0xFF8B5E3C),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              size: 50,
              color: Color(0xFFC7A87B),
            ),
          ),

          const SizedBox(height: 16),

          // Nome
          Text(
            _getDisplayName(user),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Username
          Text(
            '@${_getUsername(user)}',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.9),
            ),
          ),

          const SizedBox(height: 16),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatBadge(
                icon: Icons.article,
                label: 'Artigos',
                value: '0',
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatBadge(
                icon: Icons.bookmark,
                label: 'Salvos',
                value: '0',
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatBadge(
                icon: Icons.podcasts,
                label: 'Podcasts',
                value: '0',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC7A87B).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC7A87B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFFC7A87B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Informações Pessoais',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildInfoItem(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email,
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoItem(
            icon: Icons.person_outline,
            label: 'Nome completo',
            value: _getDisplayName(user),
          ),
          
          if (user.mobile != null) ...[
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.phone_outlined,
              label: 'Telefone',
              value: user.mobile!,
            ),
          ],
          
          if (user.address != null && user.address!.fullAddress.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.location_on_outlined,
              label: 'Endereço',
              value: user.address!.fullAddress,
            ),
          ],
          
          const SizedBox(height: 16),
          
          _buildInfoItem(
            icon: Icons.calendar_today_outlined,
            label: 'Membro desde',
            value: _formatDate(user.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFC7A87B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFC7A87B),
            size: 18,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF333333).withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          _buildActionButton(
            icon: Icons.lock_outline,
            label: 'Alterar Senha',
            onTap: _showChangePassword,
          ),
          
          const SizedBox(height: 12),
          
          _buildActionButton(
            icon: Icons.logout,
            label: 'Sair',
            onTap: _showLogoutConfirmation,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDestructive 
              ? Colors.red.withOpacity(0.3) 
              : const Color(0xFFC7A87B).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDestructive 
                        ? Colors.red.withOpacity(0.1) 
                        : const Color(0xFFC7A87B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive ? Colors.red : const Color(0xFFC7A87B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : const Color(0xFF333333),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDestructive 
                      ? Colors.red.withOpacity(0.6) 
                      : const Color(0xFF333333).withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFC7A87B).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFC7A87B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                size: 60,
                color: Color(0xFFC7A87B),
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Faça login para ver seu perfil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Entre na sua conta para acessar seu perfil e personalizar sua experiência.',
              style: TextStyle(
                fontSize: 15,
                color: const Color(0xFF333333).withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC7A87B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Fazer Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    
    return '${date.day} de ${months[date.month - 1]}, ${date.year}';
  }

  String _getDisplayName(UserModel user) {
    // Se tem firstname e lastname, usa eles
    if (user.firstname != null && user.firstname!.isNotEmpty && 
        user.lastname != null && user.lastname!.isNotEmpty) {
      return '${user.firstname} ${user.lastname}';
    }
    
    // Se tem apenas firstname, usa ele
    if (user.firstname != null && user.firstname!.isNotEmpty) {
      return user.firstname!;
    }
    
    // Se não tem nome, usa username
    if (user.username?.isNotEmpty ?? false) {
      return user.username ?? '';
    }
    
    // Se não tem nada, usa email sem @
    return user.email?.split('@')[0] ?? '';
  }

  String _getUsername(UserModel user) {
    if (user.username?.isNotEmpty ?? false) {
      return user.username ?? '';
    }
    
    // Se não tem username, usa a parte antes do @ do email
    return user.email?.split('@')[0] ?? '';
  }

  void _showEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfilePage(),
      ),
    );
    
    // Se voltou da edição, atualizar o perfil
    if (result == true || result == null) {
      await _refreshProfile();
    }
  }

  void _showChangePassword() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.lock_outline,
                    color: Color(0xFFC7A87B),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Alterar Senha',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: currentPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Senha atual',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFC7A87B),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite sua senha atual';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Nova senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFC7A87B),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite a nova senha';
                        }
                        if (value.length < 8) {
                          return 'A senha deve ter pelo menos 8 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirmar nova senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFC7A87B),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirme a nova senha';
                        }
                        if (value != newPasswordController.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: const Color(0xFF333333).withOpacity(0.6),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });

                      final success = await _authProvider.changePassword(
                        currentPassword: currentPasswordController.text,
                        newPassword: newPasswordController.text,
                        newPasswordConfirmation: confirmPasswordController.text,
                      );

                      setState(() {
                        isLoading = false;
                      });

                      Navigator.pop(context);

                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success 
                              ? 'Senha alterada com sucesso!' 
                              : _authProvider.errorMessage ?? 'Erro ao alterar senha'
                          ),
                          backgroundColor: success ? const Color(0xFFC7A87B) : Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC7A87B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Alterar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.logout,
                color: Colors.red,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Sair da conta',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          content: Text(
            'Tem certeza que deseja sair da sua conta?',
            style: TextStyle(
              color: const Color(0xFF333333).withOpacity(0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: const Color(0xFF333333).withOpacity(0.6),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                
                await _authProvider.logout();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Você saiu da sua conta'),
                      backgroundColor: const Color(0xFFC7A87B),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  
                  setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }
}