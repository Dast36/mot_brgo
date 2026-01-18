import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/engine.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Getter database singleton
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Inizializzazione DB
  Future<Database> _initDB() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = join(directory.path, 'engines.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Creazione schema
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE engines (
        id TEXT PRIMARY KEY,
        brand TEXT NOT NULL,
        model_type TEXT NOT NULL,
        serial_number TEXT NOT NULL,
        location_code TEXT,
        form TEXT,
        power REAL NOT NULL,
        voltage INTEGER NOT NULL,
        rms_current REAL,
        rpm INTEGER NOT NULL,
        poles INTEGER NOT NULL,
        power_factor REAL NOT NULL,
        insulation_class TEXT,
        protection_class TEXT,
        scaffold_code TEXT,
        order_code TEXT,
        storage_code TEXT,
        release_date TEXT,
        notes TEXT,
        status TEXT NOT NULL,
        entry_date TEXT NOT NULL,
        exit_date TEXT
      )
    ''');
  }

  // INSERT
  Future<int> insertEngine(Engine engine) async {
    final db = await database;
    return await db.insert(
      'engines',
      engine.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // SELECT *
  Future<List<Engine>> getEngines() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('engines');

    return maps.map((e) => Engine.fromMap(e)).toList();
  }

  // DELETE ALL
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('engines');
  }

  // CLOSE
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
