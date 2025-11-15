// lib/pages/podcast_page.dart
import 'package:flutter/material.dart';
import '../Model/podcast_model.dart';
import '../services/podcast_service.dart';
import 'podcast_detail_page.dart';
import 'podcast_category_page.dart';

class PodcastPage extends StatefulWidget {
  const PodcastPage({super.key});

  @override
  State<PodcastPage> createState() => _PodcastPageState();
}

class _PodcastPageState extends State<PodcastPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<PodcastModel> _podcasts = [];
  List<PodcastCategory> _categories = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Função para abreviar números grandes
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
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMoreData = true;
    });

    await Future.wait([
      _loadPodcasts(isRefresh: true),
      _loadCategories(),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadPodcasts({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMoreData = true;
    }

    final response = _searchQuery.isEmpty
        ? await PodcastService.getAllPodcasts(page: _currentPage)
        : await PodcastService.searchPodcasts(_searchQuery, page: _currentPage);

    if (response != null && response.isSuccess) {
      setState(() {
        if (isRefresh) {
          _podcasts = response.data;
        } else {
          _podcasts.addAll(response.data);
        }
        _hasMoreData = response.pagination.hasNextPage;
        _currentPage++;
      });
    }
  }

  Future<void> _loadCategories() async {
    final response = await PodcastService.getCategories();
    if (response != null && response.isSuccess) {
      setState(() {
        _categories = response.data;
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

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadPodcasts(isRefresh: true);
  }

  Future<void> _refresh() async {
    await _loadInitialData();
  }

  int get _totalPremiumPodcasts {
    return _podcasts.where((p) => p.isPremiumContent).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // AppBar principal
          SliverAppBar(
            backgroundColor: Colors.white,
            toolbarHeight: 100,
            elevation: 0,
            automaticallyImplyLeading: false,
            floating: false,
            pinned: false,
            snap: false,
            title: const Text(
              'Podcasts',
              style: TextStyle(
                color: Color(0xFF333333),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: Color(0xFFC7A87B),
                ),
                onPressed: _loadInitialData,
                tooltip: 'Atualizar',
              ),
            ],
          ),

          // Header com estatísticas
          SliverToBoxAdapter(
            child: _buildStatsHeader(),
          ),

          // Campo de busca
          // SliverToBoxAdapter(
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 20),
          //     child: _buildSearchBar(),
          //   ),
          // ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 12),
          ),

          // TabBar fixo
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 4,
            automaticallyImplyLeading: false,
            floating: false,
            pinned: true,
            snap: false,
            toolbarHeight: 4,
            flexibleSpace: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: _buildTabBar(),
            ),
          ),

          // Conteúdo das tabs
          _buildTabContent(),
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
                Icons.podcasts,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Descubra Podcasts',
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
            'Explore podcasts incríveis sobre diversos temas',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Estatísticas rápidas
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _buildStatChip(
                "${_podcasts.length}",
                "Podcasts",
                Icons.podcasts,
              ),
              _buildStatChip(
                "${_categories.length}",
                "Categorias",
                Icons.category,
              ),
              _buildStatChip(
                "$_totalPremiumPodcasts",
                "Premium",
                Icons.workspace_premium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Buscar podcasts...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Color(0xFFC7A87B)),
        ),
        onSubmitted: _performSearch,
        onChanged: (value) {
          if (value.isEmpty) {
            _performSearch('');
          }
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: const Color(0xFFC7A87B),
        unselectedLabelColor: const Color(0xFF718096),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'Todos'),
          Tab(text: 'Categorias'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPodcastsTab(),
          _buildCategoriesTab(),
        ],
      ),
    );
  }

  Widget _buildPodcastsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFC7A87B)),
      );
    }

    if (_podcasts.isEmpty) {
      return _buildEmptyState('Nenhum podcast encontrado');
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
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

  Widget _buildCategoriesTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFC7A87B)),
      );
    }

    if (_categories.isEmpty) {
      return _buildEmptyState('Nenhuma categoria encontrada');
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _buildCategoryCard(category);
        },
      ),
    );
  }

  Widget _buildPodcastCard(PodcastModel podcast) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToPodcastDetail(podcast),
          borderRadius: BorderRadius.circular(16),
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
                            onError: (exception, stackTrace) {},
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
                          color: Color(0xFF333333),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        podcast.getCategory.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFC7A87B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Text(
                      //   podcast.description,
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     color: const Color(0xFF333333).withOpacity(0.7),
                      //   ),
                      //   maxLines: 2,
                      //   overflow: TextOverflow.ellipsis,
                      // ),
                      
                      // const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Icon(
                            Icons.visibility,
                            size: 14,
                            color: const Color(0xFF333333).withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatViews(podcast.totalViews),
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF333333).withOpacity(0.6),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          if (podcast.isPremiumContent) ...[
                            const Icon(
                              Icons.workspace_premium,
                              size: 14,
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

  Widget _buildCategoryCard(PodcastCategory category) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToCategoryPodcasts(category),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        '${category.totalPodcasts ?? 0} podcasts',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF333333).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Icon(
                  Icons.arrow_forward_ios,
                  color: const Color(0xFF333333).withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.podcasts,
              size: 80,
              color: const Color(0xFF333333).withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: const Color(0xFF333333).withOpacity(0.7),
                fontWeight: FontWeight.w600,
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
        child: CircularProgressIndicator(color: Color(0xFFC7A87B)),
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

  void _navigateToCategoryPodcasts(PodcastCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PodcastCategoryPage(category: category),
      ),
    );
  }
}