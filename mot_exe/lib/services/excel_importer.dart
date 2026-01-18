import 'package:flutter/services.dart';
import 'package:excel/excel.dart';
import '../models/engine.dart';

class ExcelImporter {
  static Future<List<Engine>> loadEnginesFromExcel() async {
    final bytes = await rootBundle.load('assets/engines.xlsx');
    final excel = Excel.decodeBytes(bytes.buffer.asUint8List());
    final engines = <Engine>[];

    for (var sheetName in excel.tables.keys) {
      var rows = excel.tables[sheetName]!.rows;

      int headerRowIndex = -1;
      for (int i = 0; i < rows.length; i++) {
        var row = rows[i];
        if (row.isNotEmpty && row[0] != null) {
          var cellValue = _getCellValue(row[0]);
          if (cellValue.toLowerCase().contains('marca')) {
            headerRowIndex = i;
            break;
          }
        }
      }
      if (headerRowIndex == -1) headerRowIndex = 0;

      for (int i = headerRowIndex + 1; i < rows.length; i++) {
        var row = rows[i];
        if (row.isEmpty || _getCellValue(row[0]).isEmpty) continue;

        try {
          String marca = _getSafeCellValue(row, 0);
          String tipo = _getSafeCellValue(row, 1);
          String matricola = _getSafeCellValue(row, 2);
          String forma = _getSafeCellValue(row, 3);
          String kw = _getSafeCellValue(row, 4);
          String v = _getSafeCellValue(row, 5);
          String a = _getSafeCellValue(row, 6);
          String giri = _getSafeCellValue(row, 7);
          String poli = _getSafeCellValue(row, 8);
          String clIs = _getSafeCellValue(row, 9);
          String ip = _getSafeCellValue(row, 10);
          String scaff = _getSafeCellValue(row, 11);
          String codOff = _getSafeCellValue(row, 12);
          String codMag = _getSafeCellValue(row, 13);
          String dataPrelievo = _getSafeCellValue(row, 14);
          String note = _getSafeCellValue(row, 15);

          if (marca.isNotEmpty || tipo.isNotEmpty || matricola.isNotEmpty) {
            engines.add(Engine(
                id: (codMag.isEmpty ? matricola : codMag).toString(),
                brand: marca.toString(),
                modelType: tipo.toString(),
                serialNumber: matricola.toString(),
                locationCode: scaff.toString(),
                form: forma.toString(),
                power: _parseDouble(kw),
                voltage: v.toString(), // qui: sempre String
                rmsCurrent: _parseDouble(a) != 0 ? _parseDouble(a) : null,
                rpm: giri.toString(),
                poles: _parseInt(poli),
                powerFactor: 0.0,
                insulationClass: clIs.toString(),
                protectionClass: ip.toString(),
                scaffoldCode: scaff.toString(),
                orderCode: codOff.toString(),
                storageCode: codMag.toString(),
                releaseDate: dataPrelievo.toString(),
                notes: note.toString(),
                status: _determineStatus(dataPrelievo).toString(),
                entryDate: DateTime.now(),
                exitDate: null,
              ));

          }
        } catch (e) {
          print("Errore nel foglio '$sheetName', riga $i - $e");
          continue;
        }
      }
    }
    return engines;
  }

  static String _getCellValue(dynamic cell) {
    if (cell == null) return '';
    if (cell is Data) {
      if (cell.value == null) return '';
      if (cell.value is DateTime) {
        return (cell.value as DateTime).toIso8601String();
      } else {
        return cell.value.toString().trim();
      }
    }
    if (cell is DateTime) {
      return cell.toIso8601String();
    }
    return cell.toString().trim();
  }

  static String _getSafeCellValue(List<dynamic> row, int index) {
    if (index >= 0 && index < row.length && row[index] != null) {
      return _getCellValue(row[index]);
    }
    return '';
  }

  static double _parseDouble(String value) {
    if (value.isEmpty) return 0.0;
    if (value.contains('/')) {
      value = value.split('/')[0];
    }
    value = value.replaceAll(RegExp(r'[^\d,.]'), '');
    if (value.isEmpty) return 0.0;
    value = value.replaceAll(',', '.');
    final result = double.tryParse(value);
    return result ?? 0.0;
  }

  static int _parseInt(String value) {
    if (value.isEmpty) return 0;
    value = value.replaceAll(RegExp(r'[^\d]'), '');
    if (value.isEmpty) return 0;
    final result = int.tryParse(value);
    return result ?? 0;
  }

  static String _determineStatus(String value) {
    if (value.isEmpty) return 'in_stock';
    final date = DateTime.tryParse(value);
    if (date != null) {
      return 'shipped';
    }
    final datePattern = RegExp(r'\b(\d{1,2})[/.-](\d{1,2})[/.-](\d{2,4})\b');
    if (datePattern.hasMatch(value)) {
      return 'shipped';
    }
    if (value.trim().isNotEmpty) {
      return 'shipped';
    }
    return 'in_stock';
  }
}
