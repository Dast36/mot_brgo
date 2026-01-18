import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/engine.dart';
import '../services/db_helper.dart';

class InventoryActionScreen extends StatefulWidget {
  final Engine engine;
  final bool isReceiving; // true = registrazione in magazzino, false = scarico

  InventoryActionScreen({required this.engine, required this.isReceiving});

  @override
  _InventoryActionScreenState createState() => _InventoryActionScreenState();
}

class _InventoryActionScreenState extends State<InventoryActionScreen> {
  final dateFormat = DateFormat('dd/MM/yyyy');
  DateTime? _actionDate;
  String? _note;

  @override
  void initState() {
    super.initState();
    _actionDate = DateTime.now();
  }

  Future<void> _saveAction() async {
    if (_actionDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seleziona una data'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Engine updatedEngine;
    if (widget.isReceiving) {
      // Registra l'entrata in magazzino
      updatedEngine = Engine(
        id: widget.engine.id,
        brand: widget.engine.brand,
        modelType: widget.engine.modelType,
        serialNumber: widget.engine.serialNumber,
        locationCode: widget.engine.locationCode,
        form: widget.engine.form,
        power: widget.engine.power,
        voltage: widget.engine.voltage,
        rmsCurrent: widget.engine.rmsCurrent,
        rpm: widget.engine.rpm,
        poles: widget.engine.poles,
        powerFactor: widget.engine.powerFactor,
        insulationClass: widget.engine.insulationClass,
        protectionClass: widget.engine.protectionClass,
        scaffoldCode: widget.engine.scaffoldCode,
        orderCode: widget.engine.orderCode,
        storageCode: widget.engine.storageCode,
        releaseDate: widget.engine.releaseDate,
        notes: widget.engine.notes,
        status: 'in_stock',
        entryDate: _actionDate!,
        exitDate: widget.engine.exitDate,
      );
    } else {
      // Registra lo scarico
      updatedEngine = Engine(
        id: widget.engine.id,
        brand: widget.engine.brand,
        modelType: widget.engine.modelType,
        serialNumber: widget.engine.serialNumber,
        locationCode: widget.engine.locationCode,
        form: widget.engine.form,
        power: widget.engine.power,
        voltage: widget.engine.voltage,
        rmsCurrent: widget.engine.rmsCurrent,
        rpm: widget.engine.rpm,
        poles: widget.engine.poles,
        powerFactor: widget.engine.powerFactor,
        insulationClass: widget.engine.insulationClass,
        protectionClass: widget.engine.protectionClass,
        scaffoldCode: widget.engine.scaffoldCode,
        orderCode: widget.engine.orderCode,
        storageCode: widget.engine.storageCode,
        releaseDate: _actionDate!.toIso8601String(),
        notes: _note ?? '',
        status: 'shipped',
        entryDate: widget.engine.entryDate,
        exitDate: _actionDate,
      );
    }

    await DatabaseHelper.instance.insertEngine(updatedEngine);
    Navigator.pop(context, true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isReceiving 
            ? 'Motore registrato in magazzino' 
            : 'Motore scaricato con successo'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isReceiving 
            ? 'Registra in magazzino' 
            : 'Scarico da magazzino'),
        backgroundColor: widget.isReceiving ? Colors.green : Colors.red,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Intestazione con dati del motore
            Card(
              color: widget.isReceiving ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dettagli Motore',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: widget.isReceiving ? Colors.green : Colors.red,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('ID: ${widget.engine.id}'),
                    Text('Marca: ${widget.engine.brand}'),
                    Text('Modello: ${widget.engine.modelType}'),
                    Text('Matricola: ${widget.engine.serialNumber}'),
                    Text('Potenza: ${widget.engine.power} kW'),
                    Text('Tensione: ${widget.engine.voltage} V'),
                    Text('Giri: ${widget.engine.rpm}'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Sezione data
            Text(
              'Data ${widget.isReceiving ? 'entrata' : 'uscita'}:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _actionDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => _actionDate = date);
                }
              },
              child: Text(
                _actionDate != null ? dateFormat.format(_actionDate!) : 'Seleziona data',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            ),
            
            SizedBox(height: 10),
            
            // Note aggiuntive
            Text(
              'Note aggiuntive:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              onChanged: (value) => _note = value,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Inserisci note aggiuntive...',
              ),
            ),
            
            SizedBox(height: 30),
            
            // Pulsante di conferma
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAction,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: widget.isReceiving ? Colors.green : Colors.red,
                ),
                child: Text(
                  widget.isReceiving ? 'REGISTRA ENTRATA' : 'SCARICA MOTORE',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}