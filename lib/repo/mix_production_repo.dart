import 'package:system_pvc/data/model/material_model.dart';
import 'package:system_pvc/data/model/material_prescription_management_model.dart';
import 'package:system_pvc/data/model/mix_productions_model.dart';
import 'package:system_pvc/data/model/prescription_management_model.dart';
import 'package:system_pvc/local/mix_productions_database.dart';
import 'package:system_pvc/repo/material_repo.dart';
import 'package:system_pvc/repo/prescription_management_repo.dart';

class MixProductionRepo {
  final MixProductionsDatabase _database;
  final MaterialRepo materialRepo;
  final PrescriptionRepository prescriptionRepo;

  // يمكن الحصول على مثيل قاعدة البيانات من خلال dependency injection
  // أو تهيئته مباشرة داخل الـ Repo
  MixProductionRepo(this._database , this.materialRepo , this.prescriptionRepo);

  // إنشاء مثيل جديد مع تهيئة قاعدة البيانات
  Future<void> init() async {
    await _database.init();
  }

  // جلب الخلطات مع دعم الفلترة والتصفح
  Future<List<MixProductionModel>> getMixProductions({
    int page = 1,
    int limit = 10,
  }) async {
    return await _database.getMixProductions(
      page: page,
      limit: limit,
    );
  }

  Future<List<MixProductionModel>> getAllCountMixProductionsUserFilter(
      String startDateSend,
      String endDateSend,
      List<int> fkPrescription,
      List<int> fkEmployee, {
        int page = 1,
        int limit = 10,
      }) async {
    return await _database.getAllCountMixProductionsUserFilter(
      startDateSend,
      endDateSend,
      fkPrescription,
      fkEmployee,
      page: page,
      limit: limit,
    );
  }

  Future<int> getTotalMixProduction(
      String startDateSend,
      String endDateSend,
      List<int> fkPrescription,
      List<int> fkEmployee,
      ) async {
    try {
      int totalMixProductions = await _database.getTotalQuantityMixProduction(
        startDateSend,
        endDateSend,
        fkPrescription,
        fkEmployee,
      );
      if(totalMixProductions>0){
        return totalMixProductions;
      }else{
        return 0;
      }
    }catch(e){
      return 0;
    }
  }

    Future<int> getTotalPages() async {
    try {
      int totalPage = await _database.getTotalPages();
      print("getToalPage : ${totalPage}");
      return totalPage;
    } catch (e) {
      return 0;
    }
  }


  Future<List<PrescriptionManagementModel>> getAllPrescriptions () async {
    List<PrescriptionManagementModel> prescriptionList =await prescriptionRepo.getAllPrescriptionsWithMaterials();
    // PrescriptionManagementModel prescriptionId = prescriptionList[1];
    // int? pre = prescriptionId.id;
    return prescriptionList;
  }

  Future<int> getAvailablePrescription(int pre) async {
    List<int> availablePrescriptionList = [];
    List<MaterialModel> materialList = await materialRepo.getAllMaterials();
    PrescriptionManagementModel? prescription = await prescriptionRepo.getPrescriptionWithMaterials(pre);
    List<MaterialPrescriptionManagementModel>? materialPrescriptionList = prescription?.materials;
    if (materialPrescriptionList == null){
      print("RRRR EROR: ${materialList}");
      return 0;
    }

    for (var materialPrescription in materialPrescriptionList) {
      int fkMaterial = materialPrescription.fkMaterial;

      // البحث عن المادة المناسبة
      MaterialModel? matchedMaterial = materialList.firstWhere(
            (element) => element.materialId == fkMaterial,
        orElse: () => MaterialModel.empty(), // أو null لو المادة غير موجودة
      );

      if (matchedMaterial.materialId == null) continue; // تجاهل لو لم توجد المادة

      // حساب الكمية المتاحة من الوصفة بناءً على الكمية المتوفرة
      int quantityAvailable = (matchedMaterial.quantityAvailable /
          materialPrescription.quntatyUse)
          .floor();

      print("Calcuation ( quantityAvailable = ${matchedMaterial.quantityAvailable} / ${materialPrescription.quntatyUse} = "
          " ${quantityAvailable})");


      availablePrescriptionList.add(quantityAvailable);
    }
    int minNumber = availablePrescriptionList.reduce((a, b) => a < b ? a : b);

    print("RRRR : ${minNumber}");

    return minNumber;
  }


  // إدخال خلطة جديدة
  Future<bool> insertMixProduction(MixProductionModel mixProduction) async {

    bool isMixProductionInserted = await _database.insertMixProduction(mixProduction);

    print("before : ${prescriptionRepo.getMaterialsByPrescription(mixProduction.fkPrescription)}\n");
    if(isMixProductionInserted){
      List<MaterialPrescriptionManagementModel> materialPrescriptionList =
      await prescriptionRepo.getMaterialsByPrescription(mixProduction.fkPrescription);
      for(MaterialPrescriptionManagementModel material in materialPrescriptionList){
        materialRepo.decrementMaterialQuantity(material.fkMaterial, (material.quntatyUse * mixProduction.quantityMixProductions));
      }
      print("after : ${prescriptionRepo.getMaterialsByPrescription(mixProduction.fkPrescription)}");
      return true;
    }
    print("فشل");
    return isMixProductionInserted;
  }

