import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'services/excel_importer.dart';
import 'services/db_helper.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inizializza sqflite_ffi per Windows
  if (Platform.isWindows || Platform.isLinux) {
    databaseFactory = databaseFactoryFfi;
  }
  
  // Inizializza database
  final engines = await ExcelImporter.loadEnginesFromExcel();
  final db = DatabaseHelper.instance;
  
  // Pulisce e popola il database
  await db.clearDatabase();
  for (var engine in engines) {
    await db.insertEngine(engine);
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