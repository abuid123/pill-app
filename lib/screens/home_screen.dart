import 'package:flutter/material.dart';
import '../models/medicamento.dart';
import '../services/notificacion_service.dart';

class HomeScreen extends StatefulWidget {
  final NotificacionService notificacionService;

  const HomeScreen({super.key, required this.notificacionService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _medicamentoController = TextEditingController();
  DateTime _horaToma = DateTime.now();
  final List<Medicamento> _medicamentos = [];
  bool _esRecurrente = false;

  Future<void> _programarNotificacion() async {
    if (_medicamentoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa el nombre del medicamento')),
      );
      return;
    }

    final medicamento = Medicamento(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: _medicamentoController.text,
      horaToma: _horaToma,
      esRecurrente: _esRecurrente,
    );

    await widget.notificacionService.programarNotificacion(
      medicamento.nombre,
      medicamento.proximaToma(),
    );

    setState(() {
      _medicamentos.add(medicamento);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notificación programada con éxito')),
      );
      _medicamentoController.clear();
      setState(() {
        _esRecurrente = false;
      });
    }
  }

  void _marcarComoTomado(Medicamento medicamento) async {
    setState(() {
      medicamento.tomado = true;
    });

    // Si es recurrente, programar la siguiente toma para mañana
    if (medicamento.esRecurrente) {
      // Esperamos un segundo antes de programar la siguiente toma
      await Future.delayed(const Duration(seconds: 1));
      
      // Creamos un nuevo medicamento para el día siguiente
      final nuevoMedicamento = Medicamento(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: medicamento.nombre,
        horaToma: medicamento.horaToma.add(const Duration(days: 1)),
        esRecurrente: true,
      );

      await widget.notificacionService.programarNotificacion(
        nuevoMedicamento.nombre,
        nuevoMedicamento.proximaToma(),
      );

      // Agregamos el nuevo medicamento a la lista
      setState(() {
        _medicamentos.add(nuevoMedicamento);
      });
    }
  }

  Future<void> _seleccionarHora() async {
    final TimeOfDay? tiempo = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_horaToma),
    );

    if (tiempo != null) {
      setState(() {
        final now = DateTime.now();
        _horaToma = DateTime(
          now.year,
          now.month,
          now.day,
          tiempo.hour,
          tiempo.minute,
        );
        
        if (_horaToma.isBefore(now)) {
          _horaToma = _horaToma.add(const Duration(days: 1));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorio de Medicamentos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _medicamentoController,
              decoration: const InputDecoration(
                labelText: 'Nombre del medicamento',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _seleccionarHora,
                    child: Text(
                      'Hora: ${TimeOfDay.fromDateTime(_horaToma).format(context)}',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    const Text('Toma diaria'),
                    Switch(
                      value: _esRecurrente,
                      onChanged: (value) {
                        setState(() {
                          _esRecurrente = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _programarNotificacion,
              child: const Text('Programar Recordatorio'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Medicamentos Programados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _medicamentos.length,
                itemBuilder: (context, index) {
                  final medicamento = _medicamentos[index];
                  return Card(
                    child: ListTile(
                      title: Text(medicamento.nombre),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hora: ${TimeOfDay.fromDateTime(medicamento.horaToma).format(context)}',
                          ),
                          if (medicamento.esRecurrente)
                            const Text(
                              'Toma diaria',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      trailing: medicamento.tomado
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : TextButton(
                              onPressed: () => _marcarComoTomado(medicamento),
                              child: const Text('Marcar como tomado'),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _medicamentoController.dispose();
    super.dispose();
  }
} 