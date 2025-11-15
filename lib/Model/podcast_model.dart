// lib/Model/podcast_model.dart

class PodcastModel {
  final int id;
  final int userId;
  final int categoryId;
  final String title;
  final String description;
  final String previewImage;
  final String previewImagePath;
  final int totalViews;
  final int totalComments;
  final bool? isVideo;
  final bool isAudio;
  final String audioType;
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
  final PodcastUser? getUser;
  final PodcastCategory getCategory;
  final List<PodcastTag> tags;
  final bool isLoggedIn;
  final bool userHasSubscription;
  final bool isPremiumContent;
  final String? premiumMessage;
  final String? audioUrl;
  final bool hasFullAudio;
  final String? audioSampleUrl;
  final bool hasAudioSample;
  final String accessType;
  final String? duration;
  final String previewImageUrl;

  PodcastModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.previewImage,
    required this.previewImagePath,
    required this.totalViews,
    required this.totalComments,
    this.isVideo,
    required this.isAudio,
    required this.audioType,
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
    this.getUser,
    required this.getCategory,
    required this.tags,
    required this.isLoggedIn,
    required this.userHasSubscription,
    required this.isPremiumContent,
    this.premiumMessage,
    this.audioUrl,
    required this.hasFullAudio,
    this.audioSampleUrl,
    required this.hasAudioSample,
    required this.accessType,
    this.duration,
    required this.previewImageUrl,
  });

  factory PodcastModel.fromJson(Map<String, dynamic> json) {
    return PodcastModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      previewImage: json['preview_image'] ?? '',
      previewImagePath: json['preview_image_path'] ?? '',
      totalViews: json['total_views'] ?? 0,
      totalComments: json['total_comments'] ?? 0,
      isVideo: json['is_video'],
      isAudio: json['is_audio'] ?? false,
      audioType: json['audio_type'] ?? '',
      audioLink: json['audio_link'],
      audioFile: json['audio_file'],
      audioFilePath: json['audio_file_path'],
      audioSampleLink: json['audio_sample_link'],
      audioSampleFile: json['audio_sample_file'],
      audioSampleFilePath: json['audio_sample_file_path'],
      isRestricted: json['is_restricted'] ?? false,
      link: json['link'],
      status: json['status'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      getUser: json['get_user'] != null ? PodcastUser.fromJson(json['get_user']) : null,
      getCategory: PodcastCategory.fromJson(json['get_category'] ?? {}),
      tags: (json['tags'] as List<dynamic>?)
          ?.map((tag) => PodcastTag.fromJson(tag))
          .toList() ?? [],
      isLoggedIn: json['is_logged_in'] ?? false,
      userHasSubscription: json['user_has_subscription'] ?? false,
      isPremiumContent: json['is_premium_content'] ?? false,
      premiumMessage: json['premium_message'],
      audioUrl: json['audio_url'],
      hasFullAudio: json['has_full_audio'] ?? false,
      audioSampleUrl: json['audio_sample_url'],
      hasAudioSample: json['has_audio_sample'] ?? false,
      accessType: json['access_type'] ?? '',
      duration: json['duration'],
      previewImageUrl: json['preview_image_url'] ?? '',
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
      'get_user': getUser?.toJson(),
      'get_category': getCategory.toJson(),
      'tags': tags.map((tag) => tag.toJson()).toList(),
      'is_logged_in': isLoggedIn,
      'user_has_subscription': userHasSubscription,
      'is_premium_content': isPremiumContent,
      'premium_message': premiumMessage,
      'audio_url': audioUrl,
      'has_full_audio': hasFullAudio,
      'audio_sample_url': audioSampleUrl,
      'has_audio_sample': hasAudioSample,
      'access_type': accessType,
      'duration': duration,
      'preview_image_url': previewImageUrl,
    };
  }

  bool get canPlayFull => hasFullAudio && (audioUrl != null || audioLink != null);
  bool get canPlaySample => hasAudioSample && audioSampleUrl != null;
  bool get requiresSubscription => isPremiumContent && !userHasSubscription;
}

class PodcastUser {
  final int id;
  final String name;
  final String? avatar;

  PodcastUser({
    required this.id,
    required this.name,
    this.avatar,
  });

  factory PodcastUser.fromJson(Map<String, dynamic> json) {
    return PodcastUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
    };
  }
}

class PodcastCategory {
  final int id;
  final String name;
  final String? slug;
  final String? description;
  final int? totalPodcasts;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  PodcastCategory({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.totalPodcasts,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PodcastCategory.fromJson(Map<String, dynamic> json) {
    return PodcastCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'],
      description: json['description'],
      totalPodcasts: json['total_podcasts'],
      status: json['status'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'total_podcasts': totalPodcasts,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class PodcastTag {
  final int id;
  final String name;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PodcastTagPivot? pivot;

  PodcastTag({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.pivot,
  });

  factory PodcastTag.fromJson(Map<String, dynamic> json) {
    return PodcastTag(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      pivot: json['pivot'] != null ? PodcastTagPivot.fromJson(json['pivot']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'pivot': pivot?.toJson(),
    };
  }
}

class PodcastTagPivot {
  final int postId;
  final int tagId;

  PodcastTagPivot({
    required this.postId,
    required this.tagId,
  });

  factory PodcastTagPivot.fromJson(Map<String, dynamic> json) {
    return PodcastTagPivot(
      postId: json['post_id'] ?? 0,
      tagId: json['tag_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'tag_id': tagId,
    };
  }
}

class PodcastResponse {
  final String status;
  final List<PodcastModel> data;
  final PaginationInfo pagination;
  final String message;
  final PodcastCategory? category; // Para resposta por categoria

  PodcastResponse({
    required this.status,
    required this.data,
    required this.pagination,
    required this.message,
    this.category,
  });

  factory PodcastResponse.fromJson(Map<String, dynamic> json) {
    return PodcastResponse(
      status: json['status'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((podcast) => PodcastModel.fromJson(podcast))
          .toList() ?? [],
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
      message: json['message'] ?? '',
      category: json['category'] != null 
          ? PodcastCategory.fromJson(json['category'])
          : null,
    );
  }

  bool get isSuccess => status == 'success';
}

class PodcastCategoryResponse {
  final String status;
  final List<PodcastCategory> data;
  final PaginationInfo pagination;
  final String message;

  PodcastCategoryResponse({
    required this.status,
    required this.data,
    required this.pagination,
    required this.message,
  });

  factory PodcastCategoryResponse.fromJson(Map<String, dynamic> json) {
    return PodcastCategoryResponse(
      status: json['status'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((category) => PodcastCategory.fromJson(category))
          .toList() ?? [],
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
      message: json['message'] ?? '',
    );
  }

  bool get isSuccess => status == 'success';
}

class PaginationInfo {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginationInfo({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
    };
  }

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
}
