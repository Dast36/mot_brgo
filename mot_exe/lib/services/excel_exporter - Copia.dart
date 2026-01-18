import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/engine.dart';

class ExcelExporter {
  static Future<void> exportEnginesToExcel(List<Engine> engines) async {
    try {
      final excel = Excel.createExcel();

      final inStockEngines =
          engines.where((e) => e.status == 'in_stock').toList();
      final shippedEngines =
          engines.where((e) => e.status == 'shipped').toList();

      _createSheet(excel, 'In Magazzino', inStockEngines);
      _createSheet(excel, 'In Uso', shippedEngines);

      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(directory.path, 'engines_updated.xlsx');

      final bytes = excel.encode();
      if (bytes == null) {
        throw Exception('Errore generazione file Excel');
      }

      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      print('File Excel salvato in: $filePath');
    } catch (e) {
      print('Errore durante l\'esportazione Excel: $e');
    }
  }

  static void _createSheet(
      Excel excel, String sheetName, List<Engine> engines) {
    final sheet = excel[sheetName];

    // Intestazioni
    final headers = [
      'MARCA',
      'TIPO',
      'MATRICOLA',
      'FORMA',
      'KW',
      'V',
      'GIRI',
      'POLI',
      'LOCATION CODE',
    ];

    for (int col = 0; col < headers.length; col++) {
      sheet
          .cell(CellIndex.indexByColumnRow(
            columnIndex: col,
            rowIndex: 0,
          ))
          .value = headers[col];
    }

    // Dati
    for (int i = 0; i < engines.length; i++) {
      final e = engines[i];
      final rowIndex = i + 1;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = e.brand;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = e.modelType;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = e.serialNumber;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = e.form;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = e.power;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = e.voltage;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
          .value = e.rpm;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
          .value = e.poles;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
          .value = e.locationCode ?? '';
    }
  }
}