  // جلب خلطة محددة بواسطة المعرف
  Future<MixProductionModel?> getMixProductionById(int id) async {
    return await _database.getMixProductionById(id);
  }


  // تحديث معلومات خلطة
  Future<bool> updateMixProduction(MixProductionModel mixProduction , int currentQuantity) async {
    if(currentQuantity==mixProduction.quantityMixProductions)
      {
        print("mixProduction : ${mixProduction}");

        return await _database.updateMixProduction(mixProduction);
      }
    //اذا كان عمليية الانتاج اقل من العدد القديم
    else if(currentQuantity>mixProduction.quantityMixProductions){
      print("mixProduction_before : ${mixProduction.quantityMixProductions}");

      int differenceNumber = currentQuantity-mixProduction.quantityMixProductions;
      print("beforeDown : ${prescriptionRepo.getMaterialsByPrescription(mixProduction.fkPrescription)}\n");
      List<MaterialPrescriptionManagementModel> materialPrescriptionList =
      await prescriptionRepo.getMaterialsByPrescription(mixProduction.fkPrescription);
      for(MaterialPrescriptionManagementModel material in materialPrescriptionList){
        bool isIncrement = await materialRepo.incrementMaterialQuantity(material.fkMaterial, (material.quntatyUse * differenceNumber));
        if(isIncrement){
          MaterialModel? materialModel =await materialRepo.getMaterialById(material.fkMaterial);
          double quantityAvailable = materialModel!.quantityAvailable ?? 0;
          double minimum = materialModel!.minimum ?? 0;

          bool isAlert = minimum > quantityAvailable;
          if(!isAlert){
            materialModel.isAlerts = false;
            String alertsMessage = isAlert ? "الكمية منخفضة عن الحد الادني او تقترب منها" : "";
            materialModel.alertsMessage = alertsMessage;
          }
          materialRepo.updateMaterial(materialModel);
        }
      }
      print("mixProduction : ${mixProduction}");
      print("mixProduction_after : ${mixProduction.quantityMixProductions}");

      return await _database.updateMixProduction(mixProduction);
    }
    //اذا كان عمليية الانتاج اكبر من العدد القديم
    else if(currentQuantity<mixProduction.quantityMixProductions){
      print("mixProduction_before : ${mixProduction.quantityMixProductions}");

      int differenceNumber = mixProduction.quantityMixProductions-currentQuantity;
      print("beforeUp : ${prescriptionRepo.getMaterialsByPrescription(mixProduction.fkPrescription)}\n");
      List<MaterialPrescriptionManagementModel> materialPrescriptionList =
      await prescriptionRepo.getMaterialsByPrescription(mixProduction.fkPrescription);
      for(MaterialPrescriptionManagementModel material in materialPrescriptionList){
        bool isDecrement = await materialRepo.decrementMaterialQuantity(material.fkMaterial, (material.quntatyUse * differenceNumber));

        if(isDecrement){
          MaterialModel? materialModel =await materialRepo.getMaterialById(material.fkMaterial);
          double quantityAvailable = materialModel!.quantityAvailable ?? 0;
          double minimum = materialModel!.minimum ?? 0;

          bool isAlert = minimum >= quantityAvailable;
          if(isAlert){
            materialModel.isAlerts = true;
            String alertsMessage = isAlert ? "الكمية منخفضة عن الحد الادني او تقترب منها" : "";
            materialModel.alertsMessage = alertsMessage;
          }
          materialRepo.updateMaterial(materialModel);
        }
      }
      print("afterUp : ${
          prescriptionRepo.getMaterialsByPrescription(mixProduction.fkPrescription)
      }");
      print("mixProduction_after : ${mixProduction.quantityMixProductions}");

      return await _database.updateMixProduction(mixProduction);
    }
      return false;
  }


  Future<bool> delete_Production_And_Increment_Material_Quantity(MixProductionModel mixProduction) async{
    bool isDeleteMixProduction = await deleteMixProduction(mixProduction.mixProductionsId);
    if(isDeleteMixProduction){
      List<MaterialPrescriptionManagementModel> materialPrescriptionList = await prescriptionRepo.getMaterialsByPrescription(mixProduction.fkPrescription);
      for(MaterialPrescriptionManagementModel material in materialPrescriptionList){
        materialRepo.incrementMaterialQuantity(material.fkMaterial,
            (material.quntatyUse * mixProduction.quantityMixProductions)
        );
      }
      return true;
    }else{
      return false;
    }
  }
  // حذف خلطة
  Future<bool> deleteMixProduction(int id) async {
    return await _database.deleteMixProduction(id);
  }

  // جلب قائمة الموظفين المسؤولين عن الخلطات (مفيد لاقتراحات البحث)
  Future<List<String>> getEmployeesList() async {
    return await _database.getEmployeesList();
  }

  // جلب إحصائيات عن الخلطات
  Future<Map<String, dynamic>> getMixProductionsStatistics() async {
    return await _database.getMixProductionsStatistics();
  }

  // البحث عن الخلطات حسب الاسم
  Future<List<MixProductionModel>> searchMixProductionsByName(String name) async {
    return await _database.searchMixProductionsByName(name);
  }

  // إغلاق الـ repository وقاعدة البيانات المرتبطة به
  void close() {
    _database.close();
  }
}