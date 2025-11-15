import 'package:flutter/material.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  String selectedCategory = "Todos";
  String selectedFilter = "Recentes";

  // Dados simulados de vídeos
  final List<Map<String, dynamic>> videos = [
    {
      'id': '1',
      'title': 'Resumo das Notícias - 15 de Março',
      'description': 'Principais acontecimentos do dia em Moçambique',
      'duration': '8:45',
      'views': 15420,
      'category': 'Notícias',
      'thumbnail': 'Images/video1.jpg',
      'date': '2024-03-15',
      'author': 'TVM Notícias',
      'isLive': false,
      'isPremium': false,
      'likes': 234,
    },
    {
      'id': '2',
      'title': 'Inovação Tecnológica em Maputo',
      'description': 'Documentário sobre startups moçambicanas',
      'duration': '25:30',
      'views': 8750,
      'category': 'Tecnologia',
      'thumbnail': 'Images/video2.jpg',
      'date': '2024-03-14',
      'author': 'Tech Moz',
      'isLive': false,
      'isPremium': true,
      'likes': 156,
    },
    {
      'id': '3',
      'title': 'TRANSMISSÃO AO VIVO - Assembleia da República',
      'description': 'Sessão parlamentar ao vivo',
      'duration': 'AO VIVO',
      'views': 3200,
      'category': 'Política',
      'thumbnail': 'Images/video3.jpg',
      'date': '2024-03-15',
      'author': 'Parlamento Moz',
      'isLive': true,
      'isPremium': false,
      'likes': 89,
    },
    {
      'id': '4',
      'title': 'Análise Económica - Mercados Financeiros',
      'description': 'Perspectivas da economia moçambicana',
      'duration': '15:20',
      'views': 5680,
      'category': 'Economia',
      'thumbnail': 'Images/video4.jpg',
      'date': '2024-03-13',
      'author': 'Economia Hoje',
      'isLive': false,
      'isPremium': true,
      'likes': 78,
    },
    {
      'id': '5',
      'title': 'Desporto Nacional - Resumo da Semana',
      'description': 'Melhores momentos do desporto moçambicano',
      'duration': '12:15',
      'views': 9340,
      'category': 'Desporto',
      'thumbnail': 'Images/video5.jpg',
      'date': '2024-03-12',
      'author': 'Desporto Moz',
      'isLive': false,
      'isPremium': false,
      'likes': 198,
    },
    {
      'id': '6',
      'title': 'Cultura e Tradições - Inhambane',
      'description': 'Explorando a rica cultura de Inhambane',
      'duration': '18:40',
      'views': 4560,
      'category': 'Cultura',
      'thumbnail': 'Images/video6.jpg',
      'date': '2024-03-11',
      'author': 'Cultura Viva',
      'isLive': false,
      'isPremium': false,
      'likes': 124,
    },
  ];

  final List<String> categories = [
    'Todos',
    'Notícias',
    'Tecnologia',
    'Política',
    'Economia',
    'Desporto',
    'Cultura',
  ];

  final List<String> filters = [
    'Recentes',
    'Mais Vistos',
    'Mais Curtidos',
    'Ao Vivo',
    'Premium',
  ];

  List<Map<String, dynamic>> get filteredVideos {
    var filtered = videos.where((video) {
      if (selectedCategory != "Todos" && video['category'] != selectedCategory) {
        return false;
      }
      
      switch (selectedFilter) {
        case 'Ao Vivo':
          return video['isLive'];
        case 'Premium':
          return video['isPremium'];
        default:
          return true;
      }
    }).toList();

    // Ordenar baseado no filtro
    switch (selectedFilter) {
      case 'Mais Vistos':
        filtered.sort((a, b) => b['views'].compareTo(a['views']));
        break;
      case 'Mais Curtidos':
        filtered.sort((a, b) => b['likes'].compareTo(a['likes']));
        break;
      default:
        filtered.sort((a, b) => b['date'].compareTo(a['date']));
    }

    return filtered;
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
            'Vídeos',
            style: TextStyle(
              color: Color(0xFF333333),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Color(0xFFC7A87B)),
              onPressed: _showSearchDialog,
            ),
            IconButton(
              icon: const Icon(Icons.video_library, color: Color(0xFFC7A87B)),
              onPressed: _showMyLibraryDialog,
            ),
          ],
        ),

        // Header com estatísticas
        SliverToBoxAdapter(child: buildHeader()),

        // Filtros fixos (categorias e filtros)
        SliverAppBar(
          backgroundColor: Colors.white,
          elevation: 4,
          automaticallyImplyLeading: false,
          floating: false,
          pinned: true,
          snap: false,
          toolbarHeight: 120,
          flexibleSpace: Padding(
            padding: const EdgeInsets.all(10),
            child: buildFilters(),
          ),
        ),

        // Lista de vídeos
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: buildSliverVideosList(),
        ),
      ],
    ),
  );
}

