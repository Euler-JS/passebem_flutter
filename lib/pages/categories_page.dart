import 'package:flutter/material.dart';
import 'package:news_app/Model/news_model.dart';
import 'package:news_app/Model/api_news_model.dart';
import 'package:news_app/services/api_service.dart';
import 'package:news_app/news_detail.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String selectedCategory = "All";
  String selectedCategoryId = "0";
  
  // Dados da API
  List<CategoryModel> apiCategories = [];
  List<ApiNewsModel> filteredNews = [];
  bool isLoadingCategories = true;
  bool isLoadingNews = true;
  String? errorMessage;

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

  // Mapa de ícones para as categorias (baseado no JSON fornecido)
  final Map<String, IconData> categoryIcons = {
    "PESQUISAS": Icons.search,
    "A TSEVELE": Icons.article,
    "GALERIA": Icons.photo_library,
    "Nossas Áreas": Icons.domain,
    "Videos": Icons.video_library,
    "Canto e dança tradicionais": Icons.music_note,
    "Contos": Icons.book,
    "Gastronomia": Icons.restaurant,
    "Genérico": Icons.category,
    "Instrumentos musicais": Icons.piano,
    "Lugares históricos": Icons.location_city,
    "Medicina e beleza": Icons.local_hospital,
    "Monumentos": Icons.account_balance,
    "Utensílios": Icons.build,
    "Galeria": Icons.photo,
  };

  // Cores para as categorias
  final List<Color> categoryColors = [
    Color(0xFF3180FF),
    Color(0xFFFB3C5F),
    Color(0xFF57CBFF),
    Color(0xFFFF7A23),
    Color(0xFF8349DF),
    Color(0xFF00BCD4),
    Color(0xFF4CAF50),
    Color(0xFF9C27B0),
    Color(0xFFFF5722),
    Color(0xFF607D8B),
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadAllNews();
  }

  // Carregar categorias da API
  Future<void> _loadCategories() async {
    try {
      setState(() {
        isLoadingCategories = true;
        errorMessage = null;
      });
      
      final categories = await ApiService.getCategories();
      setState(() {
        apiCategories = categories;
        isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        isLoadingCategories = false;
        errorMessage = e.toString();
      });
      print('Erro ao carregar categorias: $e');
    }
  }

  // Carregar todas as notícias
  Future<void> _loadAllNews() async {
    try {
      setState(() {
        isLoadingNews = true;
        errorMessage = null;
      });
      
      final newsList = await ApiService.getAllNewsSimple(page: 1, perPage: 50);
      
      setState(() {
        filteredNews = newsList;
        isLoadingNews = false;
      });
    } catch (e) {
      setState(() {
        isLoadingNews = false;
        errorMessage = e.toString();
      });
      print('Erro ao carregar notícias: $e');
    }
  }

  // Filtrar notícias por categoria
  void _filterNews() {
    if (selectedCategoryId == 0) {
      // "All" - mostrar todas as notícias
      _loadAllNews();
    } else {
      // Filtrar por categoria específica
      _loadNewsByCategory(selectedCategoryId);
    }
  }

  // Carregar notícias por categoria específica
  Future<void> _loadNewsByCategory(String categoryId) async {
    try {
      setState(() {
        isLoadingNews = true;
        errorMessage = null;
      });
      
      final news = await ApiService.getNewsByCategory(int.parse(categoryId));
      setState(() {
        filteredNews = news;
        isLoadingNews = false;
      });
    } catch (e) {
      setState(() {
        isLoadingNews = false;
        errorMessage = e.toString();
      });
      print('Erro ao carregar notícias por categoria: $e');
    }
  }

  // Obter ícone para categoria
  IconData _getCategoryIcon(String categoryName) {
    return categoryIcons[categoryName] ?? Icons.category;
  }

  // Obter cor para categoria
  Color _getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }

  // Contar notícias por categoria
  int _getNewsCountForCategory(int categoryId) {
    if (categoryId == 0) return filteredNews.length;
    return filteredNews.where((news) => news.category?.id == categoryId).length;
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFFFFFFF),
    body: CustomScrollView(
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
            'Categorias',
            style: TextStyle(
              color: Color(0xFF333333),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.search, color: Color(0xFFC7A87B)),
          //     onPressed: _showSearchDialog,
          //   ),
          //   IconButton(
          //     icon: const Icon(Icons.filter_list, color: Color(0xFFC7A87B)),
          //     onPressed: _showFilterDialog,
          //   ),
          // ],
        ),

        // Header com estatísticas
        SliverToBoxAdapter(child: buildStatsHeader()),

        // Seletor de categorias (fixo)
        SliverAppBar(
          backgroundColor: Colors.white,
          elevation: 4,
          automaticallyImplyLeading: false,
          floating: false,
          pinned: true,
          snap: false,
          toolbarHeight: 120,
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: buildCategorySelector(),
          ),
        ),

        // Lista de notícias
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: buildSliverNewsList(),
        ),
      ],
    ),
  );
}

