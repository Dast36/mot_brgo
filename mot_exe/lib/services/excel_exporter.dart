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

      final bytes = excel.encode() as List<int>;
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      print('File Excel salvato in: $filePath');
    } catch (e) {
      print('Errore durante l\'esportazione Excel: $e');
    }
  }

  static void _createSheet(
      Excel excel, String sheetName, List<Engine> engines) {
    final sheet = excel[sheetName];

    if (sheet != null) {
      // Intestazioni - usa CellIndex.indexByString
      sheet.cell(CellIndex.indexByString('A1')).value = 'MARCA';
      sheet.cell(CellIndex.indexByString('B1')).value = 'TIPO';
      sheet.cell(CellIndex.indexByString('C1')).value = 'MATRICOLA';
      sheet.cell(CellIndex.indexByString('D1')).value = 'FORMA';
      sheet.cell(CellIndex.indexByString('E1')).value = 'KW';
      sheet.cell(CellIndex.indexByString('F1')).value = 'V';
      sheet.cell(CellIndex.indexByString('G1')).value = 'GIRI';
      sheet.cell(CellIndex.indexByString('H1')).value = 'POLI';
      sheet.cell(CellIndex.indexByString('I1')).value = 'LOCATION CODE';

      // Dati
      for (int i = 0; i < engines.length; i++) {
        final e = engines[i];
        final row = i + 2; // Parte dalla riga 2

        sheet.cell(CellIndex.indexByString('A$row')).value = e.brand;
        sheet.cell(CellIndex.indexByString('B$row')).value = e.modelType;
        sheet.cell(CellIndex.indexByString('C$row')).value = e.serialNumber;
        sheet.cell(CellIndex.indexByString('D$row')).value = e.form;
        sheet.cell(CellIndex.indexByString('E$row')).value = e.power.toString();
        sheet.cell(CellIndex.indexByString('F$row')).value = e.voltage.toString();
        sheet.cell(CellIndex.indexByString('G$row')).value = e.rpm.toString();
        sheet.cell(CellIndex.indexByString('H$row')).value = e.poles.toString();
        sheet.cell(CellIndex.indexByString('I$row')).value = e.locationCode ?? '';
      }
    }
  }
}