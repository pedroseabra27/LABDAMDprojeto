class Court {
  final int id;
  final String nome;
  final String esporte;
  final String precoHora;

  Court({
    required this.id,
    required this.nome,
    required this.esporte,
    required this.precoHora,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'],
      nome: json['nome'],
      esporte: json['esporte'],
      precoHora: json['precoHora'],
    );
  }
}
