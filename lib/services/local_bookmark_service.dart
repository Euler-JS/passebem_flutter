// lib/services/local_bookmark_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/news_model.dart';

class LocalBookmarkService {
  static const String _bookmarksKey = 'local_bookmarks';

  // Obter todas as notícias salvas localmente
  static Future<List<Yournews>> getBookmarkedNews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];
      
      List<Yournews> bookmarkedNews = [];
      for (String jsonString in bookmarksJson) {
        try {
          final Map<String, dynamic> newsMap = json.decode(jsonString);
          bookmarkedNews.add(Yournews.fromJson(newsMap));
        } catch (e) {
          print('Erro ao decodificar notícia salva: $e');
        }
      }
      
      return bookmarkedNews;
    } catch (e) {
      print('Erro ao obter bookmarks locais: $e');
      return [];
    }
  }

  // Verificar se uma notícia está salva localmente
  static Future<bool> isNewsBookmarked(String newsId) async {
    try {
      final bookmarkedNews = await getBookmarkedNews();
      return bookmarkedNews.any((news) => news.id == newsId);
    } catch (e) {
      print('Erro ao verificar bookmark: $e');
      return false;
    }
  }

  // Alternar bookmark de uma notícia (adicionar se não existe, remover se existe)
  static Future<bool> toggleBookmark(Yournews news) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarkedNews = await getBookmarkedNews();
      
      // Verificar se a notícia já está salva
      final isCurrentlyBookmarked = bookmarkedNews.any((savedNews) => savedNews.id == news.id);
      
      if (isCurrentlyBookmarked) {
        // Remover dos bookmarks
        bookmarkedNews.removeWhere((savedNews) => savedNews.id == news.id);
        news.isBookmarked = false;
        print('Notícia removida dos bookmarks: ${news.newsTitle}');
      } else {
        // Adicionar aos bookmarks
        news.isBookmarked = true;
        bookmarkedNews.add(news);
        print('Notícia adicionada aos bookmarks: ${news.newsTitle}');
      }
      
      // Salvar a lista atualizada
      final bookmarksJson = bookmarkedNews.map((news) => json.encode(news.toJson())).toList();
      await prefs.setStringList(_bookmarksKey, bookmarksJson);
      
      return !isCurrentlyBookmarked; // Retorna true se foi adicionado, false se foi removido
    } catch (e) {
      print('Erro ao alternar bookmark: $e');
      return false;
    }
  }

  // Adicionar notícia aos bookmarks
  static Future<bool> addBookmark(Yournews news) async {
    try {
      final isAlreadyBookmarked = await isNewsBookmarked(news.id);
      if (isAlreadyBookmarked) {
        return true; // Já está salva
      }
      
      final prefs = await SharedPreferences.getInstance();
      final bookmarkedNews = await getBookmarkedNews();
      
      news.isBookmarked = true;
      bookmarkedNews.add(news);
      
      final bookmarksJson = bookmarkedNews.map((news) => json.encode(news.toJson())).toList();
      await prefs.setStringList(_bookmarksKey, bookmarksJson);
      
      print('Notícia adicionada aos bookmarks: ${news.newsTitle}');
      return true;
    } catch (e) {
      print('Erro ao adicionar bookmark: $e');
      return false;
    }
  }

  // Remover notícia dos bookmarks
  static Future<bool> removeBookmark(String newsId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarkedNews = await getBookmarkedNews();
      
      final initialLength = bookmarkedNews.length;
      bookmarkedNews.removeWhere((news) => news.id == newsId);
      
      if (bookmarkedNews.length < initialLength) {
        final bookmarksJson = bookmarkedNews.map((news) => json.encode(news.toJson())).toList();
        await prefs.setStringList(_bookmarksKey, bookmarksJson);
        print('Notícia removida dos bookmarks: $newsId');
        return true;
      }
      
      return false; // Notícia não estava nos bookmarks
    } catch (e) {
      print('Erro ao remover bookmark: $e');
      return false;
    }
  }

  // Limpar todos os bookmarks
  static Future<bool> clearAllBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_bookmarksKey);
      print('Todos os bookmarks foram removidos');
      return true;
    } catch (e) {
      print('Erro ao limpar bookmarks: $e');
      return false;
    }
  }

  // Obter total de bookmarks
  static Future<int> getBookmarksCount() async {
    try {
      final bookmarkedNews = await getBookmarkedNews();
      return bookmarkedNews.length;
    } catch (e) {
      print('Erro ao obter contagem de bookmarks: $e');
      return 0;
    }
  }
}