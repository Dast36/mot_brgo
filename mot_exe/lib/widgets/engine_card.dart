import 'package:flutter/material.dart';
import '../models/engine.dart';         // Percorso relativo

class EngineCard extends StatelessWidget {
  final Engine engine;
  final VoidCallback onTap;

  const EngineCard({
    Key? key,
    required this.engine,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con informazioni principali
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: engine.currentType == CurrentType.ac 
                          ? Colors.blue.shade100 
                          : Colors.red.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      engine.currentType == CurrentType.ac 
                          ? Icons.electric_bolt 
                          : Icons.battery_charging_full,
                      color: engine.currentType == CurrentType.ac 
                          ? Colors.blue 
                          : Colors.red,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${engine.brand} - ${engine.modelType}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: engine.status == 'in_stock' 
                          ? Colors.green.shade100 
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      engine.status == 'in_stock' ? 'In magazzino' : 'Spedito',
                      style: TextStyle(
                        color: engine.status == 'in_stock' 
                            ? Colors.green 
                            : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 10),
              
              // Dati principali
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildInfoChip('S/N', engine.serialNumber),
                    SizedBox(width: 8),
                    _buildInfoChip('Loc', engine.locationCode),
                    SizedBox(width: 8),
                    _buildInfoChip('Forma', engine.form),
                  ],
                ),
              ),
              
              SizedBox(height: 12),
              
              // Specifiche tecniche
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTechSpec('Potenza', '${engine.power} kW'),
                    _buildTechSpec('Tensione', '${engine.voltage} V'),
                    _buildTechSpec('Giri', '${engine.rpm} RPM'),
                    if (engine.currentType == CurrentType.ac)
                      _buildTechSpec('Cos φ', engine.powerFactor.toStringAsFixed(2)),
                  ],
                ),
              ),
              
              SizedBox(height: 8),
              
              // Dettagli aggiuntivi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Poli: ${engine.poles}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Cl. Is.: ${engine.insulationClass}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Protez.: ${engine.protectionClass}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildTechSpec(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}