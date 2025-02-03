class Transaction {
  final int id;
  final double monto;
  final DateTime fecha;
  final String descripcion;
  final String categoria;
  final String tipo; // "ingreso" o "gasto"

  Transaction({
    required this.id,
    required this.monto,
    required this.fecha,
    required this.descripcion,
    required this.categoria,
    required this.tipo,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'monto': monto,
        'fecha': fecha.toIso8601String(),
        'descripcion': descripcion,
        'categoria': categoria,
        'tipo': tipo,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        monto: json['monto'],
        fecha: DateTime.parse(json['fecha']),
        descripcion: json['descripcion'],
        categoria: json['categoria'],
        tipo: json['tipo'],
      );
}
