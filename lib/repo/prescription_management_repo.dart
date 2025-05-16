import 'package:system_pvc/data/model/material_prescription_management_model.dart';
import 'package:system_pvc/data/model/prescription_management_model.dart';
import 'package:system_pvc/local/prescription_management_database/material_prescription_management_database.dart';
import 'package:system_pvc/local/prescription_management_database/prescription_management_database.dart';

class PrescriptionRepository {
  final PrescriptionManagementDatabase prescriptionDb;
  final MaterialPrescriptionManagementDatabase materialDb;

  PrescriptionRepository({
    required this.prescriptionDb,
    required this.materialDb,
  });

  /// تهيئة قاعدتي البيانات
  Future<bool> init() async {
    final p1 = await prescriptionDb.init();
    final p2 = await materialDb.init();
    return p1 == 1 && p2 == 1;
  }

  /// إدخال وصفة مع المواد المرتبطة بها (اختياري)
  Future<int> insertPrescriptionWithMaterials(
      PrescriptionManagementModel prescription,
      List<MaterialPrescriptionManagementModel> materials,
      ) async {
    final id = await prescriptionDb.insertPrescription(prescription);
    if (id == 0) return 0;

    for (final material in materials) {
      await materialDb.insertMaterial(
        material.copyWith(fkPrescriptionManagement: id),
      );
    }
    return id;
  }

  /// استرجاع وصفة واحدة مع المواد المرتبطة بها
  Future<PrescriptionManagementModel?> getPrescriptionWithMaterials(int id) async {
    final allPrescriptions = await prescriptionDb.getAllPrescriptionManagement();
    final prescription = allPrescriptions.firstWhere(
          (element) => element.id == id,
      orElse: () => PrescriptionManagementModel(id: 0, name: '', createdAt: DateTime.now()),
    );

    if (prescription.id == 0) return null;

    final materials = await materialDb.getMaterialsByPrescription(id);

    return prescription.copyWith(materials: materials);
  }

  /// استرجاع كل الوصفات مع المواد
  Future<List<PrescriptionManagementModel>> getAllPrescriptionsWithMaterials() async {
    final prescriptions = await prescriptionDb.getAllPrescriptionManagement();
    final result = <PrescriptionManagementModel>[];

    for (final prescription in prescriptions) {
      final materials = await materialDb.getMaterialsByPrescription(prescription.id!);
      print("Fuck : ${materials}");
      result.add(prescription.copyWith(materials: materials));
    }
    return result;
  }

  Future<List<MaterialPrescriptionManagementModel>> getMaterialsByPrescription(int fkPrescription) async {
   return await materialDb.getMaterialsByPrescription(fkPrescription);
  }
  /// تحديث وصفة وموادها
  Future<bool> updatePrescriptionWithMaterials(
      PrescriptionManagementModel prescription,
      List<MaterialPrescriptionManagementModel> materials,
      ) async {
    final updatedId = await prescriptionDb.updatePrescription(prescription);
    if (updatedId == 0) return false;

    // حذف المواد القديمة ثم إدخال الجديدة (أو يمكنك استخدام update لكل واحدة)
    final oldMaterials = await materialDb.getMaterialsByPrescription(updatedId);
    for (final old in oldMaterials) {
      await materialDb.deleteMaterial(old.idMaterialPrescriptionManagement!);
    }
    for (final material in materials) {
      await materialDb.insertMaterial(
        material.copyWith(fkPrescriptionManagement: updatedId),
      );
    }
    print("Reuslt : ${updatedId}");
    return updatedId==0?false:true;
  }

  /// حذف وصفة وموادها المرتبطة
  Future<int> deletePrescriptionAndMaterials(int id) async {
    final materials = await materialDb.getMaterialsByPrescription(id);
    for (final material in materials) {
      await materialDb.deleteMaterial(material.idMaterialPrescriptionManagement!);
    }
    return await prescriptionDb.deletePrescription(id);
  }

  void close() {
    prescriptionDb.close();
    materialDb.close();
  }
}
