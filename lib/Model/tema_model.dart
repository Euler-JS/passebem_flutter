// lib/Model/tema_model.dart

class TemaModel {
  final String id;
  final String nome;

  TemaModel({
    required this.id,
    required this.nome,
  });

  factory TemaModel.fromJson(Map<String, dynamic> json) {
    return TemaModel(
      id: json['_id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nome': nome,
    };
  }
}

class CreditosModel {
  final String id;
  final String user;
  final String pacote;
  final int atividade;
  final String inscricao;

  CreditosModel({
    required this.id,
    required this.user,
    required this.pacote,
    required this.atividade,
    required this.inscricao,
  });

  factory CreditosModel.fromJson(Map<String, dynamic> json) {
    return CreditosModel(
      id: json['_id']?.toString() ?? '',
      user: json['user']?.toString() ?? '',
      pacote: json['pacote']?.toString() ?? '',
      atividade: json['atividade'] ?? 0,
      inscricao: json['inscricao']?.toString() ?? '',
    );
  }
}

class TemasResponse {
  final List<TemaModel> temas;
  final CreditosModel? creditos;

  TemasResponse({
    required this.temas,
    this.creditos,
  });

  factory TemasResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> temasData = json['temas'] ?? [];
    final temas = temasData.map((item) => TemaModel.fromJson(item)).toList();
    
    CreditosModel? creditos;
    if (json['creditos'] != null && json['creditos'] is Map<String, dynamic>) {
      creditos = CreditosModel.fromJson(json['creditos'] as Map<String, dynamic>);
    }
    
    return TemasResponse(
      temas: temas,
      creditos: creditos,
    );
  }
}
