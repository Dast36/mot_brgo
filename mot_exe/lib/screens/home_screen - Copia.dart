import 'package:flutter/material.dart';
import '../models/engine.dart';
import '../services/db_helper.dart';
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
  String? _statusFilter; // Filtro stato

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
        
        // Cerca per MARCA
        if (marcaController.text.isNotEmpty) {
          matches &= engine.brand.toLowerCase().contains(marcaController.text.toLowerCase());
        }
        
        // Cerca per TIPO
        if (tipoController.text.isNotEmpty) {
          matches &= engine.modelType.toLowerCase().contains(tipoController.text.toLowerCase());
        }
        
        // Cerca per MATRICOLA
        if (matricolaController.text.isNotEmpty) {
          matches &= engine.serialNumber.toLowerCase().contains(matricolaController.text.toLowerCase());
        }
        
        // Cerca per FORMA
        if (formaController.text.isNotEmpty) {
          matches &= engine.form.toLowerCase().contains(formaController.text.toLowerCase());
        }
        
        // Cerca per KW (Potenza)
        if (kwController.text.isNotEmpty) {
          matches &= engine.power.toString().contains(kwController.text);
        }
        
        // Cerca per V (Tensione)
        if (vController.text.isNotEmpty) {
          matches &= engine.voltage.toString().contains(vController.text);
        }
        
        // Cerca per A (Corrente)
        if (aController.text.isNotEmpty) {
          matches &= engine.rmsCurrent != null && engine.rmsCurrent.toString().contains(aController.text);
        }
        
        // Cerca per GIRI
        if (giriController.text.isNotEmpty) {
          matches &= engine.rpm.toString().contains(giriController.text);
        }
        
        // Cerca per POLI
        if (poliController.text.isNotEmpty) {
          matches &= engine.poles.toString().contains(poliController.text);
        }
        
        // Filtro per STATO (In uso / In magazzino)
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
            // Barra di ricerca avanzata - Una sola riga
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Campo MARCA
                    SizedBox(
                      width: 140,
                      child: TextField(
                        controller: marcaController,
                        decoration: InputDecoration(
                          labelText: 'MARCA',
                          suffixIcon: marcaController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    marcaController.clear();
                                    _applySearch();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _applySearch(),
                      ),
                    ),
                    
                    SizedBox(width: 8),
                    
                    // Campo TIPO
                    SizedBox(
                      width: 140,
                      child: TextField(
                        controller: tipoController,
                        decoration: InputDecoration(
                          labelText: 'TIPO',
                          suffixIcon: tipoController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    tipoController.clear();
                                    _applySearch();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _applySearch(),
                      ),
                    ),
                    
                    SizedBox(width: 8),
                    
                    // Campo MATRICOLA
                    SizedBox(
                      width: 140,
                      child: TextField(
                        controller: matricolaController,
                        decoration: InputDecoration(
                          labelText: 'MATRICOLA',
                          suffixIcon: matricolaController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    matricolaController.clear();
                                    _applySearch();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _applySearch(),
                      ),
                    ),
                    
                    SizedBox(width: 8),
                    
                    // Campo FORMA
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: formaController,
                        decoration: InputDecoration(
                          labelText: 'FORMA',
                          suffixIcon: formaController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    formaController.clear();
                                    _applySearch();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _applySearch(),
                      ),
                    ),
                    
                    SizedBox(width: 8),
                    
                    // Campo KW
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: kwController,
                        decoration: InputDecoration(
                          labelText: 'KW',
                          suffixIcon: kwController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    kwController.clear();
                                    _applySearch();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => _applySearch(),
                      ),
                    ),
                    
                    SizedBox(width: 8),
                    
                    // Campo V
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: vController,
                        decoration: InputDecoration(
                          labelText: 'V',
                          suffixIcon: vController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    vController.clear();
                                    _applySearch();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _applySearch(),
                      ),
                    ),
                    
                    SizedBox(width: 8),
                    
                    // Campo A
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: aController,
                        decoration: InputDecoration(
                          labelText: 'A',
                          suffixIcon: aController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    aController.clear();
                                    _applySearch();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => _applySearch(),
                      ),
                    ),
                    
                    SizedBox(width: 8),
                    
                    // Campo GIRI
                    SizedBox(
                      width: 110,
                      child: TextField(
                        controller: giriController,
                        decoration: InputDecoration(
                          labelText: 'GIRI',
                          suffixIcon: giriController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    giriController.clear();
                                    _applySearch();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _applySearch(),
                      ),
                    ),
                    
                    SizedBox(width: 8),
                    
                    // Campo POLI
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: poliController,
                        decoration: InputDecoration(
                          labelText: 'POLI',
                          suffixIcon: poliController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    poliController.clear();
                                    _applySearch();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _applySearch(),
                      ),
                    ),
                    
                    SizedBox(width: 8),
                    
                    // Campo STATO (In uso / In magazzino)
                    Container(
                      width: 180, // Allargato da 160 a 180
                      child: DropdownButtonFormField<String>(
                        value: _statusFilter,
                        decoration: InputDecoration(
                          labelText: 'STATO',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text('TUTTI'),
                          ),
                          DropdownMenuItem(
                            value: 'in_stock',
                            child: Text('IN MAGAZZINO'),
                          ),
                          DropdownMenuItem(
                            value: 'shipped',
                            child: Text('IN USO'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _statusFilter = value;
                          });
                          _applySearch();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Statistiche in alto
            Container(
              color: Colors.blue[50]!,
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('Totale', engines.length.toString(), Icons.inventory),
                  _buildStatCard('In magazzino', 
                    engines.where((e) => e.status == 'in_stock').length.toString(), 
                    Icons.check_circle
                  ),
                  _buildStatCard('In uso', 
                    engines.where((e) => e.status == 'shipped').length.toString(), 
                    Icons.exit_to_app
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            
            // Lista delle schede tecniche
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: filteredEngines.length,
                itemBuilder: (context, index) {
                  final engine = filteredEngines[index];

                  return _buildEngineCard(engine);
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
    return GestureDetector(
      onTap: () => _showInventoryActions(context, engine),
      child: Container(
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
              // Intestazione con titolo e stato
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
              
              // Specifiche in stile tabella
              Column(
                children: [
                  _buildSpecRow('MODEL TYPE', engine.modelType),
                  _buildSpecRow('SERIAL NUMBER', engine.serialNumber),
                  _buildSpecRow('LOCATION CODE', engine.locationCode ?? '-'),
                  SizedBox(height: 8),
                  
                  // Tabella con i parametri
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
                        // Intestazione tabella
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
                        // Righe dati
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
                  
                  // Informazioni aggiuntive in orizzontale
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

  void _showInventoryActions(BuildContext context, Engine engine) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AZIONI DISPONIBILI',
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 18,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('Registra in magazzino'),
                subtitle: Text('Registra l\'ingresso del motore'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InventoryActionScreen(engine: engine, isReceiving: true),
                  ),
                ).then((_) => _loadData()),
              ),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.red),
                title: Text('Scarico da magazzino'),
                subtitle: Text('Registra l\'uscita del motore'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InventoryActionScreen(engine: engine, isReceiving: false),
                  ),
                ).then((_) => _loadData()),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CHIUDI'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}