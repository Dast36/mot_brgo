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
      // Intestazioni - usa coordinate Excel standard
      sheet.cell('A1').value = 'MARCA';
      sheet.cell('B1').value = 'TIPO';
      sheet.cell('C1').value = 'MATRICOLA';
      sheet.cell('D1').value = 'FORMA';
      sheet.cell('E1').value = 'KW';
      sheet.cell('F1').value = 'V';
      sheet.cell('G1').value = 'GIRI';
      sheet.cell('H1').value = 'POLI';
      sheet.cell('I1').value = 'LOCATION CODE';

      // Dati
      for (int i = 0; i < engines.length; i++) {
        final e = engines[i];
        final row = i + 2; // Parte dalla riga 2

        sheet.cell('A$row').value = e.brand;
        sheet.cell('B$row').value = e.modelType;
        sheet.cell('C$row').value = e.serialNumber;
        sheet.cell('D$row').value = e.form;
        sheet.cell('E$row').value = e.power.toString();
        sheet.cell('F$row').value = e.voltage.toString();
        sheet.cell('G$row').value = e.rpm.toString();
        sheet.cell('H$row').value = e.poles.toString();
        sheet.cell('I$row').value = e.locationCode ?? '';
      }
    }
  }
}