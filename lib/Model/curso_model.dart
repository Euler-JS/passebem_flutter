class ModuloModel {
  final String id;
  final String nome;

  ModuloModel({
    required this.id,
    required this.nome,
  });

  factory ModuloModel.fromJson(Map<String, dynamic> json) {
    return ModuloModel(
      id: json['_id'] ?? '',
      nome: json['nome'] ?? '',
    );
  }
}

class VideoAulaModel {
  final String id;
  final String moduloId;
  final String titulo;
  final String videoUrl;
  final String? thumbnailUrl;
  final String? professor;

  VideoAulaModel({
    required this.id,
    required this.moduloId,
    required this.titulo,
    required this.videoUrl,
    this.thumbnailUrl,
    this.professor,
  });

  factory VideoAulaModel.fromJson(Map<String, dynamic> json) {
    return VideoAulaModel(
      id: json['_id'] ?? '',
      moduloId: json['modulo_id'] ?? '',
      titulo: json['titulo'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      professor: json['professor'],
    );
  }
}
