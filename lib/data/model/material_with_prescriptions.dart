// material_prescription_calculation.dart

import 'package:flutter/material.dart';
import 'package:system_pvc/components/tableWarehouseMangment.dart';
import 'package:system_pvc/data/model/material_model.dart';
import 'package:system_pvc/data/model/material_prescription_management_model.dart';
import 'package:system_pvc/data/model/prescription_management_model.dart';

/// نموذج لعرض معلومات الخامة مع كميات الخلطات المتاحة
class MaterialWithPrescriptions {
  final MaterialModel material;
  final Map<String, PrescriptionCalculation> prescriptionsCalculations;

  MaterialWithPrescriptions({
    required this.material,
    required this.prescriptionsCalculations,
  });
}

/// نموذج لعرض حسابات الخلطة
class PrescriptionCalculation {
  final PrescriptionManagementModel prescription;
  final MaterialPrescriptionManagementModel materialInPrescription;
  final int possibleBatches; // عدد الخلطات الممكنة من هذه المادة

  PrescriptionCalculation({
    required this.prescription,
    required this.materialInPrescription,
    required this.possibleBatches,
  });
}

/// حساب عدد الخلطات الممكنة لكل مادة
List<MaterialWithPrescriptions> calculateMaterialsWithPrescriptions({
  required List<MaterialModel> materials,
  required List<PrescriptionManagementModel> prescriptions,
}) {
  List<MaterialWithPrescriptions> result = [];

  // نعالج كل مادة على حدة
  for (final material in materials) {
    Map<String, PrescriptionCalculation> prescriptionCalcs = {};

    // نمر على كل وصفة لنرى إذا كانت تستخدم هذه المادة
    for (final prescription in prescriptions) {
      // نبحث عن المادة في هذه الوصفة
      MaterialPrescriptionManagementModel? materialInPrescription;

      if (prescription.materials != null) {
        materialInPrescription = prescription.materials!.firstWhere(
              (m) => m.fkMaterial == material.materialId,
          orElse: () => MaterialPrescriptionManagementModel(
            fkMaterial: 0,
            quntatyUse: 0,
            createdAt: DateTime.now(),
          ),
        );
      }

      // إذا وجدت المادة في الوصفة ولها كمية أكبر من الصفر
      if (materialInPrescription != null &&
          materialInPrescription.fkMaterial == material.materialId &&
          materialInPrescription.quntatyUse > 0) {

        // نحسب عدد الخلطات الممكنة من هذه المادة
        int possibleBatches = (material.quantityAvailable / materialInPrescription.quntatyUse).floor();

        // نخزن النتيجة
        prescriptionCalcs[prescription.id.toString()] = PrescriptionCalculation(
          prescription: prescription,
          materialInPrescription: materialInPrescription,
          possibleBatches: possibleBatches,
        );
      }
    }

    // نضيف المادة مع حسابات الخلطات للنتيجة
    result.add(MaterialWithPrescriptions(
      material: material,
      prescriptionsCalculations: prescriptionCalcs,
    ));
  }

  return result;
}

String getCellValueForPrescription(MaterialWithPrescriptions materialWithPrescriptions, String prescriptionId) {
  final calc = materialWithPrescriptions.prescriptionsCalculations[prescriptionId];
  if (calc == null) return "-";

  return "${calc.possibleBatches} خلطة (${calc.materialInPrescription.quntatyUse} كجم/خلطة)";
}

// تحديث Widget الخاص بعرض الجدول لإضافة عدد الخلطات الممكنة
Widget tableWareHouseManagementWithPrescriptions({
  required Map<String, String> headers,
  required List<PrescriptionManagementModel> prescriptions,
  required List<MaterialWithPrescriptions> materialsWithPrescriptions,
  void Function(int index)? onEdit,
  void Function(int index)? onDelete,
}) {
  // بناء رؤوس الأعمدة للخلطات
  List<Map<String, String>> headersPrescription = prescriptions.map((p) {
    return {p.id.toString(): p.name}; // <-- تأكد من استخدام toString()
  }).toList();

  // إعداد صفوف البيانات
  List<Map<String, String>> rowsMaterial = materialsWithPrescriptions.map((materialWithPrescriptions) {
    final material = materialWithPrescriptions.material;
    Map<String, String> row = {
      "id": material.materialId.toString(),
      "materialName": material.materialName,
      "quantityAvailable": "${material.quantityAvailable} كجم",
      "minimum": "${material.minimum} كجم",
      "alerts": material.alertsMessage,
    };

    for (final prescription in prescriptions) {
      row[prescription.id.toString()] = getCellValueForPrescription(
        materialWithPrescriptions,
        prescription.id.toString(),
      );
    }

    return row;
  }).toList();

  return tableWareHouseManagement(
    headers: headers,
    headersPrescription: headersPrescription,
    rowsMaterial: rowsMaterial,
    onEdit: onEdit,
    onDelete: onDelete,
  );
}
