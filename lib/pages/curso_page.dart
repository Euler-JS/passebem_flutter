import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../Model/curso_model.dart';

class CursoPage extends StatefulWidget {
  const CursoPage({Key? key}) : super(key: key);

  @override
  State<CursoPage> createState() => _CursoPageState();
}

class _CursoPageState extends State<CursoPage> {
  List<ModuloModel> modulos = [];
  List<VideoAulaModel> videos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarModulos();
  }

  Future<void> _carregarModulos() async {
    try {
      final response = await AuthService.getModulos();
      
      final List<ModuloModel> loadedModulos = [];
      final List<VideoAulaModel> loadedVideos = [];
      
      // Parsear módulos
      if (response['modulos'] != null) {
        for (var moduloJson in response['modulos']) {
          loadedModulos.add(ModuloModel.fromJson(moduloJson));
        }
      }
      
      // Parsear vídeos
      if (response['videos'] != null) {
        for (var videoJson in response['videos']) {
          loadedVideos.add(VideoAulaModel.fromJson(videoJson));
        }
      }
      
      setState(() {
        modulos = loadedModulos;
        videos = loadedVideos;
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar módulos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF607D8B),
        title: const Text(
          'Aulas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA000),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'Sua próxima habilidade a partir de 2000.00MT',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...modulos.map((modulo) => _buildModuloSection(modulo)),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/image/aula.png',
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 150,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.school,
                        size: 100,
                        color: Colors.grey,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildModuloSection(ModuloModel modulo) {
    final moduloVideos = videos.where((v) => v.moduloId == modulo.id).toList();

    if (moduloVideos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  modulo.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.keyboard_tab,
                  color: Color(0xFF607D8B),
                ),
                onPressed: () {
                  // Navegação para lista completa de vídeos do módulo
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoListPage(
                        modulo: modulo,
                        videos: moduloVideos,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: moduloVideos.length,
            itemBuilder: (context, index) {
              final video = moduloVideos[index];
              return _buildVideoCard(video);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCard(VideoAulaModel video) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerPage(video: video),
          ),
        );
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (video.thumbnailUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        video.thumbnailUrl!,
                        width: 170,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.play_circle_outline,
                              size: 50,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    )
                  else
                    const Icon(
                      Icons.play_circle_outline,
                      size: 50,
                      color: Colors.white,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              video.titulo,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D636D),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Prof: ${video.professor ?? "Julios Tinga"}',
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF3E4452),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Página para lista completa de vídeos
class VideoListPage extends StatelessWidget {
  final ModuloModel modulo;
  final List<VideoAulaModel> videos;

  const VideoListPage({
    Key? key,
    required this.modulo,
    required this.videos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF607D8B),
        title: Text(
          modulo.nome,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                ),
              ),
              title: Text(
                video.titulo,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Prof: ${video.professor ?? "Julios Tinga"}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerPage(video: video),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Página do player de vídeo
class VideoPlayerPage extends StatelessWidget {
  final VideoAulaModel video;

  const VideoPlayerPage({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          video.titulo,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.play_circle_outline,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                video.titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              'URL: ${video.videoUrl}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Adicione o pacote video_player para reproduzir vídeos',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
