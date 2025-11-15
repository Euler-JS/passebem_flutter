import 'package:flutter/material.dart';

class PodcastsPage extends StatefulWidget {
  const PodcastsPage({super.key});

  @override
  State<PodcastsPage> createState() => _PodcastsPageState();
}

class _PodcastsPageState extends State<PodcastsPage> {
  String selectedCategory = "Todos";
  bool isPlaying = false;
  int currentPlayingIndex = -1;

  // Dados simulados de podcasts
  final List<Map<String, dynamic>> podcasts = [
    {
      'id': '1',
      'title': 'Notícias da Manhã',
      'description': 'Resumo das principais notícias do dia em Moçambique',
      'host': 'Carlos Manjate',
      'duration': '25 min',
      'category': 'Notícias',
      'image': 'Images/podcast1.png',
      'date': '2024-03-15',
      'plays': 1250,
      'isPremium': false,
      'isNew': true,
    },
    {
      'id': '2',
      'title': 'Tech Talk Moz',
      'description': 'Discussões sobre tecnologia e inovação em Moçambique',
      'host': 'Maria Silva',
      'duration': '45 min',
      'category': 'Tecnologia',
      'image': 'Images/podcast2.png',
      'date': '2024-03-14',
      'plays': 890,
      'isPremium': true,
      'isNew': false,
    },
    {
      'id': '3',
      'title': 'Economia em Foco',
      'description': 'Análises económicas e mercados financeiros',
      'host': 'Silva Macamo',
      'duration': '35 min',
      'category': 'Economia',
      'image': 'Images/podcast3.png',
      'date': '2024-03-13',
      'plays': 650,
      'isPremium': false,
      'isNew': false,
    },
    {
      'id': '4',
      'title': 'Cultura Mocambicana',
      'description': 'Explorando as tradições e cultura de Moçambique',
      'host': 'Ana Chissano',
      'duration': '30 min',
      'category': 'Cultura',
      'image': 'Images/podcast4.png',
      'date': '2024-03-12',
      'plays': 420,
      'isPremium': true,
      'isNew': false,
    },
    {
      'id': '5',
      'title': 'Desporto Nacional',
      'description': 'Cobertura completa do desporto moçambicano',
      'host': 'Pedro Nhantumbo',
      'duration': '40 min',
      'category': 'Desporto',
      'image': 'Images/podcast5.png',
      'date': '2024-03-11',
      'plays': 780,
      'isPremium': false,
      'isNew': false,
    },
  ];

  final List<String> categories = [
    'Todos',
    'Notícias',
    'Tecnologia',
    'Economia',
    'Cultura',
    'Desporto',
  ];

  List<Map<String, dynamic>> get filteredPodcasts {
    if (selectedCategory == "Todos") {
      return podcasts;
    }
    return podcasts.where((p) => p['category'] == selectedCategory).toList();
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
            'Podcasts',
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
              icon: const Icon(Icons.playlist_play, color: Color(0xFFC7A87B)),
              onPressed: _showPlaylistDialog,
            ),
          ],
        ),

        // Header com estatísticas
        SliverToBoxAdapter(child: buildHeader()),

        // Seletor de categorias fixo
        SliverAppBar(
          backgroundColor: Colors.white,
          elevation: 4,
          automaticallyImplyLeading: false,
          floating: false,
          pinned: true,
          snap: false,
          toolbarHeight: 80,
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: buildCategorySelector(),
          ),
        ),

        // Lista de podcasts
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: buildSliverPodcastsList(),
        ),
      ],
    ),
    // Player fixo na parte inferior
    bottomSheet: currentPlayingIndex != -1 ? buildMiniPlayer() : null,
  );
}

