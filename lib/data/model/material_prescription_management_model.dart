class MaterialPrescriptionManagementModel {
  int idMaterialPrescriptionManagement;
  int fkPrescriptionManagement;
  int fkMaterial;
  double quntatyUse;
  bool isSelected;
  final DateTime createdAt;

  MaterialPrescriptionManagementModel({
    this.idMaterialPrescriptionManagement = 0,
    this.fkPrescriptionManagement = 0,
    this.fkMaterial = 0,
    this.quntatyUse = 0.0,
    this.isSelected = false,
    required this.createdAt,
  });

  // دالة copyWith لتحديث البيانات بسهولة
  MaterialPrescriptionManagementModel copyWith({
    int? idMaterialPrescriptionManagement,
    int? fkPrescriptionManagement,
    int? fkMaterial,
    double? quntatyUse,
    bool? isSelected,
    DateTime? createdAt,
  }) {
    return MaterialPrescriptionManagementModel(
      idMaterialPrescriptionManagement: idMaterialPrescriptionManagement ?? this.idMaterialPrescriptionManagement,
      fkPrescriptionManagement: fkPrescriptionManagement ?? this.fkPrescriptionManagement,
      fkMaterial: fkMaterial ?? this.fkMaterial,
      quntatyUse: quntatyUse ?? this.quntatyUse,
      isSelected: isSelected ?? this.isSelected,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // تحويل الموديل إلى خريطة (Map) لتخزينه في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'idMaterialPrescriptionManagement': idMaterialPrescriptionManagement,
      'fkPrescription': fkPrescriptionManagement,
      'fkMaterial': fkMaterial,
      'quntatyUse': quntatyUse,
      'isSelected': isSelected ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // تحويل الخريطة (Map) إلى موديل
  factory MaterialPrescriptionManagementModel.fromMap(Map<String, dynamic> map) {
    return MaterialPrescriptionManagementModel(
      idMaterialPrescriptionManagement: map['idMaterialPrescriptionManagement'],
      fkPrescriptionManagement: map['fkPrescription'],
      fkMaterial: map['fkMaterial'],
      quntatyUse: map['quntatyUse'],
      isSelected: map['isSelected'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