Widget buildSliverNewsList() {
  if (isLoadingNews) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator(color: Color(0xFFC7A87B))),
      ),
    );
  }

  if (errorMessage != null) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: const Color(0xFF333333).withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('Erro ao carregar notícias', style: TextStyle(fontSize: 18, color: const Color(0xFF333333).withOpacity(0.7))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _filterNews,
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFC7A87B)),
                child: Text('Tentar novamente', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  if (filteredNews.isEmpty) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.article_outlined, size: 64, color: const Color(0xFF333333).withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('Nenhuma notícia encontrada', style: TextStyle(fontSize: 18, color: const Color(0xFF333333).withOpacity(0.7))),
            ],
          ),
        ),
      ),
    );
  }

  return SliverList(
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        final news = filteredNews[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: buildNewsCard(news, index),
        );
      },
      childCount: filteredNews.length,
    ),
  );
}

  Widget buildStatsHeader() {
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
                Icons.category,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Explore por Categoria',
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
            'Encontre as notícias que mais interessam você',
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
                "${filteredNews.length}",
                "Notícias",
                Icons.article,
              ),
              _buildStatChip(
                "${apiCategories.length}",
                "Categorias",
                Icons.category,
              ),
              _buildStatChip(
                "${filteredNews.where((n) => n.isPremiumContent).length}",
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

  Widget buildCategorySelector() {
    if (isLoadingCategories) {
      return SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFC7A87B),
          ),
        ),
      );
    }

    // Criar lista com "All" + categorias da API
    final allCategories = [
      {'id': 0, 'name': 'Todas', 'isAll': true},
      ...apiCategories.map((cat) => {
        'id': cat.id,
        'name': cat.name,
        'isAll': false,
      }),
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final categoryId = category['id'] as String;
          final categoryName = category['name'] as String;
          final isAll = category['isAll'] as bool;
          bool isSelected = selectedCategoryId == categoryId;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = categoryName;
                selectedCategoryId = categoryId.toString();
              });
              _filterNews();
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFFC7A87B) 
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected 
                      ? const Color(0xFFC7A87B) 
                      : const Color(0xFFC7A87B).withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                        ? const Color(0xFFC7A87B).withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAll ? Icons.all_inclusive : _getCategoryIcon(categoryName),
                    color: isSelected ? Colors.white : _getCategoryColor(index),
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAll ? categoryName : categoryName.length > 8 
                        ? categoryName.substring(0, 8) + '...'
                        : categoryName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF333333),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // const SizedBox(height: 4),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  //   decoration: BoxDecoration(
                  //     color: isSelected 
                  //         ? Colors.white.withOpacity(0.2)
                  //         : _getCategoryColor(index).withOpacity(0.1),
                  //     borderRadius: BorderRadius.circular(10),
                  //   ),
                  //   // child: Text(
                  //   //   '${_getNewsCountForCategory(categoryId)}',
                  //   //   style: TextStyle(
                  //   //     color: isSelected ? Colors.white : _getCategoryColor(index),
                  //   //     fontSize: 10,
                  //   //     fontWeight: FontWeight.bold,
                  //   //   ),
                  //   // ),
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildNewsList() {
    if (isLoadingNews) {
      return Center(
        child: CircularProgressIndicator(
          color: Color(0xFFC7A87B),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
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
            const SizedBox(height: 8),
            Text(
              'Toque para tentar novamente',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF333333).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _filterNews,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC7A87B),
              ),
              child: Text('Tentar novamente', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (filteredNews.isEmpty) {
      return Center(
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
            const SizedBox(height: 8),
            Text(
              'Tente selecionar uma categoria diferente',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF333333).withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredNews.length,
      itemBuilder: (context, index) {
        final news = filteredNews[index];
        return buildNewsCard(news, index);
      },
    );
  }

  Widget buildNewsCard(ApiNewsModel news, int index) {
    return GestureDetector(
      onTap: () {
        // Incrementar visualizações
        ApiService.incrementViews(news.id);
        
        // Navegar para detalhes (você pode precisar adaptar dependendo do DetailNews)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailNews(news: _convertToYournews(news)),
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
            // Imagem com badges
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
                  child: news.previewImagePath != null && news.previewImage != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Image.network(
                            'https://tsevelenews.tsevele.co.mz/uploads/${news.previewImagePath}/${news.previewImage}',
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
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey[600],
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
                
                // Categoria badge
                if (news.category != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(index).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        news.category!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                
                // Premium badge
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
                  // Título
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
                  
                  // Descrição
                  Text(
                    news.description.replaceAll(RegExp(r'<[^>]*>'), ''), // Remove HTML tags
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF333333).withOpacity(0.7),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Footer
                  Row(
                    children: [
                      // Views
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
                        ],
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Tempo
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: const Color(0xFF333333).withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(news.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF333333).withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Audio/Video badges
                      if (news.isAudio)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC7A87B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
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
                          child: Icon(
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

  // Método para formatar data
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Hoje';
    } else if (difference == 1) {
      return 'Ontem';
    } else if (difference < 7) {
      return '${difference}d atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Converter ApiNewsModel para Yournews (para compatibilidade com DetailNews)
  Yournews _convertToYournews(ApiNewsModel apiNews) {
    return Yournews(
      image: apiNews.previewImagePath != null && apiNews.previewImage != null
          ? 'https://tsevelenews.tsevele.co.mz/uploads/${apiNews.previewImagePath}/${apiNews.previewImage}'
          : 'assets/images/default.jpg',
      newsImage: apiNews.previewImagePath != null && apiNews.previewImage != null
          ? 'https://tsevelenews.tsevele.co.mz/uploads/${apiNews.previewImagePath}/${apiNews.previewImage}'
          : 'assets/images/default.jpg',
      newsTitle: apiNews.title,
      newsCategories: apiNews.category?.name ?? 'Geral',
      description: apiNews.description.replaceAll(RegExp(r'<[^>]*>'), ''),
      fullContent: apiNews.description.replaceAll(RegExp(r'<[^>]*>'), ''),
      time: _formatDate(apiNews.createdAt),
      date: '${apiNews.createdAt.day}/${apiNews.createdAt.month}/${apiNews.createdAt.year}',
      views: apiNews.totalViews,
      isPremium: apiNews.isPremiumContent,
      color: _getCategoryColor(0),
      isBookmarked: false,
      isFeatured: false,
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Notícias'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Digite sua busca...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            // TODO: Implementar busca
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Apenas Premium'),
              value: false,
              onChanged: (value) {
                // TODO: Implementar filtro premium
              },
            ),
            CheckboxListTile(
              title: const Text('Mais Recentes'),
              value: true,
              onChanged: (value) {
                // TODO: Implementar filtro por data
              },
            ),
            CheckboxListTile(
              title: const Text('Mais Visualizadas'),
              value: false,
              onChanged: (value) {
                // TODO: Implementar filtro por visualizações
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }
}