Widget buildSliverPodcastsList() {
  return SliverList(
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        final podcast = filteredPodcasts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: buildPodcastCard(podcast, index),
        );
      },
      childCount: filteredPodcasts.length,
    ),
  );
}

  Widget buildHeader() {
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
                'Podcasts Exclusivos',
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
            'Ouça os melhores podcasts de Moçambique',
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
      "${filteredPodcasts.length}",
      "Episódios",
      Icons.podcasts,
    ),
    _buildStatChip(
      "${filteredPodcasts.where((p) => p['isPremium']).length}",
      "Premium",
      Icons.workspace_premium,
    ),
    _buildStatChip(
      "${filteredPodcasts.where((p) => p['isNew']).length}",
      "Novos",
      Icons.new_releases,
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
    return Container(
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
    );
  }

  Widget buildPodcastsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredPodcasts.length,
      itemBuilder: (context, index) {
        final podcast = filteredPodcasts[index];
        return buildPodcastCard(podcast, index);
      },
    );
  }

  Widget buildPodcastCard(Map<String, dynamic> podcast, int index) {
    bool isCurrentlyPlaying = currentPlayingIndex == index;

    return GestureDetector(
      onTap: () {
        _showPodcastDetails(podcast, index);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentlyPlaying 
                ? const Color(0xFFC7A87B)
                : const Color(0xFFC7A87B).withOpacity(0.3),
            width: isCurrentlyPlaying ? 2 : 1,
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
          child: Row(
            children: [
              // Imagem do podcast
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFC7A87B).withOpacity(0.2),
                    ),
                    child: const Icon(
                      Icons.podcasts,
                      color: Color(0xFFC7A87B),
                      size: 40,
                    ),
                  ),
                  
                  // Badge novo
                  if (podcast['isNew'])
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'NOVO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(width: 16),
              
              // Informações do podcast
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título e premium badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            podcast['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (podcast['isPremium'])
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC7A87B),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Premium',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Host
                    Text(
                      'Por ${podcast['host']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF333333).withOpacity(0.7),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Descrição
                    Text(
                      podcast['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF333333).withOpacity(0.8),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Footer
                    Row(
                      children: [
                        // Duração
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: const Color(0xFF333333).withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          podcast['duration'],
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF333333).withOpacity(0.6),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Plays
                        Icon(
                          Icons.play_arrow,
                          size: 14,
                          color: const Color(0xFF333333).withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${podcast['plays']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF333333).withOpacity(0.6),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Categoria
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC7A87B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            podcast['category'],
                            style: const TextStyle(
                              color: Color(0xFFC7A87B),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Botão play/pause
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isCurrentlyPlaying) {
                      isPlaying = !isPlaying;
                    } else {
                      currentPlayingIndex = index;
                      isPlaying = true;
                    }
                  });
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isCurrentlyPlaying 
                        ? const Color(0xFFC7A87B) 
                        : const Color(0xFFC7A87B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    isCurrentlyPlaying && isPlaying 
                        ? Icons.pause 
                        : Icons.play_arrow,
                    color: isCurrentlyPlaying ? Colors.white : const Color(0xFFC7A87B),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMiniPlayer() {
    final podcast = filteredPodcasts[currentPlayingIndex];
    
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Imagem pequena
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFC7A87B).withOpacity(0.2),
              ),
              child: const Icon(
                Icons.podcasts,
                color: Color(0xFFC7A87B),
                size: 24,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Informações
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    podcast['title'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    podcast['host'],
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF333333).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // Controles
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () {
                    // Implementar anterior
                  },
                  color: const Color(0xFFC7A87B),
                ),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    setState(() {
                      isPlaying = !isPlaying;
                    });
                  },
                  color: const Color(0xFFC7A87B),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () {
                    // Implementar próximo
                  },
                  color: const Color(0xFFC7A87B),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      currentPlayingIndex = -1;
                      isPlaying = false;
                    });
                  },
                  color: const Color(0xFF333333),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPodcastDetails(Map<String, dynamic> podcast, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFC7A87B).withOpacity(0.2),
                    ),
                    child: const Icon(
                      Icons.podcasts,
                      color: Color(0xFFC7A87B),
                      size: 50,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          podcast['title'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Por ${podcast['host']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF333333).withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Descrição
              Text(
                'Descrição',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                podcast['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF333333).withOpacity(0.8),
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Informações adicionais
              Row(
                children: [
                  _buildInfoChip(Icons.access_time, podcast['duration']),
                  const SizedBox(width: 16),
                  _buildInfoChip(Icons.play_arrow, '${podcast['plays']} plays'),
                  const SizedBox(width: 16),
                  _buildInfoChip(Icons.category, podcast['category']),
                ],
              ),
              
              const Spacer(),
              
              // Botão de ação
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC7A87B), Color(0xFF8B5E3C)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      currentPlayingIndex = index;
                      isPlaying = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Reproduzir Agora',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFC7A87B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFFC7A87B),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFC7A87B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Podcasts'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Digite o nome do podcast...',
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

  void _showPlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Playlist'),
        content: const Text('Funcionalidade de playlist em desenvolvimento.'),
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