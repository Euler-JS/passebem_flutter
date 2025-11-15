// lib/pages/podcast_detail_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Model/podcast_model.dart';
import '../services/podcast_service.dart';

class PodcastDetailPage extends StatefulWidget {
  final PodcastModel podcast;

  const PodcastDetailPage({
    super.key,
    required this.podcast,
  });

  @override
  State<PodcastDetailPage> createState() => _PodcastDetailPageState();
}

class _PodcastDetailPageState extends State<PodcastDetailPage> {
  bool _isPlaying = false;
  bool _isFavorite = false;
  bool _isLoading = false;

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
    _markAsViewed();
  }

  Future<void> _markAsViewed() async {
    await PodcastService.markAsViewed(widget.podcast.id);
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isLoading = true;
    });

    final success = await PodcastService.toggleFavorite(widget.podcast.id);
    
    if (success) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite 
                ? 'Podcast adicionado aos favoritos' 
                : 'Podcast removido dos favoritos'
          ),
          backgroundColor: const Color(0xFFC7A87B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _playAudio(String? audioUrl) async {
    if (audioUrl == null || audioUrl.isEmpty) {
      _showSubscriptionDialog();
      return;
    }

    try {
      final uri = Uri.parse(audioUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        setState(() {
          _isPlaying = true;
        });
      } else {
        _showErrorSnackBar('Não foi possível reproduzir o áudio');
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao reproduzir áudio: $e');
    }
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.workspace_premium,
                color: Color(0xFFC7A87B),
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Conteúdo Premium',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          content: Text(
            widget.podcast.premiumMessage ?? 
            'Este é um conteúdo premium. Faça login e assine para ter acesso completo.',
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF333333).withOpacity(0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: const Color(0xFF333333).withOpacity(0.6),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Navegar para página de assinatura
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC7A87B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('Assinar'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Hoje';
    } else if (difference == 1) {
      return 'Ontem';
    } else if (difference < 7) {
      return '${difference}d atrás';
    } else if (difference < 30) {
      return '${(difference / 7).floor()}sem atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // AppBar com gradiente
          SliverAppBar(
            expandedHeight: 80,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFFC7A87B),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFC7A87B),
                    Color(0xFF8B5E3C),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                      ),
                onPressed: _isLoading ? null : _toggleFavorite,
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Conteúdo
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPodcastHeader(),
                _buildActionButtons(),
                _buildDescription(),
                if (widget.podcast.tags.isNotEmpty) _buildTags(),
                _buildStats(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodcastHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Imagem do podcast
          Container(
            width: double.infinity,
            height: 280,
            decoration: BoxDecoration(
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: widget.podcast.previewImageUrl.isNotEmpty
                  ? Image.network(
                      widget.podcast.previewImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage();
                      },
                    )
                  : _buildPlaceholderImage(),
            ),
          ),

          const SizedBox(height: 20),

          // Título e categoria
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.podcast.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                        height: 1.3,
                      ),
                    ),
                  ),
                  if (widget.podcast.isPremiumContent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC7A87B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFC7A87B),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            color: Color(0xFFC7A87B),
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Premium',
                            style: TextStyle(
                              color: Color(0xFFC7A87B),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFC7A87B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.podcast.getCategory.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFC7A87B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFFC7A87B).withOpacity(0.1),
      child: const Center(
        child: Icon(
          Icons.podcasts,
          size: 80,
          color: Color(0xFFC7A87B),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Botão principal
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: widget.podcast.canPlayFull
                  ? () => _playAudio(widget.podcast.audioUrl ?? widget.podcast.audioLink)
                  : widget.podcast.canPlaySample
                      ? () => _playAudio(widget.podcast.audioSampleUrl)
                      : _showSubscriptionDialog,
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              label: Text(
                widget.podcast.canPlayFull
                    ? 'Reproduzir'
                    : widget.podcast.canPlaySample
                        ? 'Amostra'
                        : 'Assinar Premium',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC7A87B),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
          
          if (widget.podcast.canPlaySample && widget.podcast.canPlayFull) ...[
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: () => _playAudio(widget.podcast.audioSampleUrl),
                icon: const Icon(
                  Icons.hearing,
                  color: Color(0xFFC7A87B),
                  size: 18,
                ),
                label: const Text(
                  'Prévia',
                  style: TextStyle(
                    color: Color(0xFFC7A87B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(
                    color: Color(0xFFC7A87B),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC7A87B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description,
                  color: Color(0xFFC7A87B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Descrição',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.podcast.description,
            style: TextStyle(
              fontSize: 15,
              color: const Color(0xFF333333).withOpacity(0.7),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC7A87B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.label,
                  color: Color(0xFFC7A87B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tags',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.podcast.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFC7A87B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFC7A87B).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  tag.name,
                  style: const TextStyle(
                    color: Color(0xFFC7A87B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC7A87B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Color(0xFFC7A87B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Estatísticas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.visibility,
                  label: 'Visualizações',
                  value: _formatViews(widget.podcast.totalViews),
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: const Color(0xFFC7A87B).withOpacity(0.2),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.comment,
                  label: 'Comentários',
                  value: widget.podcast.totalComments.toString(),
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: const Color(0xFFC7A87B).withOpacity(0.2),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.access_time,
                  label: 'Publicado',
                  value: _formatDate(widget.podcast.createdAt),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFFC7A87B),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: const Color(0xFF333333).withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}