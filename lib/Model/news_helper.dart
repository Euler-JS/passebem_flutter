// lib/helpers/news_helper.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/news_model.dart';
import '../services/local_bookmark_service.dart';

class NewsHelper {
  
  // Incrementar visualizações de uma notícia
  static Future<void> incrementViews(Yournews news) async {
    try {
      // Incrementar localmente
      news.views += 1;
      
      // Salvar no SharedPreferences o número de views para esta notícia
      final prefs = await SharedPreferences.getInstance();
      final viewsKey = 'news_views_${news.id}';
      await prefs.setInt(viewsKey, news.views);
      
      print('Views incrementadas para: ${news.newsTitle} - Total: ${news.views}');
      
    } catch (e) {
      print('Erro ao incrementar views: $e');
    }
  }

  // Alternar bookmark de uma notícia - APENAS LOCAL
  static Future<bool> toggleBookmark(Yournews news) async {
    try {
      // Garantir que a notícia tenha um ID
      if (news.id.isEmpty) {
        // Criar um ID baseado no hash do título se não existir
        news.id = news.newsTitle.hashCode.abs().toString();
        print('ID gerado para notícia: ${news.id}');
      }
      
      // Usar o serviço local de bookmarks
      final wasAdded = await LocalBookmarkService.toggleBookmark(news);
      
      return wasAdded;
    } catch (e) {
      print('Erro ao alternar bookmark: $e');
      return false;
    }
  }

  // Verificar se uma notícia está nos bookmarks - APENAS LOCAL
  static Future<bool> isBookmarked(Yournews news) async {
    try {
      // Garantir que a notícia tenha um ID
      if (news.id.isEmpty) {
        news.id = news.newsTitle.hashCode.abs().toString();
      }
      
      return await LocalBookmarkService.isNewsBookmarked(news.id);
    } catch (e) {
      print('Erro ao verificar bookmark: $e');
      return false;
    }
  }

  // Obter todas as notícias salvas - APENAS LOCAL
  static Future<List<Yournews>> getBookmarkedNews() async {
    try {
      return await LocalBookmarkService.getBookmarkedNews();
    } catch (e) {
      print('Erro ao obter notícias salvas: $e');
      return [];
    }
  }

  // Carregar views salvas para uma notícia
  static Future<int> getStoredViews(String newsId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final viewsKey = 'news_views_$newsId';
      return prefs.getInt(viewsKey) ?? 0;
    } catch (e) {
      print('Erro ao obter views salvas: $e');
      return 0;
    }
  }

  // Salvar views para uma notícia
  static Future<void> saveViews(String newsId, int views) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final viewsKey = 'news_views_$newsId';
      await prefs.setInt(viewsKey, views);
    } catch (e) {
      print('Erro ao salvar views: $e');
    }
  }

  // Métodos para compatibilidade com dados existentes
  static List<Yournews> getFeaturedNews() {
    return newsItems.where((news) => news.isFeatured).toList();
  }
  
  static List<Yournews> getMostReadNews() {
    List<Yournews> sortedNews = List.from(newsItems);
    sortedNews.sort((a, b) => b.views.compareTo(a.views));
    return sortedNews.take(5).toList();
  }
  
  static List<Yournews> getRecentNews() {
    return newsItems.take(4).toList();
  }
  
  static List<Yournews> getNewsByCategory(String category) {
    return newsItems.where((news) => 
      news.newsCategories.toLowerCase() == category.toLowerCase()
    ).toList();
  }
}