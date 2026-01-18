import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/engine.dart';

class ExcelImporter {
  static Future<List<Engine>> loadEnginesFromExcel() async {
    final bytes = await rootBundle.load('assets/engines.xlsx');
    final excel = Excel.decodeBytes(bytes.buffer.asUint8List());
    final engines = <Engine>[];

    for (var sheetName in excel.tables.keys) {
      // Ottieni tutte le righe del foglio
      var rows = excel.tables[sheetName]!.rows;
      
      // Trova l'indice della riga di intestazione (cerca "MARCA")
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

      // Se non trova la riga di intestazione, continua con la prima riga
      if (headerRowIndex == -1) headerRowIndex = 0;

      // Processa le righe dati (quelle dopo l'intestazione)
      for (int i = headerRowIndex + 1; i < rows.length; i++) {
        var row = rows[i];
        
        // Salta righe vuote o incomplete
        if (row.isEmpty || _getCellValue(row[0]).isEmpty) {
          continue;
        }

        try {
          // Ottieni i valori dalle colonne specifiche usando la funzione helper
          String marca = _getSafeCellValue(row, 0);
          String tipo = _getSafeCellValue(row, 1);
          String matricola = _getSafeCellValue(row, 2);
          String forma = _getSafeCellValue(row, 3);
          String kw = _getSafeCellValue(row, 4);
          String v = _getSafeCellValue(row, 5);
          String a = _getSafeCellValue(row, 6);
          String giri = _parseRangeOrNumber(_getSafeCellValue(row, 7));
          String poli = _getSafeCellValue(row, 8);
          String clIs = _getSafeCellValue(row, 9);
          String ip = _getSafeCellValue(row, 10);
          String scaff = _getSafeCellValue(row, 11);
          String codOff = _getSafeCellValue(row, 12);
          String codMag = _getSafeCellValue(row, 13);
          String dataPrelievo = _getSafeCellValue(row, 14);
          String note = _getSafeCellValue(row, 15);

          // Crea l'oggetto Engine solo se ha almeno alcuni dati significativi
          if (marca.isNotEmpty || tipo.isNotEmpty || matricola.isNotEmpty) {
            engines.add(Engine(
              id: codMag.isEmpty ? matricola : codMag, // Usa COD.MAG. come ID se disponibile, altrimenti MATRICOLA
              brand: marca,
              modelType: tipo,
              serialNumber: matricola,
              locationCode: scaff,
              form: forma,
              power: _parseDouble(kw),
              voltage: _parseInt(v),
              rmsCurrent: _parseDouble(a) != 0 ? _parseDouble(a) : null,
              rpm: _parseInt(giri),
              poles: _parseInt(poli),
              powerFactor: 0.0, // Cos φ - non presente nel tuo file
              insulationClass: clIs,
              protectionClass: ip,
              scaffoldCode: scaff,
              orderCode: codOff,
              storageCode: codMag,
              releaseDate: dataPrelievo,
              notes: note,
              status: _determineStatus(dataPrelievo),
              entryDate: DateTime.now(), // Imposta data corrente per ora
              exitDate: null, // Non presente nel tuo file
            ));
          }
        } catch (e) {
          print("Errore nel foglio '$sheetName', riga $i - $e");
          continue; // Salta la riga problematica
        }
      }
    }
    return engines;
  }

  // Metodo helper per ottenere il valore di una cella in modo sicuro
  static String _getCellValue(dynamic cell) {
    if (cell == null) return '';
    
    // Gestisci oggetti Data del package excel
    if (cell is Data) {
      if (cell.value == null) return '';
      // Gestisci diversi tipi di valore
      if (cell.value is DateTime) {
        return (cell.value as DateTime).toIso8601String();
      } else {
        return cell.value.toString().trim();
      }
    }
    
    // Gestisci direttamente i valori se non sono oggetti Data
    if (cell is DateTime) {
      return cell.toIso8601String();
    }
    
    return cell.toString().trim();
  }

  // Metodo helper per ottenere valore da cella con gestione null safety
  static String _getSafeCellValue(List<dynamic> row, int index) {
    if (index >= 0 && index < row.length && row[index] != null) {
      return _getCellValue(row[index]);
    }
    return '';
  }

  // Metodo helper per convertire stringa a double
  static double _parseDouble(String value) {
    if (value.isEmpty) return 0.0;
    
    // Gestisce valori come "1/0,33" o "0,8-NM"
    if (value.contains('/')) {
      // Prende la prima parte prima dello slash
      value = value.split('/')[0];
    }
    
    // Rimuove testo e tiene solo numeri
    value = value.replaceAll(RegExp(r'[^\d,.]'), '');
    if (value.isEmpty) return 0.0;
    
    // Sostituisce virgola con punto
    value = value.replaceAll(',', '.');
    final result = double.tryParse(value);
    return result ?? 0.0;
  }

  // Metodo helper per convertire stringa a int
  static int _parseInt(String value) {
    if (value.isEmpty) return 0;
    
    // Rimuove testo e tiene solo numeri
    value = value.replaceAll(RegExp(r'[^\d]'), '');
    if (value.isEmpty) return 0;
    
    final result = int.tryParse(value);
    return result ?? 0;
  }

  // Metodo helper per determinare lo stato dal campo data prelievo
  static String _determineStatus(String value) {
    if (value.isEmpty) return 'in_stock';
    
    // Controlla se la stringa contiene una data
    // Prima prova il parsing diretto
    final date = DateTime.tryParse(value);
    if (date != null) {
      return 'shipped'; // Oppure 'in_use' a seconda della logica aziendale
    }
    
    // Se non è una data ISO, prova a cercare pattern di date italiane (GG/MM/AAAA)
    final datePattern = RegExp(r'\b(\d{1,2})[/.-](\d{1,2})[/.-](\d{2,4})\b');
    if (datePattern.hasMatch(value)) {
      return 'shipped';
    }
    
    // Se c'è del testo ma non una data chiara
    if (value.trim().isNotEmpty) {
      return 'shipped';
    }
    
    return 'in_stock';
  }
}