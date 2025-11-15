import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:news_app/Model/news_model.dart';
import 'package:news_app/pages/subscription_plans_new.dart';
import 'package:news_app/Model/news_helper.dart' as news_helper; // Import do NewsHelper local

class DetailNews extends StatefulWidget {
  const DetailNews({super.key, required this.news});

  final Yournews news;

  @override
  State<DetailNews> createState() => _DetailNewsState();
}

class _DetailNewsState extends State<DetailNews> {
  bool isUserPremium = false;
  bool isLiked = false;
  int likeCount = 147;
  int commentCount = 23;
  bool isLoadingBookmark = false;

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
    _initializeNews();
  }

  // Inicializar dados da notícia
  Future<void> _initializeNews() async {
    // Garantir que a notícia tenha um ID
    widget.news.ensureId();
    
    // Incrementar views
    await news_helper.NewsHelper.incrementViews(widget.news);
    
    // Verificar se a notícia está nos bookmarks locais
    await _checkBookmarkStatus();
  }

  // Verificar status do bookmark
  Future<void> _checkBookmarkStatus() async {
    try {
      final isBookmarked = await news_helper.NewsHelper.isBookmarked(widget.news);
      if (mounted) {
        setState(() {
          widget.news.isBookmarked = isBookmarked;
        });
      }
    } catch (e) {
      print('Erro ao verificar status do bookmark: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // AppBar customizado com imagem
          buildSliverAppBar(),
          
          // Conteúdo principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoria e data
                  buildCategorySection(),
                  
                  const SizedBox(height: 16),
                  
                  // Título
                  buildTitle(),
                  
                  const SizedBox(height: 20),
                  
                  // Estatísticas e autor
                  buildStatsAndAuthor(),
                  
                  const SizedBox(height: 24),
                  
                  // Botões de interação
                  buildInteractionButtons(),
                  
                  const SizedBox(height: 32),
                  
                  // Conteúdo do artigo
                  buildArticleContent(),
                  
                  const SizedBox(height: 40),
                  
                  // Seção de comentários
                  // buildCommentsSection(),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: isLoadingBookmark
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    widget.news.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    color: widget.news.isBookmarked ? const Color(0xFFC7A87B) : Colors.white,
                    size: 20,
                  ),
            onPressed: isLoadingBookmark ? null : _handleBookmarkToggle,
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.white, size: 20),
            onPressed: _shareNews,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Imagem de fundo
            widget.news.newsImage.startsWith('http') 
              ? Image.network(
                  widget.news.newsImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.image,
                        size: 64,
                        color: Colors.grey.shade600,
                      ),
                    );
                  },
                )
              : Image.asset(
                  widget.news.newsImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.image,
                        size: 64,
                        color: Colors.grey.shade600,
                      ),
                    );
                  },
                ),
            
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
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
            
            // Badge premium se aplicável
            if (widget.news.isPremium)
              Positioned(
                top: 60,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC7A87B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.workspace_premium, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
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
    );
  }

  // Método para lidar com o toggle do bookmark - APENAS LOCAL
  Future<void> _handleBookmarkToggle() async {
    setState(() {
      isLoadingBookmark = true;
    });

    try {
      // Alternar bookmark usando apenas sistema local
      final wasAdded = await news_helper.NewsHelper.toggleBookmark(widget.news);
      
      if (mounted) {
        setState(() {
          isLoadingBookmark = false;
        });
        
        // Mostrar mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.news.isBookmarked 
                  ? "Notícia salva nos favoritos!" 
                  : "Notícia removida dos favoritos",
            ),
            backgroundColor: widget.news.isBookmarked 
                ? const Color(0xFFC7A87B) 
                : Colors.grey[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingBookmark = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Erro ao atualizar favorito"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      
      print('Erro ao alternar bookmark: $e');
    }
  }

  Widget buildCategorySection() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFC7A87B),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.news.newsCategories.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  widget.news.date,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${widget.news.time} de leitura',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTitle() {
    return Text(
      widget.news.newsTitle,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
        height: 1.3,
        letterSpacing: -0.5,
      ),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget buildStatsAndAuthor() {
    return Column(
      children: [
        // Linha do autor
        Row(
          children: [
            // Avatar do autor
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFC7A87B), Color(0xFF8B5E3C)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Info do autor
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Redação Tsevele',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  Text(
                    'Jornalista',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Linha das estatísticas
        Row(
          children: [
            Flexible(
              child: Row(
                children: [
                  Icon(
                    Icons.visibility,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _formatViews(widget.news.views),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Row(
                children: [
                  Icon(
                    Icons.thumb_up_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '$likeCount',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
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
    );
  }

  Widget buildInteractionButtons() {
    return Row(
      children: [
        // Botão Like
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              setState(() {
                isLiked = !isLiked;
                likeCount += isLiked ? 1 : -1;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isLiked ? const Color(0xFFC7A87B) : Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: isLiked ? Colors.white : Colors.grey[600],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Gostei',
                      style: TextStyle(
                        color: isLiked ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Botão Comentários
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              // Scroll para comentários
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Comentar',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildArticleContent() {
    String contentToShow;
    bool showPremiumButton = false;
    
    if (widget.news.isPremium && !isUserPremium) {
      List<String> paragraphs = widget.news.fullContent.split('\n\n');
      contentToShow = paragraphs.take(2).join('\n\n');
      showPremiumButton = true;
    } else {
      contentToShow = widget.news.fullContent;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Html(
          data: contentToShow,
          style: {
            "body": Style(
              fontSize: FontSize(17),
              lineHeight: LineHeight(1.6),
              color: const Color(0xFF2D3748),
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
            "p": Style(
              fontSize: FontSize(17),
              lineHeight: LineHeight(1.6),
              color: const Color(0xFF2D3748),
              margin: Margins.only(bottom: 16),
            ),
            "h1": Style(
              fontSize: FontSize(24),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A202C),
              margin: Margins.only(top: 20, bottom: 12),
            ),
            "h2": Style(
              fontSize: FontSize(22),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A202C),
              margin: Margins.only(top: 18, bottom: 10),
            ),
            "h3": Style(
              fontSize: FontSize(20),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A202C),
              margin: Margins.only(top: 16, bottom: 8),
            ),
            "strong": Style(
              fontWeight: FontWeight.bold,
            ),
            "em": Style(
              fontStyle: FontStyle.italic,
            ),
            "a": Style(
              color: const Color(0xFFC7A87B),
              textDecoration: TextDecoration.underline,
            ),
            "ul": Style(
              margin: Margins.only(top: 8, bottom: 16, left: 16),
            ),
            "ol": Style(
              margin: Margins.only(top: 8, bottom: 16, left: 16),
            ),
            "li": Style(
              margin: Margins.only(bottom: 8),
            ),
          },
        ),
        
        if (showPremiumButton) ...[
          const SizedBox(height: 32),
          
          // Card Premium moderno
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFC7A87B),
                  Color(0xFF8B5E3C),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC7A87B).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                const Text(
                  "Conteúdo Premium",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  "Continue lendo este artigo exclusivo com uma assinatura premium",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SubscriptionPlansPage(),
                        ),
                      );
                      
                      // Se retornou true, recarregar a página
                      if (result == true && mounted) {
                        setState(() {
                          // Isso vai recarregar a notícia e verificar o status premium
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF8B5E3C),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Assinar Premium",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Comentários',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFC7A87B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$commentCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Campo de comentário
        // Container(
        //   padding: const EdgeInsets.all(16),
        //   decoration: BoxDecoration(
        //     color: Colors.grey[50],
        //     borderRadius: BorderRadius.circular(16),
        //     border: Border.all(color: Colors.grey[200]!),
        //   ),
        //   child: Row(
        //     children: [
        //       Container(
        //         width: 40,
        //         height: 40,
        //         decoration: BoxDecoration(
        //           gradient: const LinearGradient(
        //             colors: [Color(0xFFC7A87B), Color(0xFF8B5E3C)],
        //           ),
        //           borderRadius: BorderRadius.circular(20),
        //         ),
        //         child: const Icon(
        //           Icons.person,
        //           color: Colors.white,
        //           size: 20,
        //         ),
        //       ),
        //       const SizedBox(width: 12),
        //       Expanded(
        //         child: TextField(
        //           decoration: InputDecoration(
        //             hintText: 'Adicione um comentário...',
        //             hintStyle: TextStyle(color: Colors.grey[500]),
        //             border: InputBorder.none,
        //           ),
        //         ),
        //       ),
        //       Container(
        //         padding: const EdgeInsets.all(8),
        //         decoration: BoxDecoration(
        //           color: const Color(0xFFC7A87B),
        //           borderRadius: BorderRadius.circular(8),
        //         ),
        //         child: const Icon(
        //           Icons.send,
        //           color: Colors.white,
        //           size: 18,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        
        const SizedBox(height: 24),
        
        // Comentários exemplo
        // ...List.generate(3, (index) => _buildCommentItem(index)),
      ],
    );
  }

  Widget _buildCommentItem(int index) {
    final comments = [
      {
        'name': 'Maria Santos',
        'time': '2h',
        'comment': 'Muito interessante esta perspectiva sobre a cultura moçambicana!',
        'likes': 5,
      },
      {
        'name': 'Silva Macamo',
        'time': '4h', 
        'comment': 'Ótimo artigo! É importante preservar estas tradições.',
        'likes': 3,
      },
      {
        'name': 'Ana Chissano',
        'time': '6h',
        'comment': 'Parabéns pela qualidade do jornalismo.',
        'likes': 8,
      },
    ];
    
    final comment = comments[index];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFC7A87B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    comment['name'].toString().substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment['name'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      comment['time'].toString(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment['comment'].toString(),
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.thumb_up_outlined,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '${comment['likes']}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Responder',
                style: TextStyle(
                  color: const Color(0xFFC7A87B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _shareNews() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Compartilhar Notícia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(Icons.copy, 'Copiar Link', () {
                  Clipboard.setData(ClipboardData(text: "https://tsevele.com/news/${widget.news.newsTitle}"));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copiado!')),
                  );
                }),
                _buildShareOption(Icons.chat, 'WhatsApp', () {}),
                _buildShareOption(Icons.facebook, 'Facebook', () {}),
                _buildShareOption(Icons.mail, 'Email', () {}),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFC7A87B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFC7A87B),
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}