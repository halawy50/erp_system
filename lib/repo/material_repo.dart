import 'package:system_pvc/data/model/material_model.dart';
import 'package:system_pvc/local/material_database.dart';

class MaterialRepo {
  final MaterialDatabase _materialDatabase;

  MaterialRepo(this._materialDatabase);

  // إضافة خامة جديدة
  Future<bool> addMaterial(MaterialModel material) async {
    try {
      await _materialDatabase.insertMaterial(material);
      return true;
    } catch (e) {
      return false;
    }
  }

  // تحديث خامة
  Future<bool> updateMaterial(MaterialModel material) async {
    try {
      bool updateMaterial = await _materialDatabase.updateMaterial(material);
      if(updateMaterial){
        return true;
      }else{
        return false;
      }
    } catch (e) {
      return false;
    }
  }


  //اضافة كميات زيادة
  Future<bool> incrementMaterialQuantity(int materialId, double quantity) async {
    try {
      bool incrementMaterialQuantity = await _materialDatabase.incrementMaterialQuantity(materialId , quantity);
      if(incrementMaterialQuantity){
        return true;
      }else{
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  //تقليل كمية
  Future<bool> decrementMaterialQuantity(int materialId, double quantity) async {
    try {
      bool decrementMaterialQuantity = await _materialDatabase.decrementMaterialQuantity(materialId , quantity);
      if(decrementMaterialQuantity){
        return true;
      }else{
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // حذف خامة
  Future<bool> deleteMaterial(int materialId) async {
    try {
      await _materialDatabase.deleteMaterial(materialId);
      return true;
    } catch (e) {
      return false;
    }
  }


  // الحصول على جميع الخامات
  Future<List<MaterialModel>> getMaterials({int page = 1, int itemsPerPage = 10}) async {
    try {
      var data = await _materialDatabase.getMaterials(page: page, limit: itemsPerPage);
      print("Catch : ${data}");
      return data;

    } catch (e) {
      print("Catch : ${e}");
      return [];
    }
  }

  // الحصول على جميع الخامات
  Future<List<MaterialModel>> getAllMaterials() async {
    try {
      var data = await _materialDatabase.getAllMaterials();
      print("Catch : ${data}");
      return data;

    } catch (e) {
      print("Catch : ${e}");
      return [];
    }
  }

  // الحصول على خامة معينة
  Future<MaterialModel?> getMaterialById(int id) async {
    try {
      return await _materialDatabase.getMaterialById(id);
    } catch (e) {
      return null;
    }
  }

  Future<int> getTotalPages() async {
    try {
      int totalPage = await _materialDatabase.getTotalPages();

      print("getToalPageWar : ${totalPage}");
      return totalPage;
    } catch (e) {
      return 0;
    }
  }

  // تحديث إشعار الخامة
  Future<bool> updateAlert(int id, bool isAlerts, String alertsMessage) async {
    try {
      await _materialDatabase.updateAlert(id: id, isAlerts: isAlerts, alertsMessage: alertsMessage);
      return true;
    } catch (e) {
      return false;
    }
  }
}
