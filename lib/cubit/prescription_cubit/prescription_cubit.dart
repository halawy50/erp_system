import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_pvc/data/model/material_prescription_management_model.dart';
import 'package:system_pvc/data/model/prescription_management_model.dart';
import 'package:system_pvc/repo/prescription_management_repo.dart';
import 'prescription_state.dart';  // استيراد الـ state

class PrescriptionCubit extends Cubit<PrescriptionState> {
  final PrescriptionRepository prescriptionRepository;

  PrescriptionCubit(this.prescriptionRepository) : super(PrescriptionInitialState());

  // استرجاع جميع الوصفات مع المواد
  Future<void> loadAllPrescriptionsWithMaterials() async {
    emit(PrescriptionLoadingState());

    try {
      final prescriptions = await prescriptionRepository.getAllPrescriptionsWithMaterials();
      emit(PrescriptionLoadedState(prescriptions));
    } catch (e) {
      emit(PrescriptionErrorState("فشل في تحميل الوصفات: $e"));
    }
  }

  // استرجاع وصفة واحدة مع المواد المرتبطة بها
  Future<void> loadPrescriptionWithMaterials(int id) async {
    emit(PrescriptionLoadingState());

    try {
      final prescription = await prescriptionRepository.getPrescriptionWithMaterials(id);
      if (prescription != null) {
        emit(PrescriptionLoadedState([prescription]));
      } else {
        emit(PrescriptionErrorState("الوصفة غير موجودة"));
      }
    } catch (e) {
      emit(PrescriptionErrorState("فشل في تحميل الوصفة: $e"));
    }
  }

  // إضافة وصفة مع المواد المرتبطة بها
  Future<void> addPrescriptionWithMaterials(
      PrescriptionManagementModel prescription,
      List<MaterialPrescriptionManagementModel> materials,
      ) async {
    try {
      final id = await prescriptionRepository.insertPrescriptionWithMaterials(prescription, materials);
      if (id != 0) {
        loadAllPrescriptionsWithMaterials();  // إعادة تحميل الوصفات بعد إضافة جديدة
      } else {
        emit(PrescriptionErrorState("فشل في إضافة الوصفة"));
      }
    } catch (e) {
      emit(PrescriptionErrorState("فشل في إضافة الوصفة: $e"));
    }
  }

  // تحديث وصفة وموادها
  Future<void> updatePrescriptionWithMaterials(
      PrescriptionManagementModel prescription,
      List<MaterialPrescriptionManagementModel> materials,
      ) async {
    try {
      final updatedId = await prescriptionRepository.updatePrescriptionWithMaterials(prescription, materials);
      if (updatedId != 0) {
        loadAllPrescriptionsWithMaterials();  // إعادة تحميل الوصفات بعد التحديث
      } else {
        emit(PrescriptionErrorState("فشل في تحديث الوصفة"));
      }
    } catch (e) {
      emit(PrescriptionErrorState("فشل في تحديث الوصفة: $e"));
    }
  }

  // حذف وصفة وموادها
  Future<void> deletePrescriptionWithMaterials(int id) async {
    try {
      final deletedId = await prescriptionRepository.deletePrescriptionAndMaterials(id);
      if (deletedId != 0) {
        loadAllPrescriptionsWithMaterials();  // إعادة تحميل الوصفات بعد الحذف
      } else {
        emit(PrescriptionErrorState("فشل في حذف الوصفة"));
      }
    } catch (e) {
      emit(PrescriptionErrorState("فشل في حذف الوصفة: $e"));
    }
  }
}
