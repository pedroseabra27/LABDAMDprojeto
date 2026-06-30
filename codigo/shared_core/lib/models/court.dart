class Court {
  final int id;
  final String nome;
  final String esporte;
  final String precoHora;
  final String? imagemUrl;
  final String? endereco;
  final String? descricao;

  Court({
    required this.id,
    required this.nome,
    required this.esporte,
    required this.precoHora,
    this.imagemUrl,
    this.endereco,
    this.descricao,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'],
      nome: json['nome'],
      esporte: json['esporte'],
      precoHora: json['precoHora'],
      imagemUrl: json['imagemUrl'],
      endereco: json['endereco'],
      descricao: json['descricao'],
    );
  }
}
