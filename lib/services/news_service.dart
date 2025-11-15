// lib/services/news_service.dart
import 'dart:convert';
import 'dart:math' as math; // Importação para funções matemáticas
import 'package:flutter/material.dart'; // Importação necessária para a classe Color
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/news_model.dart';

class NewsService {
  static const String baseUrl = 'https://tsevelenews.tsevele.co.mz/api';

  // Obter token armazenado para autenticação
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    print('NewsService: Token obtido: ${token != null ? (token.substring(0, math.min(10, token.length)) + '...') : 'null'}');
    
    // Se não houver token, verificar se há um token de teste
    if (token == null) {
      print('NewsService: Token não encontrado, verificando token de teste');
      // Se você tiver um token de teste para desenvolvimento, pode usar aqui
      // return 'seu-token-de-teste';
    }
    
    return token;
  }

  // Headers padrão com autenticação
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Obter notícias favoritas do servidor
  static Future<List<Yournews>> getBookmarkedNews() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/news/bookmarked'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Converter resposta da API para objetos Yournews
        List<Yournews> bookmarkedNews = [];
        for (var item in data['data']) {
          // Aqui precisamos converter o formato da API para o nosso modelo local
          // Isso pode precisar de ajustes baseados na estrutura exata da resposta
          bookmarkedNews.add(Yournews(
            image: item['image'] ?? '',
            newsImage: item['image'] ?? '',
            newsTitle: item['title'] ?? '',
            newsCategories: item['category'] ?? 'GENERAL',
            time: item['created_at'] ?? '',
            date: item['publication_date'] ?? '',
            color: getCategoryColor(item['category'] ?? 'GENERAL'),
            description: item['summary'] ?? '',
            fullContent: item['content'] ?? '',
            isPremium: item['is_premium'] ?? false,
            views: item['views'] ?? 0,
            isBookmarked: true, // Já que veio da lista de favoritos
            isFeatured: item['is_featured'] ?? false,
          ));
        }
        
        return bookmarkedNews;
      } else {
        print('Erro ao buscar favoritos: ${response.statusCode}');
        // Em caso de erro, retornar lista vazia
        return [];
      }
    } catch (e) {
      print('Exceção ao buscar favoritos: $e');
      return [];
    }
  }

  // Adicionar notícia aos favoritos
  static Future<bool> bookmarkNews(String newsId) async {
    try {
      print('NewsService: Adicionando bookmark para notícia ID: $newsId');
      
      final headers = await _getHeaders();
      final url = '$baseUrl/news/$newsId/bookmark';
      
      print('NewsService: Chamando API POST $url');
      print('NewsService: Headers: $headers');
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      );
      
      print('NewsService: Resposta da API - Status: ${response.statusCode}');
      print('NewsService: Resposta da API - Body: ${response.body}');
      
      final success = response.statusCode == 200 || response.statusCode == 201;
      print('NewsService: Operação ${success ? "bem-sucedida" : "falhou"}');
      
      return success;
    } catch (e) {
      print('NewsService: Exceção ao adicionar favorito: $e');
      return false;
    }
  }

  // Remover notícia dos favoritos
  static Future<bool> unbookmarkNews(String newsId) async {
    try {
      print('NewsService: Removendo bookmark para notícia ID: $newsId');
      
      final headers = await _getHeaders();
      final url = '$baseUrl/news/$newsId/bookmark';
      
      print('NewsService: Chamando API DELETE $url');
      print('NewsService: Headers: $headers');
      
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );
      
      print('NewsService: Resposta da API - Status: ${response.statusCode}');
      print('NewsService: Resposta da API - Body: ${response.body}');
      
      final success = response.statusCode == 200 || response.statusCode == 204;
      print('NewsService: Operação ${success ? "bem-sucedida" : "falhou"}');
      
      return success;
    } catch (e) {
      print('NewsService: Exceção ao remover favorito: $e');
      return false;
    }
  }

  // Verificar se uma notícia está nos favoritos
  static Future<bool> isNewsBookmarked(String newsId) async {
    try {
      final bookmarks = await getBookmarkedNews();
      return bookmarks.any((news) => news.id == newsId);
    } catch (e) {
      return false;
    }
  }

  // Helper para obter a cor baseada na categoria
  static Color getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'WORLD':
        return const Color(0xFF8B5E3C);
      case 'TECH':
        return const Color(0xFF333333);
      case 'MUSIC':
        return const Color(0xFFC7A87B);
      case 'TRAVEL':
        return const Color(0xFF8B5E3C);
      case 'FASHION':
        return const Color(0xFFC7A87B);
      default:
        return const Color(0xFF333333);
    }
  }
}
