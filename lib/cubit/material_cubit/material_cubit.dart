import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_pvc/cubit/material_cubit/material_state.dart' as custom;
import 'package:system_pvc/cubit/material_cubit/material_state.dart';
import 'package:system_pvc/data/model/material_model.dart';
import 'package:system_pvc/repo/material_repo.dart';

class MaterialCubit extends Cubit<custom.MaterialsState> {
  final MaterialRepo materialRepo;

  MaterialCubit(this.materialRepo) : super(MaterialLoading());

  // تحميل المواد مع تصحيح الصفحات
  Future<void> fetchMaterials({int page = 1, int itemsPerPage = 10}) async {
    try {
      emit(MaterialLoading());
      final materials = await materialRepo.getMaterials(page: page, itemsPerPage: itemsPerPage);
      final totalPage = await materialRepo.getTotalPages(); // للحصول على عدد العناصر الإجمالي

      // print("Pages : ${totalPages} , totalItem : ${totalItems}");
      emit(MaterialLoaded(
        materials: materials,
        totalPages: totalPage,
        currentPage: page,
      ));
    } catch (e) {
      emit(MaterialError("حدث خطأ: $e"));
    }
  }

  Future<void> addMaterial(MaterialModel material) async {
    try {
      await materialRepo.addMaterial(material);
      fetchMaterials(); // تحديث القائمة بعد الإضافة
    } catch (e) {
      emit(custom.MaterialError('فشل في إضافة الخامة: $e'));
    }
  }

  Future<int> getAllMaterialCounter({int page = 1, int itemsPerPage = 10}) async {
    try {
      List<MaterialModel> materilList = await materialRepo.getMaterials(page: page);
      return materilList.length;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> updateMaterial(MaterialModel material) async {
    try {
      bool updateMaterial = await materialRepo.updateMaterial(material);
      if(updateMaterial){
        fetchMaterials();
        return true;
      }else{
        return false;
      }
    } catch (e) {
      emit(custom.MaterialError('فشل في تحديث الخامة: $e'));
      return false;
    }
  }

  Future<void> deleteMaterial(int id) async {
    try {
      await materialRepo.deleteMaterial(id);
    } catch (e) {
      emit(custom.MaterialError('فشل في حذف الخامة: $e'));
    }
  }
}
