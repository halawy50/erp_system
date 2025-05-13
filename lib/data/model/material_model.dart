class MaterialModel {
  int materialId;
  String materialName;
  double quantityAvailable;
  double minimum;
  bool isAlerts;
  String alertsMessage;
  final DateTime createdAt;


  MaterialModel({
    this.materialId = 0,
    this.materialName = 'غير محدد',
    this.quantityAvailable = 0.0,
    this.minimum = 0.0,
    this.isAlerts = false,
    this.alertsMessage = 'لا توجد رسائل تنبيه',
    DateTime? createdAt,


  }) : createdAt = createdAt ?? DateTime.now(); // تعيين القيمة الافتراضية للـ createdAt إذا لم يتم تحديده



}
