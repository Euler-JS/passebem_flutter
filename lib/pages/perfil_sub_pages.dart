import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../Model/user_model.dart';

class EditPerfilPage extends StatefulWidget {
  const EditPerfilPage({Key? key}) : super(key: key);

  @override
  State<EditPerfilPage> createState() => _EditPerfilPageState();
}

class _EditPerfilPageState extends State<EditPerfilPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  bool isLoading = true;
  UserModel? user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final storedUser = await AuthService.getStoredUser();
      if (storedUser != null) {
        setState(() {
          user = storedUser;
          _nomeController.text = storedUser.fullName;
          _emailController.text = storedUser.displayEmail;
          _telefoneController.text = storedUser.mobile ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF607D8B),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(
                        user?.profileImageUrl ??
                            'https://oolhar.com.br/wp-content/uploads/2020/09/perfil-candidatos.jpg',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () {
                        // Implementar mudança de foto
                        print('Mudar foto de perfil');
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Mudar Foto'),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Implementar atualização do perfil
                            print('Salvar alterações');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funcionalidade em desenvolvimento'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA000),
                        ),
                        child: const Text(
                          'Salvar Alterações',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// Página de Material Didático
class CategoriaDidaticaPage extends StatelessWidget {
  const CategoriaDidaticaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categorias = [
      {'nome': 'A1', 'numero': 2},
      {'nome': 'B', 'numero': 2},
      {'nome': 'C1', 'numero': 2},
      {'nome': 'C', 'numero': 2},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF607D8B),
        title: const Text(
          'Material Didáctico',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          return Card(
            elevation: 3,
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Categoria ${categoria['nome']} selecionada'),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.book,
                    size: 60,
                    color: Color(0xFF607D8B),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Categoria ${categoria['nome']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${categoria['numero']} materiais',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Página de Histórico Acadêmico
class HistoricoAcademicoPage extends StatelessWidget {
  const HistoricoAcademicoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF607D8B),
        title: const Text(
          'Histórico Académico',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history_edu,
              size: 100,
              color: Color(0xFF607D8B),
            ),
            const SizedBox(height: 20),
            const Text(
              'Histórico Académico',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Aqui você verá o histórico de todas as suas provas e testes realizados.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Página de Histórico de Compras
class HistoricoComprasPage extends StatelessWidget {
  const HistoricoComprasPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF607D8B),
        title: const Text(
          'Histórico de Compras',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag,
              size: 100,
              color: Color(0xFF607D8B),
            ),
            const SizedBox(height: 20),
            const Text(
              'Histórico de Compras',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Aqui você verá o histórico de todas as suas compras e transações.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Página de Suporte
class SupportPage extends StatelessWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF607D8B),
        title: const Text(
          'Ajuda e Suporte',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Como podemos ajudar?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildSupportCard(
            context,
            icon: Icons.email,
            title: 'Email',
            subtitle: 'suporte@passebem.mz',
            onTap: () {
              print('Abrir email');
            },
          ),
          _buildSupportCard(
            context,
            icon: Icons.phone,
            title: 'Telefone',
            subtitle: '+258 84 000 0000',
            onTap: () {
              print('Ligar');
            },
          ),
          _buildSupportCard(
            context,
            icon: Icons.help_outline,
            title: 'FAQ',
            subtitle: 'Perguntas Frequentes',
            onTap: () {
              print('Abrir FAQ');
            },
          ),
          _buildSupportCard(
            context,
            icon: Icons.message,
            title: 'Chat',
            subtitle: 'Fale conosco',
            onTap: () {
              print('Abrir chat');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF607D8B),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
