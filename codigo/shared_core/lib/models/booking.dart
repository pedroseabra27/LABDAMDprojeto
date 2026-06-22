class Booking {
  final int id;
  final int quadraId;
  final int clienteId;
  final int? prestadorId;
  final DateTime horarioInicio;
  final String status;

  Booking({
    required this.id,
    required this.quadraId,
    required this.clienteId,
    this.prestadorId,
    required this.horarioInicio,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      quadraId: json['quadraId'],
      clienteId: json['clienteId'],
      prestadorId: json['prestadorId'],
      horarioInicio: DateTime.parse(json['horarioInicio']),
      status: json['status'],
    );
  }

  Booking copyWith({
    int? id,
    int? quadraId,
    int? clienteId,
    int? prestadorId,
    DateTime? horarioInicio,
    String? status,
  }) {
    return Booking(
      id: id ?? this.id,
      quadraId: quadraId ?? this.quadraId,
      clienteId: clienteId ?? this.clienteId,
      prestadorId: prestadorId ?? this.prestadorId,
      horarioInicio: horarioInicio ?? this.horarioInicio,
      status: status ?? this.status,
    );
  }
}
