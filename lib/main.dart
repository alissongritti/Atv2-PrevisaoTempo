import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'screens/home_screen.dart';
import 'services/cptec_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa formatação de datas em Português do Brasil (pt_BR)
  await initializeDateFormatting('pt_BR', null);
  Intl.defaultLocale = 'pt_BR';

  // Inicializa o serviço de persistência local (SharedPreferences)
  final storageService = await StorageService.init();
  final cptecService = CptecService();

  runApp(PrevisaoTempoApp(
    cptecService: cptecService,
    storageService: storageService,
  ));
}

/// Aplicativo principal de Previsão do Tempo CPTEC/INPE
class PrevisaoTempoApp extends StatelessWidget {
  final CptecService cptecService;
  final StorageService storageService;

  const PrevisaoTempoApp({
    super.key,
    required this.cptecService,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Previsão do Tempo CPTEC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo.shade700,
          secondary: Colors.blueAccent,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.indigo.shade700,
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 1.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: HomeScreen(
        cptecService: cptecService,
        storageService: storageService,
      ),
    );
  }
}
