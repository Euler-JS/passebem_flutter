import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HotTopic {
  String image;
  String name;
  Color color;
  HotTopic({
    required this.color,
    required this.image,
    required this.name,
  });
}

List<HotTopic> topicItems = [
  HotTopic(
    color: const Color(0xFF8B5E3C), // Marrom suave
    image: "Images/world.png",
    name: 'World',
  ),
  HotTopic(
    color: const Color(0xFF333333), // Cinza escuro
    image: "Images/tech.png",
    name: 'Tech',
  ),
  HotTopic(
    color: const Color(0xFFC7A87B), // Bege/creme
    image: "Images/music.png",
    name: 'Music',
  ),
  HotTopic(
    color: const Color(0xFF8B5E3C), // Marrom suave
    image: "Images/travel.png",
    name: 'Travel',
  ),
  HotTopic(
    color: const Color(0xFF333333), // Cinza escuro
    image: "Images/kitchen.png",
    name: 'Kitchen',
  ),
  HotTopic(
    color: const Color(0xFFC7A87B), // Bege/creme
    image: "Images/fashion.png",
    name: 'Fashion',
  ),
];

// Modelo expandido para suas notícias
class Yournews {
  String id; // ID único para a notícia
  String image;
  String newsImage;
  String newsTitle;
  String newsCategories;
  String time;
  String date;
  Color color;
  String description; // Trecho curto/preview
  String fullContent; // Texto completo da notícia
  bool isPremium; // Se é conteúdo premium
  int views; // Número de visualizações
  bool isBookmarked; // Se está salvo
  bool isFeatured; // Se deve aparecer no carrossel

  Yournews({
    this.id = '', // ID padrão vazio para compatibilidade com dados existentes
    required this.image,
    required this.newsImage,
    required this.newsTitle,
    required this.newsCategories,
    required this.time,
    required this.date,
    required this.color,
    required this.description,
    required this.fullContent,
    this.isPremium = false,
    this.views = 0,
    this.isBookmarked = false,
    this.isFeatured = false,
  });

