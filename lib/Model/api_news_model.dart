// lib/models/api_news_model.dart
import 'package:flutter/material.dart';

class ApiNewsModel {
  final int id;
  final int userId;
  final int categoryId;
  final String title;
  final String description;
  final String? previewImage;
  final String? previewImagePath;
  final int totalViews;
  final int totalComments;
  final bool isVideo;
  final bool isAudio;
  final String? audioType;
  final String? audioLink;
  final String? audioFile;
  final String? audioFilePath;
  final String? audioSampleLink;
  final String? audioSampleFile;
  final String? audioSampleFilePath;
  final bool isRestricted;
  final String? link;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CategoryModel? category;
  final bool isPremiumContent;
  final String? premiumMessage;
  
  // Propriedades locais para UI
  bool isBookmarked;
  bool isFeatured;

  ApiNewsModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.description,
    this.previewImage,
    this.previewImagePath,
    required this.totalViews,
    required this.totalComments,
    required this.isVideo,
    required this.isAudio,
    this.audioType,
    this.audioLink,
    this.audioFile,
    this.audioFilePath,
    this.audioSampleLink,
    this.audioSampleFile,
    this.audioSampleFilePath,
    required this.isRestricted,
    this.link,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    required this.isPremiumContent,
    this.premiumMessage,
    this.isBookmarked = false,
    this.isFeatured = false,
  });

  factory ApiNewsModel.fromJson(Map<String, dynamic> json) {
    return ApiNewsModel(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      title: json['title'],
      description: json['description'],
      previewImage: json['preview_image'],
      previewImagePath: json['preview_image_path'],
      totalViews: json['total_views'],
      totalComments: json['total_comments'],
      isVideo: json['is_video'],
      isAudio: json['is_audio'],
      audioType: json['audio_type'],
      audioLink: json['audio_link'],
      audioFile: json['audio_file'],
      audioFilePath: json['audio_file_path'],
      audioSampleLink: json['audio_sample_link'],
      audioSampleFile: json['audio_sample_file'],
      audioSampleFilePath: json['audio_sample_file_path'],
      isRestricted: json['is_restricted'],
      link: json['link'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      category: json['get_category'] != null 
          ? CategoryModel.fromJson(json['get_category']) 
          : null,
      isPremiumContent: json['is_premium_content'] ?? false,
      premiumMessage: json['premium_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'preview_image': previewImage,
      'preview_image_path': previewImagePath,
      'total_views': totalViews,
      'total_comments': totalComments,
      'is_video': isVideo,
      'is_audio': isAudio,
      'audio_type': audioType,
      'audio_link': audioLink,
      'audio_file': audioFile,
      'audio_file_path': audioFilePath,
      'audio_sample_link': audioSampleLink,
      'audio_sample_file': audioSampleFile,
      'audio_sample_file_path': audioSampleFilePath,
      'is_restricted': isRestricted,
      'link': link,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'get_category': category?.toJson(),
      'is_premium_content': isPremiumContent,
      'premium_message': premiumMessage,
    };
  }

  // Getters para manter compatibilidade com o código existente
  String get newsTitle => title;
  String get newsImage => getImageUrl();
  String get newsCategories => category?.name ?? 'Sem categoria';
  int get views => totalViews;
  bool get isPremium => isPremiumContent;
  String get time => getTimeAgo();
  String get date => formatDate();
  Color get color => getCategoryColor();
  String get fullContent => description; // Para casos simples, usar description
  
  // URL completa da imagem
  String getImageUrl() {
    if (previewImage == null || previewImagePath == null) {
      return 'assets/images/placeholder.jpg'; // Imagem padrão
    }
    return 'https://tsevelenews.tsevele.co.mz/assets/images/blog_magazine/$previewImagePath/$previewImage';
  }
  
  // Calcular tempo decorrido
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'agora';
    }
  }
  
  // Formatar data
  String formatDate() {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
  
  // Cor da categoria (baseada no nome)
  Color getCategoryColor() {
    if (category == null) return const Color(0xFF333333);
    
    switch (category!.name.toLowerCase()) {
      case 'contos':
        return const Color(0xFFC7A87B);
      case 'medicina e beleza':
        return const Color(0xFF8B5E3C);
      case 'genérico':
        return const Color(0xFF333333);
      case 'tecnologia':
        return const Color(0xFF3180FF);
      case 'política':
        return const Color(0xFFFB3C5F);
      case 'economia':
        return const Color(0xFF57CBFF);
      case 'desporto':
        return const Color(0xFFFF7A23);
      case 'cultura':
        return const Color(0xFF8349DF);
      default:
        return const Color(0xFF666666);
    }
  }
}

class CategoryModel {
  final String id;
  final String name;

  CategoryModel({
    required this.id,
    required this.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '0',
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// Helper para gerenciar notícias da API
class ApiNewsHelper {
  static List<ApiNewsModel> _bookmarkedNews = [];
  
  // Obter notícias salvas
  static List<ApiNewsModel> getBookmarkedNews() {
    return _bookmarkedNews;
  }
  
  // Alternar bookmark
  static void toggleBookmark(ApiNewsModel news) {
    if (_bookmarkedNews.contains(news)) {
      _bookmarkedNews.remove(news);
      news.isBookmarked = false;
    } else {
      _bookmarkedNews.add(news);
      news.isBookmarked = true;
    }
  }
  
  // Verificar se está salva
  static bool isBookmarked(ApiNewsModel news) {
    return _bookmarkedNews.contains(news);
  }
  
  // Limpar bookmarks
  static void clearBookmarks() {
    for (var news in _bookmarkedNews) {
      news.isBookmarked = false;
    }
    _bookmarkedNews.clear();
  }
}

// Modelo para paginação
class PaginationModel {
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  PaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      total: json['total'],
      perPage: json['per_page'],
    );
  }

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
}