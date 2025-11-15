// lib/pages/all_recent_news_page.dart
import 'package:flutter/material.dart';
import 'package:news_app/Model/news_model.dart';
import 'package:news_app/Model/api_news_model.dart';
import 'package:news_app/services/api_service.dart';
import 'package:news_app/news_detail.dart';

class AllRecentNewsPage extends StatefulWidget {
  const AllRecentNewsPage({super.key});

  @override
  State<AllRecentNewsPage> createState() => _AllRecentNewsPageState();
}

class _AllRecentNewsPageState extends State<AllRecentNewsPage> {
  List<ApiNewsModel> recentNews = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecentNews();
  }

  Future<void> _loadRecentNews() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      
      final news = await ApiService.getRecentNews();
      setState(() {
        recentNews = news;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  String _formatViews(int views) {
    if (views >= 1000000) {
      double millions = views / 1000000;
      return '${millions.toStringAsFixed(millions.truncateToDouble() == millions ? 0 : 1)}M';
    } else if (views >= 1000) {
      double thousands = views / 1000;
      return '${thousands.toStringAsFixed(thousands.truncateToDouble() == thousands ? 0 : 1)}k';
    } else {
      return views.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            backgroundColor: Colors.white,
            toolbarHeight: 100,
            elevation: 0,
            automaticallyImplyLeading: false,
            floating: false,
            pinned: false,
            snap: false,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF333333),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Notícias Recentes',
              style: TextStyle(
                color: Color(0xFF333333),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),

          // Header com estatísticas
          SliverToBoxAdapter(
            child: _buildStatsHeader(),
          ),

          // Lista de notícias
          _buildNewsList(),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFC7A87B),
            Color(0xFF8B5E3C),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.schedule,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Últimas Publicações',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Acompanhe as notícias mais recentes',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.article,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${recentNews.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Notícias',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList() {
    if (isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFC7A87B)),
        ),
      );
    }

    if (errorMessage != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: const Color(0xFF333333).withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar notícias',
                style: TextStyle(
                  fontSize: 18,
                  color: const Color(0xFF333333).withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadRecentNews,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC7A87B),
                  elevation: 0,
                ),
                child: const Text(
                  'Tentar novamente',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (recentNews.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.article_outlined,
                size: 64,
                color: const Color(0xFF333333).withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhuma notícia encontrada',
                style: TextStyle(
                  fontSize: 18,
                  color: const Color(0xFF333333).withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final news = recentNews[index];
            return _buildNewsCard(news);
          },
          childCount: recentNews.length,
        ),
      ),
    );
  }

  Widget _buildNewsCard(ApiNewsModel news) {
    return GestureDetector(
      onTap: () {
        ApiService.incrementViews(news.id);
        
        final convertedNews = Yournews(
          image: news.getImageUrl(),
          newsImage: news.getImageUrl(),
          newsTitle: news.title,
          newsCategories: news.newsCategories,
          time: news.getTimeAgo(),
          date: news.formatDate(),
          color: news.getCategoryColor(),
          description: news.description,
          fullContent: news.description,
          isPremium: news.isPremiumContent,
          views: news.totalViews,
          isBookmarked: news.isBookmarked,
          isFeatured: news.isFeatured,
        );
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailNews(news: convertedNews),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFC7A87B).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    color: Colors.grey[300],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.network(
                      news.getImageUrl(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Gradient overlay
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
                
                // Badges
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: news.getCategoryColor(),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      news.newsCategories,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                if (news.isPremiumContent)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC7A87B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            color: Colors.white,
                            size: 10,
                          ),
                          SizedBox(width: 2),
                          Text(
                            'Premium',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    news.description.replaceAll(RegExp(r'<[^>]*>'), ''),
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF333333).withOpacity(0.7),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 14,
                        color: const Color(0xFF333333).withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatViews(news.totalViews),
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF333333).withOpacity(0.6),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: const Color(0xFF333333).withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        news.getTimeAgo(),
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF333333).withOpacity(0.6),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      if (news.isAudio)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC7A87B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.audiotrack,
                            color: Color(0xFFC7A87B),
                            size: 12,
                          ),
                        ),
                      
                      if (news.isVideo)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC7A87B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Color(0xFFC7A87B),
                            size: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}