class Engine {
  final String id;
  final String brand;
  final String modelType;
  final String serialNumber;
  final String locationCode;
  final String form;
  final double power;
  final String voltage; // cambiato da int a String
  final double? rmsCurrent;
  final String rpm; // già String
  final int poles;
  final double powerFactor;
  final String insulationClass;
  final String protectionClass;
  final String scaffoldCode;
  final String orderCode;
  final String storageCode;
  final String releaseDate;
  final String notes;
  final String status;
  final DateTime entryDate;
  final DateTime? exitDate;

  Engine({
    required this.id,
    required this.brand,
    required this.modelType,
    required this.serialNumber,
    required this.locationCode,
    required this.form,
    required this.power,
    required this.voltage,
    this.rmsCurrent,
    required this.rpm,
    required this.poles,
    required this.powerFactor,
    required this.insulationClass,
    required this.protectionClass,
    required this.scaffoldCode,
    required this.orderCode,
    required this.storageCode,
    required this.releaseDate,
    required this.notes,
    required this.status,
    required this.entryDate,
    this.exitDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model_type': modelType,
      'serial_number': serialNumber,
      'location_code': locationCode,
      'form': form,
      'power': power,
      'voltage': voltage, // salva come stringa
      'rms_current': rmsCurrent,
      'rpm': rpm,
      'poles': poles,
      'power_factor': powerFactor,
      'insulation_class': insulationClass,
      'protection_class': protectionClass,
      'scaffold_code': scaffoldCode,
      'order_code': orderCode,
      'storage_code': storageCode,
      'release_date': releaseDate,
      'notes': notes,
      'status': status,
      'entry_date': entryDate.toIso8601String(),
      'exit_date': exitDate?.toIso8601String(),
    };
  }

  static Engine fromMap(Map<String, dynamic> map) {
    return Engine(
      id: map['id'],
      brand: map['brand'],
      modelType: map['model_type'],
      serialNumber: map['serial_number'],
      locationCode: map['location_code'],
      form: map['form'],
      power: double.parse(map['power'].toString().replaceAll(',', '.')),
      voltage: map['voltage'].toString(), // converti sempre in stringa
      rmsCurrent: map['rms_current'] != null ? double.parse(map['rms_current'].toString()) : null,
      rpm: map['rpm'].toString(),
      poles: map['poles'],
      powerFactor: double.parse(map['power_factor'].toString().replaceAll(',', '.')),
      insulationClass: map['insulation_class'],
      protectionClass: map['protection_class'],
      scaffoldCode: map['scaffold_code'],
      orderCode: map['order_code'],
      storageCode: map['storage_code'],
      releaseDate: map['release_date'],
      notes: map['notes'],
      status: map['status'],
      entryDate: DateTime.parse(map['entry_date']),
      exitDate: map['exit_date'] != null ? DateTime.parse(map['exit_date']) : null,
    );
  }
}