import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'services/excel_importer.dart';
import 'services/db_helper.dart';
import 'services/excel_exporter.dart'; // Aggiungi questa importazione
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inizializza sqflite_ffi per Windows
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;  // <-- aggiungi questa riga  
  }
  
  // Inizializza database
  final db = DatabaseHelper.instance;
  
  // Controlla se il database è vuoto
  final engines = await db.getEngines();
  if (engines.isEmpty) {
    // Carica solo se il database è vuoto
    final excelEngines = await ExcelImporter.loadEnginesFromExcel();
    for (var engine in excelEngines) {
      await db.insertEngine(engine);
    }
  }
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestione Motori',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Aggiungi questo per esportare quando l'app si chiude
class HomeScreenWithExport extends StatefulWidget {
  @override
  _HomeScreenWithExportState createState() => _HomeScreenWithExportState();
}

class _HomeScreenWithExportState extends State<HomeScreenWithExport> {
  @override
  void dispose() {
    // Esporta i dati nel file Excel quando l'app si chiude
    _exportData();
    super.dispose();
  }
  
  Future<void> _exportData() async {
    final db = DatabaseHelper.instance;
    final engines = await db.getEngines();
    await ExcelExporter.exportEnginesToExcel(engines);
  }
  
  @override
  Widget build(BuildContext context) {
    return HomeScreen();
  }
}