// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:news_app/Model/api_news_model.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://tsevelenews.tsevele.co.mz/api';
  
  // Headers padrão
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Headers com autenticação (quando disponível)
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await AuthService.getToken();
    final baseHeaders = headers;
    if (token != null) {
      baseHeaders['Authorization'] = 'Bearer $token';
    }
    return baseHeaders;
  }
  
  // Buscar notícias em destaque
  static Future<List<ApiNewsModel>> getFeaturedNews() async {
    try {
      final authHeaders = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/news/featured'),
        headers: authHeaders,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == 'success') {
          final List<dynamic> newsData = jsonData['data'];
          return newsData.map((item) => ApiNewsModel.fromJson(item)).toList();
        } else {
          throw Exception('API returned error: ${jsonData['message']}');
        }
      } else {
        throw Exception('Failed to load featured news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching featured news: $e');
    }
  }
  // Método que retorna lista simples de notícias
static Future<List<ApiNewsModel>> getAllNewsSimple({int page = 1, int perPage = 50}) async {
  try {
    final authHeaders = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/news?page=$page&per_page=$perPage'),
      headers: authHeaders,
    );
    
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      
      if (jsonData['status'] == 'success') {
        final List<dynamic> newsData = jsonData['data'];
        return newsData.map((item) => ApiNewsModel.fromJson(item)).toList();
      } else {
        throw Exception('API returned error: ${jsonData['message']}');
      }
    } else {
      throw Exception('Failed to load news: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching all news: $e');
  }
}
  // Buscar todas as notícias (com paginação)
  static Future<Map<String, dynamic>> getAllNews({
    int page = 1,
    int perPage = 10,
    String? category,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      final uri = Uri.parse('$baseUrl/news').replace(queryParameters: queryParams);
      final authHeaders = await getAuthHeaders();
      final response = await http.get(uri, headers: authHeaders);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == 'success') {
          final List<dynamic> newsData = jsonData['data']['data'];
          final newsList = newsData.map((item) => ApiNewsModel.fromJson(item)).toList();
          
          return {
            'news': newsList,
            'pagination': {
              'current_page': jsonData['data']['current_page'],
              'last_page': jsonData['data']['last_page'],
              'total': jsonData['data']['total'],
              'per_page': jsonData['data']['per_page'],
            }
          };
        } else {
          throw Exception('API returned error: ${jsonData['message']}');
        }
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }
  
  // Buscar notícia específica por ID
  static Future<ApiNewsModel> getNewsById(int id) async {
    try {
      final authHeaders = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/news/$id'),
        headers: authHeaders,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == 'success') {
          return ApiNewsModel.fromJson(jsonData['data']);
        } else {
          throw Exception('API returned error: ${jsonData['message']}');
        }
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news by ID: $e');
    }
  }
  
  // Buscar categorias
  static Future<List<CategoryModel>> getCategories() async {
    try {
      final authHeaders = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/news-categories'),
        headers: authHeaders,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == 'success') {
          final List<dynamic> categoriesData = jsonData['data'];
          return categoriesData.map((item) => CategoryModel.fromJson(item)).toList();
        } else {
          throw Exception('API returned error: ${jsonData['message']}');
        }
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
  
  // Incrementar visualizações
  static Future<void> incrementViews(int newsId) async {
    try {
      final authHeaders = await getAuthHeaders();
      await http.post(
        Uri.parse('$baseUrl/news/$newsId/views'),
        headers: authHeaders,
      );
    } catch (e) {
      // Falha silenciosa para incremento de views
      print('Error incrementing views: $e');
    }
  }
  
  // Buscar notícias por categoria
  static Future<List<ApiNewsModel>> getNewsByCategory(int categoryId) async {
    try {
      final authHeaders = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/news/category/$categoryId'),
        headers: authHeaders,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == 'success') {
          final List<dynamic> newsData = jsonData['data'];
          return newsData.map((item) => ApiNewsModel.fromJson(item)).toList();
        } else {
          throw Exception('API returned error: ${jsonData['message']}');
        }
      } else {
        throw Exception('Failed to load news by category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news by category: $e');
    }
  }
  
  // Buscar notícias mais lidas
  static Future<List<ApiNewsModel>> getMostReadNews() async {
    try {
      final authHeaders = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/news/most-read'),
        headers: authHeaders,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == 'success') {
          final List<dynamic> newsData = jsonData['data'];
          return newsData.map((item) => ApiNewsModel.fromJson(item)).toList();
        } else {
          throw Exception('API returned error: ${jsonData['message']}');
        }
      } else {
        throw Exception('Failed to load most read news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching most read news: $e');
    }
  }
  
  // Buscar notícias recentes
  static Future<List<ApiNewsModel>> getRecentNews() async {
    try {
      final authHeaders = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/news/recent'),
        headers: authHeaders,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == 'success') {
          final List<dynamic> newsData = jsonData['data'];
          return newsData.map((item) => ApiNewsModel.fromJson(item)).toList();
        } else {
          throw Exception('API returned error: ${jsonData['message']}');
        }
      } else {
        throw Exception('Failed to load recent news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching recent news: $e');
    }
  }
}