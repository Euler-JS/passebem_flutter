// lib/services/podcast_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/podcast_model.dart';
import 'auth_service.dart';

class PodcastService {
  static const String baseUrl = 'https://tsevelenews.tsevele.co.mz/api/podcasts';
  
  // Headers padrão
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Headers com autenticação (se disponível)
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await AuthService.getToken();
    final baseHeaders = headers;
    if (token != null) {
      baseHeaders['Authorization'] = 'Bearer $token';
    }
    return baseHeaders;
  }

  // Obter todos os podcasts
  static Future<PodcastResponse?> getAllPodcasts({int page = 1, int perPage = 15}) async {
    try {
      final authHeaders = await getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl?page=$page&per_page=$perPage'),
        headers: authHeaders,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return PodcastResponse.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      print('Error getting podcasts: $e');
      return null;
    }
  }

  // Obter categorias de podcasts
  static Future<PodcastCategoryResponse?> getCategories({int page = 1, int perPage = 15}) async {
    try {
      final authHeaders = await getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/categories?page=$page&per_page=$perPage'),
        headers: authHeaders,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return PodcastCategoryResponse.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      print('Error getting podcast categories: $e');
      return null;
    }
  }

  // Obter podcasts por categoria
  static Future<PodcastResponse?> getPodcastsByCategory(
    int categoryId, {
    int page = 1, 
    int perPage = 15
  }) async {
    try {
      final authHeaders = await getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/category/$categoryId?page=$page&per_page=$perPage'),
        headers: authHeaders,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return PodcastResponse.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      print('Error getting podcasts by category: $e');
      return null;
    }
  }

  // Obter detalhes de um podcast específico
  static Future<PodcastModel?> getPodcast(int podcastId) async {
    try {
      final authHeaders = await getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/$podcastId'),
        headers: authHeaders,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success' && jsonData['data'] != null) {
          return PodcastModel.fromJson(jsonData['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error getting podcast details: $e');
      return null;
    }
  }

  // Buscar podcasts
  static Future<PodcastResponse?> searchPodcasts(
    String query, {
    int page = 1,
    int perPage = 15,
    int? categoryId,
  }) async {
    try {
      final authHeaders = await getAuthHeaders();
      
      String url = '$baseUrl/search?q=$query&page=$page&per_page=$perPage';
      if (categoryId != null) {
        url += '&category_id=$categoryId';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: authHeaders,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return PodcastResponse.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      print('Error searching podcasts: $e');
      return null;
    }
  }

  // Marcar podcast como visualizado
  static Future<bool> markAsViewed(int podcastId) async {
    try {
      final authHeaders = await getAuthHeaders();
      
      final response = await http.post(
        Uri.parse('$baseUrl/$podcastId/view'),
        headers: authHeaders,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking podcast as viewed: $e');
      return false;
    }
  }

  // Adicionar podcast aos favoritos
  static Future<bool> toggleFavorite(int podcastId) async {
    try {
      final authHeaders = await getAuthHeaders();
      
      final response = await http.post(
        Uri.parse('$baseUrl/$podcastId/favorite'),
        headers: authHeaders,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error toggling podcast favorite: $e');
      return false;
    }
  }

  // Obter podcasts favoritos do usuário
  static Future<PodcastResponse?> getFavorites({int page = 1, int perPage = 15}) async {
    try {
      final authHeaders = await getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/favorites?page=$page&per_page=$perPage'),
        headers: authHeaders,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return PodcastResponse.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      print('Error getting favorite podcasts: $e');
      return null;
    }
  }

  // Obter histórico de podcasts ouvidos
  static Future<PodcastResponse?> getHistory({int page = 1, int perPage = 15}) async {
    try {
      final authHeaders = await getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/history?page=$page&per_page=$perPage'),
        headers: authHeaders,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return PodcastResponse.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      print('Error getting podcast history: $e');
      return null;
    }
  }
}
