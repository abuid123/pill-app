class Medicamento {
  final String id;
  final String nombre;
  final DateTime horaToma;
  final bool esRecurrente;
  bool tomado;

  Medicamento({
    required this.id,
    required this.nombre,
    required this.horaToma,
    required this.esRecurrente,
    this.tomado = false,
  });

  DateTime proximaToma() {
    if (!esRecurrente) return horaToma;
    
    final ahora = DateTime.now();
    DateTime proximaHora = DateTime(
      ahora.year,
      ahora.month,
      ahora.day,
      horaToma.hour,
      horaToma.minute,
    );

    if (proximaHora.isBefore(ahora)) {
      proximaHora = proximaHora.add(const Duration(days: 1));
    }

    return proximaHora;
  }
} 