Widget buildSliverVideosList() {
  return SliverList(
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        final video = filteredVideos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: buildVideoCard(video),
        );
      },
      childCount: filteredVideos.length,
    ),
  );
}

  Widget buildHeader() {
    final liveCount = videos.where((v) => v['isLive']).length;
    final premiumCount = videos.where((v) => v['isPremium']).length;
    
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
                Icons.play_circle,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Vídeos Exclusivos',
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
            'Assista aos melhores vídeos e transmissões ao vivo',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Estatísticas
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildStatChip(
                "${filteredVideos.length}",
                "Vídeos",
                Icons.play_circle,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                "$liveCount",
                "Ao Vivo",
                Icons.live_tv,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                "$premiumCount",
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

  Widget buildFilters() {
    return Column(
      children: [
        // Categorias
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              String category = categories[index];
              bool isSelected = selectedCategory == category;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFFC7A87B) 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFFC7A87B) 
                          : const Color(0xFFC7A87B).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected 
                            ? Colors.white 
                            : const Color(0xFF333333),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        //Essa seccao é para filtrar dados como mais recentes. etc
        // const SizedBox(height: 16),
        
        // Filtros de ordenação
        // Container(
        //   height: 40,
        //   margin: const EdgeInsets.symmetric(horizontal: 20),
        //   child: ListView.builder(
        //     scrollDirection: Axis.horizontal,
        //     itemCount: filters.length,
        //     itemBuilder: (context, index) {
        //       String filter = filters[index];
        //       bool isSelected = selectedFilter == filter;

        //       return GestureDetector(
        //         onTap: () {
        //           setState(() {
        //             selectedFilter = filter;
        //           });
        //         },
        //         child: Container(
        //           margin: const EdgeInsets.only(right: 8),
        //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //           decoration: BoxDecoration(
        //             color: isSelected 
        //                 ? const Color(0xFF8B5E3C) 
        //                 : const Color(0xFFF5F5F5),
        //             borderRadius: BorderRadius.circular(20),
        //           ),
        //           child: Center(
        //             child: Text(
        //               filter,
        //               style: TextStyle(
        //                 color: isSelected 
        //                     ? Colors.white 
        //                     : const Color(0xFF333333),
        //                 fontWeight: FontWeight.w500,
        //                 fontSize: 12,
        //               ),
        //             ),
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // ),
     
      ],
    );
  }

  Widget buildVideosList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredVideos.length,
      itemBuilder: (context, index) {
        final video = filteredVideos[index];
        return buildVideoCard(video);
      },
    );
  }

  Widget buildVideoCard(Map<String, dynamic> video) {
    return GestureDetector(
      onTap: () {
        _showVideoPlayer(video);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
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
            // Thumbnail
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    color: const Color(0xFFC7A87B).withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons.play_circle_outline,
                    color: Color(0xFFC7A87B),
                    size: 64,
                  ),
                ),
                
                // Overlay com badges
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: video['category'] == 'Notícias' 
                          ? Colors.red 
                          : const Color(0xFFC7A87B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      video['category'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // Badge ao vivo
                if (video['isLive'])
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fiber_manual_record,
                            color: Colors.white,
                            size: 8,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'AO VIVO',
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
                
                // Badge premium
                if (video['isPremium'])
                  Positioned(
                    top: video['isLive'] ? 50 : 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5E3C),
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
                
                // Duração
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      video['duration'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // Botão play central
                const Positioned.fill(
                  child: Center(
                    child: Icon(
                      Icons.play_circle_filled,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ],
            ),
            
            // Informações do vídeo
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    video['title'],
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
                  
                  // Autor
                  Text(
                    video['author'],
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF333333).withOpacity(0.7),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Descrição
                  Text(
                    video['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF333333).withOpacity(0.8),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Footer com estatísticas
                  Row(
                    children: [
                      // Views
                      Row(
                        children: [
                          Icon(
                            Icons.visibility,
                            size: 16,
                            color: const Color(0xFF333333).withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatNumber(video['views']),
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF333333).withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Likes
                      Row(
                        children: [
                          Icon(
                            Icons.thumb_up,
                            size: 16,
                            color: const Color(0xFF333333).withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${video['likes']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF333333).withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Data
                      Text(
                        _formatDate(video['date']),
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF333333).withOpacity(0.6),
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

  void _showVideoPlayer(Map<String, dynamic> video) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Container(
          height: 300,
          child: Column(
            children: [
              // Simulação de player
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          Icons.play_circle_filled,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Text(
                          video['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Controles
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black87,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_10, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.fullscreen, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    DateTime now = DateTime.now();
    Duration difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Vídeos'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Digite o título do vídeo...',
            border: OutlineInputBorder(),
          ),
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

  void _showMyLibraryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Minha Biblioteca'),
        content: const Text('Funcionalidade de biblioteca de vídeos em desenvolvimento.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}