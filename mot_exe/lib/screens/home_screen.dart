import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';

import '../models/engine.dart';
import '../services/db_helper.dart';
import '../services/excel_exporter.dart';
import 'engine_registration_screen.dart';
import 'inventory_action_screen.dart';
import '../widgets/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Engine> engines = [];
  List<Engine> filteredEngines = [];
  
  // Campi di ricerca
  TextEditingController marcaController = TextEditingController();
  TextEditingController tipoController = TextEditingController();
  TextEditingController matricolaController = TextEditingController();
  TextEditingController formaController = TextEditingController();
  TextEditingController kwController = TextEditingController();
  TextEditingController vController = TextEditingController();
  TextEditingController aController = TextEditingController();
  TextEditingController giriController = TextEditingController();
  TextEditingController poliController = TextEditingController();
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DatabaseHelper.instance.getEngines();
    setState(() {
      engines = data;
      filteredEngines = data;
    });
  }

  void _applySearch() {
    setState(() {
      filteredEngines = engines.where((engine) {
        bool matches = true;
        
        if (marcaController.text.isNotEmpty) {
          matches &= engine.brand.toLowerCase().contains(marcaController.text.toLowerCase());
        }
        
        if (tipoController.text.isNotEmpty) {
          matches &= engine.modelType.toLowerCase().contains(tipoController.text.toLowerCase());
        }
        
        if (matricolaController.text.isNotEmpty) {
          matches &= engine.serialNumber.toLowerCase().contains(matricolaController.text.toLowerCase());
        }
        
        if (formaController.text.isNotEmpty) {
          matches &= engine.form.toLowerCase().contains(formaController.text.toLowerCase());
        }
        
        if (kwController.text.isNotEmpty) {
          matches &= engine.power.toString().contains(kwController.text);
        }
        
        if (vController.text.isNotEmpty) {
          matches &= engine.voltage.toString().contains(vController.text);
        }
        
        if (aController.text.isNotEmpty) {
          matches &= engine.rmsCurrent != null && engine.rmsCurrent.toString().contains(aController.text);
        }
        
        if (giriController.text.isNotEmpty) {
          matches &= engine.rpm.toString().contains(giriController.text);
        }
        
        if (poliController.text.isNotEmpty) {
          matches &= engine.poles.toString().contains(poliController.text);
        }
        
        if (_statusFilter != null) {
          if (_statusFilter == 'in_stock') {
            matches &= engine.status == 'in_stock';
          } else if (_statusFilter == 'shipped') {
            matches &= engine.status == 'shipped';
          }
        }
        
        return matches;
      }).toList();
    });
  }

  // Funzione per creare e salvare PDF
  Future<void> _createAndSavePDF() async {
    try {
      // Mostra dialog di caricamento
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Creazione PDF in corso...'),
            ],
          ),
        ),
      );

      print('🔄 Iniziando generazione PDF...');
      
      // Crea il PDF
      final pdf = await _generatePDF();
      
      print('✅ PDF generato con successo');
      
      // Ottieni la directory dei download
      Directory? downloadsDirectory;
      if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'];
        print('📁 USERPROFILE: $userProfile');
        
        if (userProfile != null) {
          downloadsDirectory = Directory(path.join(userProfile, 'Downloads'));
          print('📁 Directory download: ${downloadsDirectory.path}');
          
          // Crea la directory se non esiste
          if (!downloadsDirectory.existsSync()) {
            downloadsDirectory.createSync(recursive: true);
            print('📁 Directory creata');
          }
        }
      } else if (Platform.isAndroid) {
        downloadsDirectory = await getExternalStorageDirectory();
      } else {
        downloadsDirectory = await getDownloadsDirectory();
      }
      
      if (downloadsDirectory == null) {
        downloadsDirectory = await getApplicationDocumentsDirectory();
        print('📁 Usando directory documenti: ${downloadsDirectory.path}');
      }
      
      // Crea il nome file
      final now = DateTime.now();
      final fileName = 'Lista_Motori_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.pdf';
      final filePath = '${downloadsDirectory.path}/$fileName';
      
      print('📄 Salvando PDF in: $filePath');
      
      // Salva il PDF
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      
      print('✅ PDF salvato con successo');
      
      Navigator.of(context).pop();
      
      // Mostra dialog con opzioni
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('PDF Creato'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Il file è stato salvato in:'),
                SizedBox(height: 8),
                SelectableText(
                  filePath,
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
                SizedBox(height: 16),
                Text('Motori nel PDF: ${filteredEngines.length}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('CHIUDI'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openPDF(filePath);
              },
              child: Text('APRI PDF'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showPrintDialog(pdf);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
              ),
              child: Text('STAMPA'),
            ),
          ],
        ),
      );

    } catch (e, stackTrace) {
      print('❌ Errore PDF: $e');
      print('Stack trace: $stackTrace');
      
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Funzione per aprire il PDF
  Future<void> _openPDF(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossibile aprire il file PDF'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nell\'apertura del PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Funzione per mostrare dialog di stampa
  Future<void> _showPrintDialog(pw.Document pdf) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Lista_Motori_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nella stampa: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Funzione per generare il PDF - VERSIONE CORRETTA
  Future<pw.Document> _generatePDF() async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final formattedDate = '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}';
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            // Intestazione
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'LISTA MOTORI',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Data: $formattedDate'),
                      pw.Text('Totale: ${filteredEngines.length} motori'),
                    ],
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),
            
            // Tabella dei motori
            pw.Table.fromTextArray(
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: pw.TextStyle(fontSize: 9),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
                7: pw.Alignment.center,
              },
              headerPadding: pw.EdgeInsets.all(8),
              cellPadding: pw.EdgeInsets.all(6),
              headers: ['MARCA', 'TIPO', 'KW', 'V', 'FORMA', 'GIRI', 'POLI', 'LOCATION'],
              data: filteredEngines.map((engine) => [
                engine.brand,
                engine.modelType,
                engine.power.toStringAsFixed(2),
                engine.voltage.toString(),
                engine.form.isNotEmpty ? engine.form : '-',
                engine.rpm.toString(),
                engine.poles.toString(),
                engine.locationCode ?? '-',
              ]).toList(),
            ),
            
            pw.SizedBox(height: 30),
            
            // Footer
            pw.Center(
              child: pw.Text(
                'Documento generato il $formattedDate',
                style: pw.TextStyle(fontSize: 8),
              ),
            ),
          ];
        },
      ),
    );
    
    return pdf;
  }

  // Funzione per esportare in Excel
  Future<void> _exportToExcel() async {
    try {
      final db = DatabaseHelper.instance;
      final engines = await db.getEngines();
      await ExcelExporter.exportEnginesToExcel(engines);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dati esportati in engines_updated.xlsx')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore esportazione: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Gestione Motori',
        onRefresh: _loadData,
      ),
      body: Container(
        color: Colors.grey[100]!,
        child: Column(
          children: [
            // Barra di ricerca avanzata
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildSearchField('MARCA', marcaController, 140),
                    SizedBox(width: 8),
                    _buildSearchField('TIPO', tipoController, 140),
                    SizedBox(width: 8),
                    _buildSearchField('MATRICOLA', matricolaController, 140),
                    SizedBox(width: 8),
                    _buildSearchField('FORMA', formaController, 120),
                    SizedBox(width: 8),
                    _buildNumberSearchField('KW', kwController, 100, true),
                    SizedBox(width: 8),
                    _buildNumberSearchField('V', vController, 100, false),
                    SizedBox(width: 8),
                    _buildNumberSearchField('A', aController, 100, true),
                    SizedBox(width: 8),
                    _buildNumberSearchField('GIRI', giriController, 110, false),
                    SizedBox(width: 8),
                    _buildNumberSearchField('POLI', poliController, 100, false),
                    SizedBox(width: 8),
                    
                    // Campo STATO
                    Container(
                      width: 180,
                      child: DropdownButtonFormField<String>(
                        value: _statusFilter,
                        decoration: InputDecoration(
                          labelText: 'STATO',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(value: null, child: Text('TUTTI')),
                          DropdownMenuItem(value: 'in_stock', child: Text('IN MAGAZZINO')),
                          DropdownMenuItem(value: 'shipped', child: Text('IN USO')),
                        ],
                        onChanged: (value) {
                          setState(() { _statusFilter = value; });
                          _applySearch();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Pulsanti azioni rapide
            Container(
              color: Colors.grey[100],
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  // Pulsante REG/SC
                  Expanded(
                    child: Container(
                      height: 40,
                      margin: EdgeInsets.only(right: 4),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Azioni Registro/Scarico'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.check_circle, color: Colors.green),
                                    title: Text('Registra in magazzino'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      if (filteredEngines.isNotEmpty) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => InventoryActionScreen(
                                              engine: filteredEngines.firstWhere(
                                                (e) => e.status == 'shipped',
                                                orElse: () => filteredEngines.first,
                                              ),
                                              isReceiving: true,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.exit_to_app, color: Colors.red),
                                    title: Text('Scarico da magazzino'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      if (filteredEngines.isNotEmpty) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => InventoryActionScreen(
                                              engine: filteredEngines.firstWhere(
                                                (e) => e.status == 'in_stock',
                                                orElse: () => filteredEngines.first,
                                              ),
                                              isReceiving: false,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('ANNULLA'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: Icon(Icons.list_alt),
                        label: Text('REG/SC'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  // Pulsante CREA PDF
                  Expanded(
                    child: Container(
                      height: 40,
                      margin: EdgeInsets.only(left: 4),
                      child: ElevatedButton.icon(
                        onPressed: _createAndSavePDF,
                        icon: Icon(Icons.picture_as_pdf),
                        label: Text('CREA PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  // Pulsante ESPORTA
                  Expanded(
                    child: Container(
                      height: 40,
                      margin: EdgeInsets.only(left: 4),
                      child: ElevatedButton.icon(
                        onPressed: _exportToExcel,
                        icon: Icon(Icons.file_download),
                        label: Text('ESPORTA'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 8),
            
            // Statistiche
            Container(
              color: Colors.blue[50]!,
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('Totale', engines.length.toString(), Icons.inventory),
                  _buildStatCard('In magazzino', 
                    engines.where((e) => e.status == 'in_stock').length.toString(), 
                    Icons.check_circle),
                  _buildStatCard('In uso', 
                    engines.where((e) => e.status == 'shipped').length.toString(), 
                    Icons.exit_to_app),
                ],
              ),
            ),
            SizedBox(height: 8),
            
            // Lista motori
            Expanded(
              child: filteredEngines.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Nessun motore trovato',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: filteredEngines.length,
                      itemBuilder: (context, index) {
                        return _buildEngineCard(filteredEngines[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EngineRegistrationScreen()),
        ).then((_) => _loadData()),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[800]!,
      ),
    );
  }

  Widget _buildSearchField(String label, TextEditingController controller, double width) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, size: 16),
                  onPressed: () {
                    controller.clear();
                    _applySearch();
                  },
                )
              : null,
          border: OutlineInputBorder(),
        ),
        onChanged: (_) => _applySearch(),
      ),
    );
  }

  Widget _buildNumberSearchField(String label, TextEditingController controller, 
      double width, bool decimal) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, size: 16),
                  onPressed: () {
                    controller.clear();
                    _applySearch();
                  },
                )
              : null,
          border: OutlineInputBorder(),
        ),
        keyboardType: decimal 
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        onChanged: (_) => _applySearch(),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[800], size: 24),
        SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        Text(value, style: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold, 
          color: Colors.blue[900]
        )),
      ],
    );
  }

  Widget _buildEngineCard(Engine engine) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: _getStatusColor(engine.status),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  engine.brand,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusBackgroundColor(engine.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    engine.status == 'in_stock' ? 'IN MAGAZZINO' : 'IN USO',
                    style: TextStyle(
                      color: _getStatusTextColor(engine.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            Divider(color: Colors.grey[300]!, height: 20),
            
            Column(
              children: [
                _buildSpecRow('MODEL TYPE', engine.modelType),
                _buildSpecRow('SERIAL NUMBER', engine.serialNumber),
                _buildSpecRow('LOCATION CODE', engine.locationCode ?? '-'),
                SizedBox(height: 8),
                
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Table(
                    border: TableBorder(
                      horizontalInside: BorderSide(color: Colors.grey[300]!),
                      verticalInside: BorderSide(color: Colors.grey[300]!),
                    ),
                    columnWidths: {
                      0: FlexColumnWidth(1.5),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.blue[50]!,
                        ),
                        children: [
                          _buildTableCell('PARAMETRO', isHeader: true),
                          _buildTableCell('VALORE', isHeader: true),
                          _buildTableCell('PARAMETRO', isHeader: true),
                          _buildTableCell('VALORE', isHeader: true),
                        ],
                      ),
                      TableRow(
                        children: [
                          _buildTableCell('Potenza (kW)'),
                          _buildTableCell('${engine.power}'),
                          _buildTableCell('Tensione (V)'),
                          _buildTableCell('${engine.voltage}'),
                        ],
                      ),
                      TableRow(
                        children: [
                          _buildTableCell('RPM'),
                          _buildTableCell('${engine.rpm}'),
                          _buildTableCell('Poli'),
                          _buildTableCell('${engine.poles}'),
                        ],
                      ),
                      TableRow(
                        children: [
                          _buildTableCell('Corrente (A)'),
                          _buildTableCell(engine.rmsCurrent?.toString() ?? '-'),
                          _buildTableCell('Classe Isol.'),
                          _buildTableCell(engine.insulationClass),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 12),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem('ID:', engine.id),
                    _buildInfoItem('Forma:', engine.form),
                    _buildInfoItem('Data ingresso:', _formatDate(engine.entryDate)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'in_stock') {
      return Colors.green[500]!;
    } else {
      return Colors.orange[500]!;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    if (status == 'in_stock') {
      return Colors.green[100]!;
    } else {
      return Colors.orange[100]!;
    }
  }

  Color _getStatusTextColor(String status) {
    if (status == 'in_stock') {
      return Colors.green[700]!;
    } else {
      return Colors.orange[700]!;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
          color: isHeader ? Colors.blue[900]! : Colors.grey[800]!,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}