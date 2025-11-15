// lib/pages/podcast_category_page.dart
import 'package:flutter/material.dart';
import '../Model/podcast_model.dart';
import '../services/podcast_service.dart';
import 'podcast_detail_page.dart';

class PodcastCategoryPage extends StatefulWidget {
  final PodcastCategory category;

  const PodcastCategoryPage({
    super.key,
    required this.category,
  });

  @override
  State<PodcastCategoryPage> createState() => _PodcastCategoryPageState();
}

class _PodcastCategoryPageState extends State<PodcastCategoryPage> {
  List<PodcastModel> _podcasts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPodcasts(isRefresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPodcasts({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _hasMoreData = true;
      });
    }

    final response = await PodcastService.getPodcastsByCategory(
      widget.category.id,
      page: _currentPage,
    );

    if (response != null && response.isSuccess) {
      setState(() {
        if (isRefresh) {
          _podcasts = response.data;
        } else {
          _podcasts.addAll(response.data);
        }
        _hasMoreData = response.pagination.hasNextPage;
        _currentPage++;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMorePodcasts();
      }
    }
  }

  Future<void> _loadMorePodcasts() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _loadPodcasts();

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _refresh() async {
    await _loadPodcasts(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFC7A87B),
              Color(0xFF8B5E3C),
              Color(0xFFC7A87B),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildCategoryInfo(),
              Expanded(
                child: _buildPodcastList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Categoria',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.category,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFC7A87B).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.category,
              color: Color(0xFFC7A87B),
              size: 32,
            ),
          ),
          
          const SizedBox(width: 20),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  widget.category.description ?? 'Explore os podcasts desta categoria',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(
                      Icons.podcasts,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.category.totalPodcasts ?? 0} podcasts',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodcastList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_podcasts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        itemCount: _podcasts.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _podcasts.length) {
            return _buildLoadingIndicator();
          }

          final podcast = _podcasts[index];
          return _buildPodcastCard(podcast);
        },
      ),
    );
  }

  Widget _buildPodcastCard(PodcastModel podcast) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToPodcastDetail(podcast),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Imagem do podcast
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: podcast.previewImageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(podcast.previewImageUrl),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              // Handle image loading error
                            },
                          )
                        : null,
                  ),
                  child: podcast.previewImageUrl.isEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFC7A87B).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.podcasts,
                            color: Color(0xFFC7A87B),
                            size: 40,
                          ),
                        )
                      : null,
                ),
                
                const SizedBox(width: 16),
                
                // Informações do podcast
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        podcast.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        podcast.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Icon(
                            Icons.remove_red_eye,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${podcast.totalViews}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          if (podcast.isPremiumContent) ...[
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Color(0xFFC7A87B),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Premium',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFC7A87B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          
                          const Spacer(),
                          
                          Icon(
                            podcast.canPlayFull ? Icons.play_circle_fill : Icons.play_circle_outline,
                            color: const Color(0xFFC7A87B),
                            size: 24,
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

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.podcasts,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              'Nenhum podcast encontrado',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Esta categoria ainda não possui podcasts disponíveis.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  void _navigateToPodcastDetail(PodcastModel podcast) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PodcastDetailPage(podcast: podcast),
      ),
    );
  }
}
