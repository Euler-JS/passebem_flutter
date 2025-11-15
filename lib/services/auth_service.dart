// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/user_model.dart';

class AuthService {
  static const String baseUrl = 'http://mowosocw4sgwsk84kw4ks40c.62.171.183.132.sslip.io';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  // Headers padrão
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Headers com autenticação
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    final baseHeaders = headers;
    if (token != null) {
      baseHeaders['Authorization'] = 'Bearer $token';
    }
    return baseHeaders;
  }

  // Registrar usuário
  static Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/appuser'),
        headers: headers,
        body: json.encode(request.toJson()),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return AuthResponse(
          success: true,
          message: jsonData.toString(),
        );
      } else {
        return AuthResponse(
          success: false,
          message: 'Erro no registro',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  // Login
  static Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/appuser'),
        headers: {
          'numero': request.login,
          'senha': request.password,
        },
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final user = UserModel.fromJson(jsonData);
        final token = user.id.toString();
        
        await _saveAuthData(token, user);
        
        return AuthResponse(
          success: true,
          message: 'Login realizado com sucesso',
          user: user,
          token: token,
        );
      } else {
        String message = 'Credenciais inválidas';
        if (response.statusCode == 401) {
          message = 'Credenciais inválidas. Verifique seu telefone e senha.';
        } else if (response.statusCode == 404) {
          message = 'Usuário não encontrado.';
        }
        return AuthResponse(
          success: false,
          message: message,
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  // Logout
  static Future<bool> logout() async {
    try {
      final authHeaders = await getAuthHeaders();
      
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: authHeaders,
      );
      
      // Mesmo que o logout no servidor falhe, removemos os dados locais
      await _clearAuthData();
      
      return response.statusCode == 200;
    } catch (e) {
      // Em caso de erro, ainda assim removemos os dados locais
      await _clearAuthData();
      return false;
    }
  }

  // Obter perfil do usuário
  static Future<UserModel?> getProfile() async {
    try {
      final authHeaders = await getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: authHeaders,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == 'success') {
          UserModel user;
          
          // Tentar diferentes estruturas de resposta
          if (jsonData['data'] != null && jsonData['data']['user'] != null) {
            // Estrutura: { "status": "success", "data": { "user": { "id": 1, "email": "..." } } }
            user = UserModel.fromJson(jsonData['data']['user']);
          } else if (jsonData['data'] != null && jsonData['data'] is Map) {
            // Estrutura: { "status": "success", "data": { "id": 1, "email": "..." } }
            user = UserModel.fromJson(jsonData['data']);
          } else if (jsonData['user'] != null) {
            // Estrutura: { "status": "success", "user": { "id": 1, "email": "..." } }
            user = UserModel.fromJson(jsonData['user']);
          } else {
            // Estrutura: { "status": "success", "id": 1, "email": "..." } (dados diretos)
            user = UserModel.fromJson(jsonData);
          }
          
          await _saveUser(user);
          return user;
        }
      }
      return null;
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  // Alterar senha
  static Future<AuthResponse> changePassword(ChangePasswordRequest request) async {
    try {
      final authHeaders = await getAuthHeaders();
      
      final response = await http.put(
        Uri.parse('$baseUrl/change-password'),
        headers: authHeaders,
        body: json.encode(request.toJson()),
      );
      
      final jsonData = json.decode(response.body);
      return AuthResponse.fromJson(jsonData);
      
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  // Verificar se usuário está logado
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Obter token armazenado
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Obter usuário armazenado
  static Future<UserModel?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson != null) {
      try {
        final userData = json.decode(userJson);
        return UserModel.fromJson(userData);
      } catch (e) {
        print('Error parsing stored user: $e');
        return null;
      }
    }
    return null;
  }

  // Salvar dados de autenticação
  static Future<void> _saveAuthData(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  // Salvar apenas dados do usuário
  static Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  // Limpar dados de autenticação
  static Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Verificar se token é válido (faz uma requisição para o perfil)
  static Future<bool> validateToken() async {
    try {
      final user = await getProfile();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  // Atualizar perfil
  static Future<AuthResponse> updateProfile(UpdateProfileRequest request) async {
    try {
      final authHeaders = await getAuthHeaders();
      
      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: authHeaders,
        body: json.encode(request.toJson()),
      );
      
      final jsonData = json.decode(response.body);
      final authResponse = AuthResponse.fromJson(jsonData);
      
      if (response.statusCode == 200 && authResponse.success && authResponse.user != null) {
        await _saveUser(authResponse.user!);
      }
      
      return authResponse;
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  // Atualizar perfil (método genérico - mantido para compatibilidade)
  static Future<AuthResponse> updateProfileGeneric(Map<String, dynamic> data) async {
    try {
      final authHeaders = await getAuthHeaders();
      
      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: authHeaders,
        body: json.encode(data),
      );
      
      final jsonData = json.decode(response.body);
      final authResponse = AuthResponse.fromJson(jsonData);
      
      if (response.statusCode == 200 && authResponse.success && authResponse.user != null) {
        await _saveUser(authResponse.user!);
      }
      
      return authResponse;
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  // Esqueci a senha
  static Future<AuthResponse> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: headers,
        body: json.encode({'email': email}),
      );
      
      final jsonData = json.decode(response.body);
      return AuthResponse.fromJson(jsonData);
      
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }
  
  // Buscar temas (requer autenticação com ID do usuário)
  static Future<Map<String, dynamic>> getTemas() async {
    try {
      // Obter o usuário armazenado para pegar o ID
      final user = await getStoredUser();
      if (user == null || user.id.isEmpty) {
        throw Exception('User not logged in or ID not available');
      }
      
      // Criar headers com Authorization igual ao ID do usuário (como no React)
      final temasHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': user.id, // Usa o ID do usuário como token
      };
      
      print('Temas request headers: $temasHeaders');
      
      final response = await http.get(
        Uri.parse('$baseUrl/apptemas'),
        headers: temasHeaders,
      );
      
      print('Temas response status: ${response.statusCode}');
      print('Temas response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception('Failed to load temas: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching temas: $e');
      throw Exception('Error fetching temas: $e');
    }
  }

  // ===== MÉTODOS DE CHAT =====
  
  // Buscar todas as mensagens do chat
  static Future<List<dynamic>> getChatMessages() async {
    try {
      final user = await getStoredUser();
      if (user == null || user.id.isEmpty) {
        throw Exception('User not logged in');
      }
      
      final chatHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': user.id,
      };
      
      final response = await http.get(
        Uri.parse('$baseUrl/chatall'),
        headers: chatHeaders,
      );
      
      print('Chat messages response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData as List<dynamic>;
      } else {
        throw Exception('Failed to load chat messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching chat messages: $e');
      return [];
    }
  }
  
  // Enviar mensagem de texto
  static Future<bool> sendTextMessage(String text) async {
    try {
      final user = await getStoredUser();
      if (user == null || user.id.isEmpty) {
        throw Exception('User not logged in');
      }
      
      final chatHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': user.id,
        'user': user.id,
      };
      
      final body = {
        'text': text,
        'name': user.username ?? user.firstname ?? 'user',
        'avatar': 'https://oolhar.com.br/wp-content/uploads/2020/09/perfil-candidatos.jpg',
      };
      
      print('Sending message with headers: $chatHeaders');
      print('Sending message body: $body');
      
      final response = await http.post(
        Uri.parse('$baseUrl/chattext'),
        headers: chatHeaders,
        body: json.encode(body),
      );
      
      print('Send text message response status: ${response.statusCode}');
      print('Send text message response body: ${response.body}');
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error sending text message: $e');
      return false;
    }
  }
  
  // Enviar imagem
  static Future<bool> sendImageMessage(String imagePath) async {
    try {
      final user = await getStoredUser();
      if (user == null || user.id.isEmpty) {
        throw Exception('User not logged in');
      }
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/chatimagem'),
      );
      
      request.headers['Authorization'] = user.id;
      
      request.files.add(
        await http.MultipartFile.fromPath('imagem', imagePath),
      );
      
      request.fields['name'] = user.username ?? user.firstname ?? 'user';
      request.fields['avatar'] = 'https://oolhar.com.br/wp-content/uploads/2020/09/perfil-candidatos.jpg';
      
      final response = await request.send();
      
      print('Send image message response status: ${response.statusCode}');
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error sending image message: $e');
      return false;
    }
  }
  
  // Enviar vídeo
  static Future<bool> sendVideoMessage(String videoPath) async {
    try {
      final user = await getStoredUser();
      if (user == null || user.id.isEmpty) {
        throw Exception('User not logged in');
      }
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/chatvideo'),
      );
      
      request.headers['Authorization'] = user.id;
      
      request.files.add(
        await http.MultipartFile.fromPath('imagem', videoPath),
      );
      
      request.fields['name'] = user.username ?? user.firstname ?? 'user';
      request.fields['avatar'] = 'https://oolhar.com.br/wp-content/uploads/2020/09/perfil-candidatos.jpg';
      
      final response = await request.send();
      
      print('Send video message response status: ${response.statusCode}');
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error sending video message: $e');
      return false;
    }
  }

  // ===== MÉTODOS DE MÓDULOS/AULAS =====
  
  // Buscar módulos e vídeos de aula
  static Future<Map<String, dynamic>> getModulos() async {
    try {
      final user = await getStoredUser();
      if (user == null || user.id.isEmpty) {
        throw Exception('User not logged in');
      }
      
      final modulosHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': user.id,
      };
      
      final response = await http.get(
        Uri.parse('$baseUrl/appmodulos'),
        headers: modulosHeaders,
      );
      
      print('Modulos response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        // Retornar a estrutura completa com modulos e videos
        if (jsonData['data'] != null) {
          return {
            'modulos': jsonData['data']['modulos'] ?? [],
            'videos': jsonData['data']['videosaulas'] ?? [],
          };
        }
        
        return {
          'modulos': [],
          'videos': [],
        };
      } else {
        throw Exception('Failed to load modulos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching modulos: $e');
      return {
        'modulos': [],
        'videos': [],
      };
    }
  }
}
