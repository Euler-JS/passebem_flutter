// lib/Model/user_stats_model.dart
class UserStats {
  final int articlesReadToday;
  final int readingStreak;
  final int totalArticlesRead;
  final int bookmarkedArticles;
  final DateTime lastReadDate;
  final Map<String, int> readsByCategory;

  UserStats({
    required this.articlesReadToday,
    required this.readingStreak,
    required this.totalArticlesRead,
    required this.bookmarkedArticles,
    required this.lastReadDate,
    required this.readsByCategory,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      articlesReadToday: json['articlesReadToday'] ?? 0,
      readingStreak: json['readingStreak'] ?? 0,
      totalArticlesRead: json['totalArticlesRead'] ?? 0,
      bookmarkedArticles: json['bookmarkedArticles'] ?? 0,
      lastReadDate: json['lastReadDate'] != null 
          ? DateTime.parse(json['lastReadDate'])
          : DateTime.now(),
      readsByCategory: Map<String, int>.from(json['readsByCategory'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'articlesReadToday': articlesReadToday,
      'readingStreak': readingStreak,
      'totalArticlesRead': totalArticlesRead,
      'bookmarkedArticles': bookmarkedArticles,
      'lastReadDate': lastReadDate.toIso8601String(),
      'readsByCategory': readsByCategory,
    };
  }

  UserStats copyWith({
    int? articlesReadToday,
    int? readingStreak,
    int? totalArticlesRead,
    int? bookmarkedArticles,
    DateTime? lastReadDate,
    Map<String, int>? readsByCategory,
  }) {
    return UserStats(
      articlesReadToday: articlesReadToday ?? this.articlesReadToday,
      readingStreak: readingStreak ?? this.readingStreak,
      totalArticlesRead: totalArticlesRead ?? this.totalArticlesRead,
      bookmarkedArticles: bookmarkedArticles ?? this.bookmarkedArticles,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      readsByCategory: readsByCategory ?? this.readsByCategory,
    );
  }

  // Estatísticas vazias para inicialização
  static UserStats empty() {
    return UserStats(
      articlesReadToday: 0,
      readingStreak: 0,
      totalArticlesRead: 0,
      bookmarkedArticles: 0,
      lastReadDate: DateTime.now(),
      readsByCategory: {},
    );
  }
}
