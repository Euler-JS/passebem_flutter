// lib/pages/all_most_read_news_page.dart
import 'package:flutter/material.dart';
import 'package:news_app/Model/news_model.dart';
import 'package:news_app/Model/api_news_model.dart';
import 'package:news_app/services/api_service.dart';
import 'package:news_app/news_detail.dart';

class AllMostReadNewsPage extends StatefulWidget {
  const AllMostReadNewsPage({super.key});

  @override
  State<AllMostReadNewsPage> createState() => _AllMostReadNewsPageState();
}

class _AllMostReadNewsPageState extends State<AllMostReadNewsPage> {
  List<ApiNewsModel> mostReadNews = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMostReadNews();
  }

  Future<void> _loadMostReadNews() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      
      final news = await ApiService.getMostReadNews();
      setState(() {
        mostReadNews = news;
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
              'Mais Lidas',
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
                Icons.trending_up,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Notícias em Alta',
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
            'As notícias mais populares do momento',
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
                  Icons.visibility,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${mostReadNews.fold<int>(0, (sum, news) => sum + news.totalViews)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Visualizações',
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
                onPressed: _loadMostReadNews,
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

    if (mostReadNews.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.trending_up,
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
            final news = mostReadNews[index];
            return _buildRankedNewsCard(news, index + 1);
          },
          childCount: mostReadNews.length,
        ),
      ),
    );
  }

  Widget _buildRankedNewsCard(ApiNewsModel news, int ranking) {
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
        constraints: const BoxConstraints(minHeight: 120),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Ranking badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: ranking <= 3 
                      ? LinearGradient(
                          colors: ranking == 1 
                              ? [Colors.amber, Colors.orange]
                              : ranking == 2 
                                  ? [Colors.grey, Colors.grey.shade400]
                                  : [Colors.brown, Colors.brown.shade400],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFC7A87B), Color(0xFF8B5E3C)],
                        ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: ranking <= 3 
                      ? Icon(
                          ranking == 1 ? Icons.emoji_events : Icons.star,
                          color: Colors.white,
                          size: 22,
                        )
                      : Text(
                          "$ranking",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Imagem
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    news.getImageUrl(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[600],
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Conteúdo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título e badge premium
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            news.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (news.isPremiumContent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC7A87B),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Premium',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: news.getCategoryColor().withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              news.newsCategories,
                              style: TextStyle(
                                color: news.getCategoryColor(),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.visibility,
                                size: 14,
                                color: const Color(0xFF333333).withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  _formatViews(news.totalViews),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF333333).withOpacity(0.6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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
        ),
      ),
    );
  }
}