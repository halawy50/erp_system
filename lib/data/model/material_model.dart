class MaterialModel {
  int materialId;
  String materialName;
  double quantityAvailable;
  double minimum;
  bool isAlerts;
  String alertsMessage;
  final DateTime createdAt;

  // دالة لتقريب الرقم إلى 3 أرقام بعد الفاصلة
  double roundTo3(double value) {
    return double.parse(value.toStringAsFixed(3));
  }

  MaterialModel({
    this.materialId = 0,
    this.materialName = 'غير محدد',
    double quantityAvailable = 0.0,
    double minimum = 0.0,
    this.isAlerts = false,
    this.alertsMessage = 'لا توجد رسائل تنبيه',
    DateTime? createdAt,
  })  : quantityAvailable = double.parse(quantityAvailable.toStringAsFixed(3)),
        minimum = double.parse(minimum.toStringAsFixed(3)),
        createdAt = createdAt ?? DateTime.now();

  MaterialModel copyWith({
    int? materialId,
    String? materialName,
    double? quantityAvailable,
    double? minimum,
    bool? isAlerts,
    String? alertsMessage,
  }) {
    return MaterialModel(
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      quantityAvailable: quantityAvailable != null
          ? double.parse(quantityAvailable.toStringAsFixed(3))
          : this.quantityAvailable,
      minimum: minimum != null
          ? double.parse(minimum.toStringAsFixed(3))
          : this.minimum,
      isAlerts: isAlerts ?? this.isAlerts,
      alertsMessage: alertsMessage ?? this.alertsMessage,
      createdAt: createdAt,
    );
  }

  factory MaterialModel.empty() {
    return MaterialModel(materialId: 0, quantityAvailable: 0.0);
  }
}
