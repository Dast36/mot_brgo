import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import '../models/engine.dart';
import '../services/db_helper.dart';

class EngineRegistrationScreen extends StatefulWidget {
  @override
  _EngineRegistrationScreenState createState() => _EngineRegistrationScreenState();
}

class _EngineRegistrationScreenState extends State<EngineRegistrationScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registra nuovo motore'),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dati Principali', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  FormBuilderTextField(
                    name: 'id',
                    decoration: InputDecoration(
                      labelText: 'ID Motore',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'ID richiesto' : null,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: 12),
                  FormBuilderTextField(
                    name: 'brand',
                    decoration: InputDecoration(
                      labelText: 'Marca',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Marca richiesta' : null,
                  ),
                  SizedBox(height: 12),
                  FormBuilderTextField(
                    name: 'modelType',
                    decoration: InputDecoration(
                      labelText: 'Modello/Tipo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Modello richiesto' : null,
                  ),
                  SizedBox(height: 12),
                  FormBuilderTextField(
                    name: 'serialNumber',
                    decoration: InputDecoration(
                      labelText: 'Matricola',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Matricola richiesta' : null,
                  ),
                  SizedBox(height: 12),
                  FormBuilderTextField(
                    name: 'locationCode',
                    decoration: InputDecoration(
                      labelText: 'Codice Piazzamento',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  FormBuilderTextField(
                    name: 'form',
                    decoration: InputDecoration(
                      labelText: 'Forma',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  Text('Specifiche Tecniche', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  
                  FormBuilderTextField(
                    name: 'power',
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Potenza (kW)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Richiesto';
                      final cleanValue = value.replaceAll(',', '.');
                      if (double.tryParse(cleanValue) == null) return 'Valore non valido';
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  
                  FormBuilderTextField(
                    name: 'voltage',
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Tensione (V)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Richiesto';
                      if (int.tryParse(value) == null) return 'Valore non valido';
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  
                  FormBuilderTextField(
                    name: 'rmsCurrent',
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Corrente (A)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  FormBuilderTextField(
                    name: 'rpm',
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Giri/min',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Richiesto';
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  
                  FormBuilderTextField(
                    name: 'poles',
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Poli',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Richiesto';
                      if (int.tryParse(value) == null) return 'Valore non valido';
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  
                  FormBuilderTextField(
                    name: 'insulationClass',
                    decoration: InputDecoration(
                      labelText: 'Classe Isolamento',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  FormBuilderTextField(
                    name: 'protectionClass',
                    decoration: InputDecoration(
                      labelText: 'Protezione (IPxx)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  Text('Altri Dati', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  
                  FormBuilderTextField(
                    name: 'scaffoldCode',
                    decoration: InputDecoration(
                      labelText: 'Codice Scaffale',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  FormBuilderTextField(
                    name: 'orderCode',
                    decoration: InputDecoration(
                      labelText: 'Codice Ordine',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  FormBuilderTextField(
                    name: 'storageCode',
                    decoration: InputDecoration(
                      labelText: 'Codice Magazzino',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  Text('Data Entrata', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  
                  FormBuilderDateTimePicker(
                    name: 'entry_date',
                    inputType: InputType.date,
                    format: dateFormat,
                    initialValue: DateTime.now(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  Text('Stato', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  
                  FormBuilderDropdown(
                    name: 'status',
                    initialValue: 'in_stock',
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'in_stock', child: Text('In magazzino')),
                      DropdownMenuItem(value: 'shipped', child: Text('Spedito')),
                      DropdownMenuItem(value: 'in_transit', child: Text('In transito')),
                    ],
                  ),
                  
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          _submitForm();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                      ),
                      child: Text(
                        'REGISTRA MOTORE',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    final formData = _formKey.currentState?.value;
    if (formData == null) return;

    try {
      // Parse numeric values safely
      final power = double.tryParse(formData['power']?.toString().replaceAll(',', '.') ?? '0') ?? 0.0;
      final voltage = int.tryParse(formData['voltage']?.toString() ?? '0') ?? 0;
      final rpm = formData['rpm']?.toString() ?? '';
      final poles = int.tryParse(formData['poles']?.toString() ?? '0') ?? 0;
      
      // Parse optional rmsCurrent
      double? rmsCurrent;
      if (formData['rmsCurrent'] != null && formData['rmsCurrent'].toString().isNotEmpty) {
        rmsCurrent = double.tryParse(formData['rmsCurrent'].toString().replaceAll(',', '.'));
      }

      final newEngine = Engine(
        id: formData['id']?.toString() ?? '',
        brand: formData['brand']?.toString() ?? '',
        modelType: formData['modelType']?.toString() ?? '',
        serialNumber: formData['serialNumber']?.toString() ?? '',
        locationCode: formData['locationCode']?.toString() ?? '',
        form: formData['form']?.toString() ?? '',
        power: power,
        voltage: voltage,
        rmsCurrent: rmsCurrent,
        rpm: rpm,
        poles: poles,
        powerFactor: 0.0,
        insulationClass: formData['insulationClass']?.toString() ?? '',
        protectionClass: formData['protectionClass']?.toString() ?? '',
        scaffoldCode: formData['scaffoldCode']?.toString() ?? '',
        orderCode: formData['orderCode']?.toString() ?? '',
        storageCode: formData['storageCode']?.toString() ?? '',
        releaseDate: '',
        notes: '',
        status: formData['status']?.toString() ?? 'in_stock',
        entryDate: formData['entry_date'] is DateTime ? formData['entry_date'] as DateTime : DateTime.now(),
        exitDate: null,
      );

      DatabaseHelper.instance.insertEngine(newEngine);
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Motore registrato con successo!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nella registrazione: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}