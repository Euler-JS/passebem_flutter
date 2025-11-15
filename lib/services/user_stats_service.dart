// lib/services/user_stats_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/user_stats_model.dart';

class UserStatsService {
  static const String _statsKey = 'user_stats';
  static const String _bookmarksKey = 'bookmarked_articles';

  // Carregar estatísticas do usuário
  static Future<UserStats> getUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_statsKey);
      
      if (statsJson != null) {
        final statsData = json.decode(statsJson);
        var stats = UserStats.fromJson(statsData);
        
        // Verificar se precisa resetar os artigos lidos hoje
        stats = await _checkAndResetDailyStats(stats);
        
        // Atualizar contagem de bookmarks
        stats = await _updateBookmarkCount(stats);
        
        return stats;
      } else {
        // Primeira vez - criar estatísticas vazias
        final emptyStats = UserStats.empty();
        await _saveUserStats(emptyStats);
        return emptyStats;
      }
    } catch (e) {
      print('Erro ao carregar estatísticas do usuário: $e');
      return UserStats.empty();
    }
  }

  // Salvar estatísticas do usuário
  static Future<void> _saveUserStats(UserStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = json.encode(stats.toJson());
      await prefs.setString(_statsKey, statsJson);
    } catch (e) {
      print('Erro ao salvar estatísticas do usuário: $e');
    }
  }

  // Verificar e resetar estatísticas diárias
  static Future<UserStats> _checkAndResetDailyStats(UserStats stats) async {
    final now = DateTime.now();
    final lastReadDate = stats.lastReadDate;
    
    // Se o último dia de leitura não foi hoje, resetar contadores diários
    if (!_isSameDay(now, lastReadDate)) {
      final daysDifference = now.difference(lastReadDate).inDays;
      
      // Se perdeu um dia, resetar streak
      final newStreak = daysDifference == 1 ? stats.readingStreak : 0;
      
      final newStats = stats.copyWith(
        articlesReadToday: 0,
        readingStreak: newStreak,
        lastReadDate: now,
      );
      
      await _saveUserStats(newStats);
      return newStats;
    }
    
    return stats;
  }

  // Atualizar contagem de bookmarks
  static Future<UserStats> _updateBookmarkCount(UserStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = prefs.getStringList(_bookmarksKey) ?? [];
      
      final updatedStats = stats.copyWith(
        bookmarkedArticles: bookmarks.length,
      );
      
      await _saveUserStats(updatedStats);
      return updatedStats;
    } catch (e) {
      print('Erro ao atualizar contagem de bookmarks: $e');
      return stats;
    }
  }

  // Registrar que o usuário leu um artigo
  static Future<UserStats> recordArticleRead({
    String? category,
  }) async {
    try {
      final currentStats = await getUserStats();
      final now = DateTime.now();
      
      // Atualizar estatísticas por categoria
      final updatedReadsByCategory = Map<String, int>.from(currentStats.readsByCategory);
      if (category != null) {
        updatedReadsByCategory[category] = (updatedReadsByCategory[category] ?? 0) + 1;
      }
      
      // Verificar se é um novo dia de leitura para atualizar streak
      int newStreak = currentStats.readingStreak;
      if (_isSameDay(now, currentStats.lastReadDate)) {
        // Mesmo dia - manter streak atual
        newStreak = currentStats.readingStreak;
      } else {
        // Novo dia - incrementar streak
        final daysDifference = now.difference(currentStats.lastReadDate).inDays;
        if (daysDifference == 1) {
          newStreak = currentStats.readingStreak + 1;
        } else {
          newStreak = 1; // Reiniciar streak
        }
      }
      
      final updatedStats = currentStats.copyWith(
        articlesReadToday: currentStats.articlesReadToday + 1,
        totalArticlesRead: currentStats.totalArticlesRead + 1,
        readingStreak: newStreak,
        lastReadDate: now,
        readsByCategory: updatedReadsByCategory,
      );
      
      await _saveUserStats(updatedStats);
      return updatedStats;
    } catch (e) {
      print('Erro ao registrar leitura de artigo: $e');
      return await getUserStats();
    }
  }

  // Registrar bookmark
  static Future<UserStats> recordBookmark(String articleId, {bool isBookmarked = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = prefs.getStringList(_bookmarksKey) ?? [];
      
      if (isBookmarked) {
        if (!bookmarks.contains(articleId)) {
          bookmarks.add(articleId);
        }
      } else {
        bookmarks.remove(articleId);
      }
      
      await prefs.setStringList(_bookmarksKey, bookmarks);
      
      // Atualizar estatísticas
      final currentStats = await getUserStats();
      final updatedStats = currentStats.copyWith(
        bookmarkedArticles: bookmarks.length,
      );
      
      await _saveUserStats(updatedStats);
      return updatedStats;
    } catch (e) {
      print('Erro ao registrar bookmark: $e');
      return await getUserStats();
    }
  }

  // Verificar se duas datas são do mesmo dia
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // Resetar todas as estatísticas (para teste ou reset do usuário)
  static Future<void> resetStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_statsKey);
      await prefs.remove(_bookmarksKey);
    } catch (e) {
      print('Erro ao resetar estatísticas: $e');
    }
  }

  // Obter categoria mais lida
  static Future<String?> getMostReadCategory() async {
    try {
      final stats = await getUserStats();
      if (stats.readsByCategory.isEmpty) return null;
      
      String mostReadCategory = '';
      int maxReads = 0;
      
      stats.readsByCategory.forEach((category, reads) {
        if (reads > maxReads) {
          maxReads = reads;
          mostReadCategory = category;
        }
      });
      
      return mostReadCategory.isNotEmpty ? mostReadCategory : null;
    } catch (e) {
      print('Erro ao obter categoria mais lida: $e');
      return null;
    }
  }

  // Obter tempo médio de leitura estimado (baseado em estatísticas)
  static Future<int> getEstimatedReadingTimeMinutes() async {
    try {
      final stats = await getUserStats();
      // Estimativa: 3 minutos por artigo em média
      const int avgReadTimePerArticle = 3;
      return stats.totalArticlesRead * avgReadTimePerArticle;
    } catch (e) {
      print('Erro ao calcular tempo estimado de leitura: $e');
      return 0;
    }
  }
}