  // Método para converter o objeto para Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'newsImage': newsImage,
      'newsTitle': newsTitle,
      'newsCategories': newsCategories,
      'time': time,
      'date': date,
      'color': color.value, // Converte Color para int
      'description': description,
      'fullContent': fullContent,
      'isPremium': isPremium,
      'views': views,
      'isBookmarked': isBookmarked,
      'isFeatured': isFeatured,
    };
  }

  // Método estático para criar objeto a partir de Map (JSON)
  static Yournews fromJson(Map<String, dynamic> json) {
    return Yournews(
      id: json['id'] ?? '',
      image: json['image'] ?? '',
      newsImage: json['newsImage'] ?? '',
      newsTitle: json['newsTitle'] ?? '',
      newsCategories: json['newsCategories'] ?? 'GENERAL',
      time: json['time'] ?? '',
      date: json['date'] ?? '',
      color: Color(json['color'] ?? 0xFF333333), // Converte int para Color
      description: json['description'] ?? '',
      fullContent: json['fullContent'] ?? '',
      isPremium: json['isPremium'] ?? false,
      views: json['views'] ?? 0,
      isBookmarked: json['isBookmarked'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
    );
  }

  // Método para garantir que a notícia tenha um ID válido
  void ensureId() {
    if (id.isEmpty) {
      id = newsTitle.hashCode.abs().toString();
    }
  }

  // Método para criar uma cópia da notícia
  Yournews copyWith({
    String? id,
    String? image,
    String? newsImage,
    String? newsTitle,
    String? newsCategories,
    String? time,
    String? date,
    Color? color,
    String? description,
    String? fullContent,
    bool? isPremium,
    int? views,
    bool? isBookmarked,
    bool? isFeatured,
  }) {
    return Yournews(
      id: id ?? this.id,
      image: image ?? this.image,
      newsImage: newsImage ?? this.newsImage,
      newsTitle: newsTitle ?? this.newsTitle,
      newsCategories: newsCategories ?? this.newsCategories,
      time: time ?? this.time,
      date: date ?? this.date,
      color: color ?? this.color,
      description: description ?? this.description,
      fullContent: fullContent ?? this.fullContent,
      isPremium: isPremium ?? this.isPremium,
      views: views ?? this.views,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}

List<Yournews> newsItems = [
  Yournews(
    id: '1', // ID adicionado para API
    description: "Conta-se que há muito, muito tempo, no tempo em que os animais falavam, o crocodilo e o macaco eram amigos bem chegados. Um dia, o crocodilo foi visitar o seu amigo macaco e, quando lá chegou, permaneceu uma semana. Depois de ter completado uma semana de visita, o crocodilo pediu ao seu amigo macaco que o acompanhasse a casa para assim, o maca...",
    fullContent: "Conta-se que há muito, muito tempo, no tempo em que os animais falavam, o crocodilo e o macaco eram amigos bem chegados. Um dia, o crocodilo foi visitar o seu amigo macaco e, quando lá chegou, permaneceu uma semana. Depois de ter completado uma semana de visita, o crocodilo pediu ao seu amigo macaco que o acompanhasse a casa para assim, o macaco conhecer a sua família.\n\nO macaco aceitou e ambos partiram juntos. No caminho, o crocodilo começou a pensar que seria uma boa ideia comer o macaco. Assim, ele disse ao macaco que tinha um presente especial para ele na sua casa. O macaco, inocente, ficou animado com a ideia.\n\nQuando chegaram à casa do crocodilo, este convidou o macaco a entrar e ofereceu-lhe um banquete delicioso. O macaco estava tão distraído com a comida que não percebeu as intenções do crocodilo. No entanto, quando o crocodilo se preparou para atacar, o macaco conseguiu escapar rapidamente e saltou para uma árvore próxima.\n\nO crocodilo ficou furioso por ter perdido a sua presa e jurou vingança. Mas o macaco era astuto e sempre conseguia escapar das garras do crocodilo. Desde então, eles tornaram-se inimigos mortais, mas a história da amizade entre o macaco e o crocodilo ainda é contada como um conto moral sobre confiança e traição.",
    newsImage: "image/tseve_macaco.jpg",
    image: "image/tseve_macaco.jpg",
    newsTitle: 'A amizade entre o macaco e crocodilo (conto)',
    newsCategories: "TRAVEL",
    date: 'Sunday 2 March 2024',
    time: '2m',
    color: const Color(0xFFC7A87B),
    views: 1250,
    isBookmarked: false,
    isFeatured: true,
    isPremium: false,
  ),
  Yournews(
    description: "Remédio de lua é um medicamento tradicional dado à criança nos primeiros meses de vida, pois acredita-se que o mesmo protege o bebé de ataques epilépticos. O nome “remédio de lua” deriva da crença ou do conhecimento de que durante as fases de transição da lua algumas crianças têm ataques epilépticos, que para o seu tratamento ...",
    fullContent: "Remédio de lua é um medicamento tradicional dado à criança nos primeiros meses de vida, pois acredita-se que o mesmo protege o bebé de ataques epilépticos. O nome “remédio de lua” deriva da crença ou do conhecimento de que durante as fases de transição da lua algumas crianças têm ataques epilépticos, que para o seu tratamento é necessário o uso deste remédio.\n\nO remédio é feito com uma mistura de ervas e raízes, que são fervidas e depois administradas à criança. Acredita-se que o remédio tem propriedades calmantes e protetoras, ajudando a prevenir convulsões e outros problemas neurológicos.\n\nNo entanto, a eficácia do remédio de lua é controversa. Enquanto alguns pais juram por seus benefícios, outros questionam sua validade científica. Estudos sobre o assunto são limitados e muitas vezes inconclusivos.\n\nApesar disso, o remédio de lua continua a ser uma prática comum em muitas comunidades, especialmente em áreas rurais onde o acesso a cuidados médicos convencionais pode ser limitado. A tradição persiste como parte do conhecimento cultural local, refletindo a interseção entre medicina tradicional e moderna.",
    newsImage: "image/tseve_barro.png",
    image: "image/tseve_barro.png",
    newsTitle: 'Remédio de lua: a disputa entre o conhecimento tradicional e convencional',
    newsCategories: "MUSIC",
    date: 'Saturday 29 Nov 2023',
    time: '4h',
    color: const Color(0xFF8B5E3C),
    views: 2100,
    isBookmarked: true,
    isFeatured: true,
    isPremium: true, // Conteúdo premium
  ),
  Yournews(
    description: "As sociedades africanas são culturalmente crentes da existência de espíritos de antepassados que conduzem, amaldiçoam ou atormentam a vida das pessoas ainda em vida. Curandeiros ou nyangas são guiados por espíritos nas suas acções para a cura de seus doentes. Pessoas alegam terem sido possuídas por espíritos para terem optado por certa...",
    fullContent: "As sociedades africanas são culturalmente crentes da existência de espíritos de antepassados que conduzem, amaldiçoam ou atormentam a vida das pessoas ainda em vida. Curandeiros ou nyangas são guiados por espíritos nas suas acções para a cura de seus doentes. Pessoas alegam terem sido possuídas por espíritos para terem optado por certa profissão ou para terem cometido certos crimes. A crença na existência de espíritos é tão forte que, em algumas sociedades, a morte de uma pessoa",
    newsImage: "image/tseve_marido.jpg",
    image: "image/tseve_marido.jpg",
    newsTitle: "“Marido da noite”: do mistério espiritual ao ultraje às vítimas",
    newsCategories: "TECH",
    date: 'Saturday 29 Nov 2019',
    time: '10h',
    color: const Color(0xFF333333),
    views: 890,
    isBookmarked: false,
    isFeatured: false,
    isPremium: true, // Conteúdo premium
  ),
  Yournews(
    description: "TSV (026/2025) – A Lagoa de Nhambande (dona virgem em português) está situada na localidade de Nhambande, distrito de Machanga, província de Sofala. Nhambande é mais do que um simples espelho de água: trata-se de um repositório vivo de memórias, crenças, rituais, práticas de justiça tradicional e resistência simbólica diante das ad...",
    fullContent: "TSV (026/2025) – A Lagoa de Nhambande (dona virgem em português) está situada na localidade de Nhambande, distrito de Machanga, província de Sofala. Nhambande é mais do que um simples espelho de água: trata-se de um repositório vivo de memórias, crenças, rituais, práticas de justiça tradicional e resistência simbólica diante das adversidades.",
    newsImage: "image/tseve_vovo.jpg",
    image: "image/tseve_vovo.jpg",
    newsTitle: "A Sagrada Lagoa de Nhambande: a lagoa da vida",
    newsCategories: "WORLD",
    date: 'Saturday 29 Nov 1101',
    time: '∞',
    color: const Color(0xFFC7A87B),
    views: 500,
    isBookmarked: true,
    isFeatured: true,
    isPremium: false,
  ),
  // Adicionando mais notícias para exemplo
  Yournews(
    description: "TSV (025/2025) – KuLhamba ou KuLhamba khombo é um banho tradicional colectivo, envolvendo membros da mesma linhagem, isto é, descendentes de avô, bisavô ou trisavô comum, para os libertar de khombo, uma maldição que se manifesta através de enfermidades, falta de sorte (no casamento, dificuldades para encontrar emprego, mesmo com...",
    fullContent: "TSV (025/2025) – KuLhamba ou KuLhamba khombo é um banho tradicional colectivo, envolvendo membros da mesma linhagem, isto é, descendentes de avô, bisavô ou trisavô comum, para os libertar de khombo, uma maldição que se manifesta através de enfermidades, falta de sorte (no casamento, dificuldades para encontrar emprego, mesmo com formação académica), entre outros ",
    newsImage: "image/tseve_purificacao.jpg",
    image: "image/tseve_purificacao.jpg",
    newsTitle: "KuLhamba khombo: a arte de “purificação”",
    newsCategories: "TECH",
    date: 'Monday 4 March 2024',
    time: '1h',
    color: const Color(0xFF333333),
    views: 3200,
    isBookmarked: false,
    isFeatured: false,
    isPremium: true,
  ),
  Yournews(
    description: "Sustainable fashion is becoming more than just a trend—it's a necessity for the future of our planet.",
    fullContent: "Sustainable fashion is becoming more than just a trend—it's a necessity for the future of our planet. The fashion industry is one of the most polluting industries in the world, and consumers are increasingly demanding more ethical and environmentally friendly options.\n\nSustainable fashion involves using eco-friendly materials, reducing waste, and ensuring fair labor practices throughout the supply chain. Brands are exploring innovative materials like recycled plastics, organic cotton, and even lab-grown leather alternatives.\n\nThe concept of 'slow fashion' is gaining traction, encouraging consumers to buy fewer, higher-quality pieces that last longer. This approach contrasts with fast fashion, which promotes frequent purchases of cheap, disposable clothing.\n\nMany designers are now focusing on creating timeless pieces that won't go out of style, and some brands are implementing take-back programs where customers can return old clothes for recycling or upcycling.\n\nConsumers can contribute to sustainable fashion by choosing quality over quantity, supporting ethical brands, and taking care of their clothes to extend their lifespan.",
    newsImage: "Images/fashion.png",
    image: "Images/fashion.png",
    newsTitle: "Sustainable Fashion: The Future is Green",
    newsCategories: "FASHION",
    date: 'Tuesday 5 March 2024',
    time: '30m',
    color: const Color(0xFFC7A87B),
    views: 720,
    isBookmarked: false,
    isFeatured: false,
    isPremium: false,
  ),
];

// Funções helper para filtrar notícias
class NewsHelper {
  // Flag para determinar se deve usar API ou dados estáticos
  static bool useApiData = true;
  
  // Obter token armazenado para autenticação
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  // Headers padrão com autenticação
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Obter notícias em destaque para o carrossel
  static List<Yournews> getFeaturedNews() {
    return newsItems.where((news) => news.isFeatured).toList();
  }
  
  // Obter notícias mais lidas (ordenadas por views)
  static List<Yournews> getMostReadNews() {
    List<Yournews> sortedNews = List.from(newsItems);
    sortedNews.sort((a, b) => b.views.compareTo(a.views));
    return sortedNews.take(5).toList();
  }
  
  // Obter notícias recentes
  static List<Yournews> getRecentNews() {
    return newsItems.take(4).toList();
  }
  
  // Filtrar notícias por categoria
  static List<Yournews> getNewsByCategory(String category) {
    return newsItems.where((news) => 
      news.newsCategories.toLowerCase() == category.toLowerCase()
    ).toList();
  }
  
  // Obter notícias salvas
  static List<Yournews> getBookmarkedNews() {
    // Usando dados mockados localmente para compatibilidade
    if (!useApiData) {
      return newsItems.where((news) => news.isBookmarked).toList();
    }
    // Retornando lista vazia, pois o método real será assíncrono
    return [];
  }
  
  // Método assíncrono para obter bookmarks da API
  static Future<List<Yournews>> fetchBookmarkedNewsFromApi() async {
    if (!useApiData) {
      // Fallback para dados locais se a API não estiver ativada
      return Future.value(newsItems.where((news) => news.isBookmarked).toList());
    }
    
    try {
      // Importação dinâmica para evitar problemas de referência circular
      // Deve ser importado em runtime pelo componente que usa
      // import '../services/news_service.dart';
      // return await NewsService.getBookmarkedNews();
      
      // Enquanto estamos integrando, retornamos a implementação local
      return Future.value(newsItems.where((news) => news.isBookmarked).toList());
    } catch (e) {
      print('Erro ao buscar favoritos da API: $e');
      // Fallback para dados locais em caso de erro
      return Future.value(newsItems.where((news) => news.isBookmarked).toList());
    }
  }
  
  // Alternar bookmark
  static Future<bool> toggleBookmark(Yournews news) async {
    if (!useApiData) {
      // Implementação local antiga
      news.isBookmarked = !news.isBookmarked;
      return Future.value(true);
    }
    
    try {
      // Importar o serviço no arquivo que usa este método
      // import '../services/news_service.dart';
      
      // Verificar se a notícia tem um ID válido
      if (news.id.isEmpty) {
        print('Erro: ID da notícia está vazio, não é possível realizar operação com a API');
        // Fallback para implementação local
        news.isBookmarked = !news.isBookmarked;
        return true;
      }
      
      // Usar a variável externa "newsService" que deve ser inicializada no arquivo que usa este método
      if (news.isBookmarked) {
        // Remover dos favoritos
        // Esta linha deve ser descomenada e usada no arquivo real que importa NewsService
        // bool success = await NewsService.unbookmarkNews(news.id);
        
        // Por enquanto, chamar diretamente o HTTP
        final response = await http.delete(
          Uri.parse('https://tsevelenews.tsevele.co.mz/api/news/${news.id}/bookmark'),
          headers: await _getAuthHeaders(),
        );
        
        final success = response.statusCode == 200 || response.statusCode == 204;
        if (success) {
          news.isBookmarked = false;
        }
        return success;
      } else {
        // Adicionar aos favoritos
        // Esta linha deve ser descomenada e usada no arquivo real que importa NewsService
        // bool success = await NewsService.bookmarkNews(news.id);
        
        // Por enquanto, chamar diretamente o HTTP
        final response = await http.post(
          Uri.parse('https://tsevelenews.tsevele.co.mz/api/news/${news.id}/bookmark'),
          headers: await _getAuthHeaders(),
        );
        
        final success = response.statusCode == 200 || response.statusCode == 201;
        if (success) {
          news.isBookmarked = true;
        }
        return success;
      }
    } catch (e) {
      print('Erro ao alternar favorito na API: $e');
      // Implementação local como fallback
      news.isBookmarked = !news.isBookmarked;
      return true;
    }
  }
  
  // Verificar se uma notícia está nos favoritos via API
  static Future<bool> isNewsBookmarked(String newsId) async {
    if (!useApiData) {
      // Implementação local
      return Future.value(
        newsItems.any((news) => news.id == newsId && news.isBookmarked)
      );
    }
    
    try {
      // import '../services/news_service.dart';
      // return await NewsService.isNewsBookmarked(newsId);
      
      // Implementação temporária enquanto estamos integrando
      return Future.value(
        newsItems.any((news) => news.id == newsId && news.isBookmarked)
      );
    } catch (e) {
      print('Erro ao verificar favorito na API: $e');
      return false;
    }
  }
  
  // Incrementar visualizações
  static void incrementViews(Yournews news) {
    news.views++;
  }
}