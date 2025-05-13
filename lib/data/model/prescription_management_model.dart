import 'package:system_pvc/data/model/material_prescription_management_model.dart';

class PrescriptionManagementModel {
  int? id;
  String name;
  DateTime createdAt;
  List<MaterialPrescriptionManagementModel>? materials; // إضافة هذا الحقل لاحتواء المواد المرتبطة

  PrescriptionManagementModel({
    this.id,
    required this.name,
    required this.createdAt,
    this.materials, // تعيين المواد المرتبطة
  });

  // دالة copyWith لتحديث البيانات بسهولة
  PrescriptionManagementModel copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    List<MaterialPrescriptionManagementModel>? materials,
  }) {
    return PrescriptionManagementModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      materials: materials ?? this.materials,
    );
  }

  // تحويل الموديل إلى خريطة (Map) لتخزينه في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'materialId': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // تحويل الخريطة (Map) إلى موديل
  factory PrescriptionManagementModel.fromMap(Map<String, dynamic> map) {
    return PrescriptionManagementModel(
      id: map['materialId'],
      name: map['name'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
