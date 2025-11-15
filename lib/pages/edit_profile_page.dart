// lib/pages/edit_profile_page.dart
import 'package:flutter/material.dart';
import '../services/auth_provider.dart';
import '../Model/user_model.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final AuthProvider _authProvider = AuthProvider.instance;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers para dados pessoais
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  
  // Controllers para endereço
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Listen for changes in AuthProvider
    _authProvider.addListener(_onAuthProviderChanged);
  }

  void _onAuthProviderChanged() {
    if (mounted) {
      // Recarregar dados se o usuário mudou
      _loadUserData();
    }
  }

  void _loadUserData() {
    final user = _authProvider.user;
    if (user != null) {
      _firstnameController.text = user.firstname ?? '';
      _lastnameController.text = user.lastname ?? '';
      _mobileController.text = user.mobile ?? '';
      
      if (user.address != null) {
        _addressController.text = user.address!.address ?? '';
        _cityController.text = user.address!.city ?? '';
        _stateController.text = user.address!.state ?? '';
        _zipController.text = user.address!.zip ?? '';
        _countryController.text = user.address!.country ?? '';
      }
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthProviderChanged);
    _firstnameController.dispose();
    _lastnameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFC7A87B),
              Color(0xFF8B5E3C),
              Color(0xFFC7A87B),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Editar Perfil',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 44), // Para equilibrar o layout
                  ],
                ),
              ),

              // Formulário
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFC7A87B).withOpacity(0.1),
                                    border: Border.all(
                                      color: const Color(0xFFC7A87B),
                                      width: 3,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Color(0xFFC7A87B),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFC7A87B),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Seção de Dados Pessoais
                          _buildSectionTitle('Dados Pessoais'),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _firstnameController,
                            label: 'Nome',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira seu nome';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _lastnameController,
                            label: 'Sobrenome',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira seu sobrenome';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _mobileController,
                            label: 'Telefone',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value)) {
                                  return 'Por favor, insira um telefone válido';
                                }
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 32),

                          // Seção de Endereço
                          _buildSectionTitle('Endereço'),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _addressController,
                            label: 'Endereço',
                            icon: Icons.location_on_outlined,
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildTextField(
                                  controller: _cityController,
                                  label: 'Cidade',
                                  icon: Icons.location_city_outlined,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _zipController,
                                  label: 'CEP',
                                  icon: Icons.local_post_office_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _stateController,
                                  label: 'Estado/Província',
                                  icon: Icons.map_outlined,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _countryController,
                                  label: 'País',
                                  icon: Icons.flag_outlined,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          // Botão Salvar
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFC7A87B), Color(0xFF8B5E3C)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFC7A87B).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Salvar Alterações',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF718096),
          fontSize: 16,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFFC7A87B),
          size: 22,
        ),
        filled: true,
        fillColor: const Color(0xFFF7FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFC7A87B),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Criar objeto de endereço se algum campo estiver preenchido
        UserAddress? address;
        if (_addressController.text.isNotEmpty ||
            _cityController.text.isNotEmpty ||
            _stateController.text.isNotEmpty ||
            _zipController.text.isNotEmpty ||
            _countryController.text.isNotEmpty) {
          address = UserAddress(
            address: _addressController.text.isNotEmpty ? _addressController.text : null,
            city: _cityController.text.isNotEmpty ? _cityController.text : null,
            state: _stateController.text.isNotEmpty ? _stateController.text : null,
            zip: _zipController.text.isNotEmpty ? _zipController.text : null,
            country: _countryController.text.isNotEmpty ? _countryController.text : null,
          );
        }

        final success = await _authProvider.updateProfile(
          firstname: _firstnameController.text.isNotEmpty ? _firstnameController.text : null,
          lastname: _lastnameController.text.isNotEmpty ? _lastnameController.text : null,
          mobile: _mobileController.text.isNotEmpty ? _mobileController.text : null,
          address: address,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil atualizado com sucesso!'),
                backgroundColor: Color(0xFFC7A87B),
              ),
            );
            Navigator.pop(context, true); // Retorna true para indicar sucesso
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_authProvider.errorMessage ?? 'Erro ao atualizar perfil'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro de conexão: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
