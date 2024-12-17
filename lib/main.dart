import 'package:flutter/material.dart';
import 'services/notificacion_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificacionService = NotificacionService();
  await notificacionService.inicializar();
  runApp(MyApp(notificacionService: notificacionService));
}

class MyApp extends StatelessWidget {
  final NotificacionService notificacionService;

  const MyApp({super.key, required this.notificacionService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recordatorio de Medicamentos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomeScreen(notificacionService: notificacionService),
    );
  }
}
