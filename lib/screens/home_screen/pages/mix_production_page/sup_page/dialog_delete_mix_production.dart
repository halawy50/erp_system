
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:system_pvc/components/show_snak_bar.dart';
import 'package:system_pvc/constant/color.dart';
import 'package:system_pvc/cubit/mix_production_cubit/mix_production_cubit.dart';
import 'package:system_pvc/data/model/mix_productions_model.dart';
import 'package:system_pvc/repo/mix_production_repo.dart';

void showDialogDeleteMixProduction({
  required BuildContext context,
  required MixProductionModel mixProduction,
  required String startDate,
  required String endDate,
  required List<int> fkPrescription,
  required List<int> fkEmployee,
  required MixProductionRepo mixProductionRepo,
  required MixProductionCubit mixProductionCubit,
  required int page,
  required void Function(bool isShow) onClose,
}){
  showDialog(
    context: context,
    builder: (context) => AlertDialog(

      title: Text(
        'تنبيه',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Container(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'هل تريد حذف عملية الإنتاج وإعادة المواد إلى المخزن أم الحذف بدون إعادة المواد؟',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: ColorApp.blue),
              onPressed: () async {
                bool isDeleted = await mixProductionRepo.delete_Production_And_Increment_Material_Quantity(mixProduction);
                Navigator.pop(context);
                if (isDeleted) {
                  List<MixProductionModel> mixProductionList = await mixProductionRepo.getMixProductions(page: page);
                  int items = mixProductionList.length;
                  if(items>0 && page>=1){
                    mixProductionCubit.getAllCountMixProductionsUserFilter(
                        startDate,
                        endDate,
                        fkPrescription,
                        fkEmployee,
                        page: page);
                  }else if(items<=0 && page>=1){
                    mixProductionCubit.getAllCountMixProductionsUserFilter(
                        startDate,
                        endDate,
                        fkPrescription,
                        fkEmployee,
                        page: page-1);
                  }
                  onClose(false);
                  showSnackbar(context, "تم حذف عملية الانتاج", backgroundColor: Colors.green);

                } else {
                  showSnackbar(context, "حدث خطأ ما", backgroundColor: Colors.red);
                }
              },
              child: Text("إعادة المواد إلى المخزن", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: ColorApp.red),
              onPressed: () async {
                bool isDeleted = await mixProductionRepo.deleteMixProduction(mixProduction.mixProductionsId);
                Navigator.pop(context);
                if (isDeleted) {
                  List<MixProductionModel> mixProductionList = await mixProductionRepo.getMixProductions(page: page);
                  int items = mixProductionList.length;
                  if(items>0 && page>=1){
                    mixProductionCubit.getAllCountMixProductionsUserFilter(
                        startDate,
                        endDate,
                        fkPrescription,
                        fkEmployee,
                        page: page);
                  }else if(items<=0 && page>=1){
                    mixProductionCubit.getAllCountMixProductionsUserFilter(
                        startDate,
                        endDate,
                        fkPrescription,
                        fkEmployee,
                        page: page-1);
                  }
                  onClose(false);

                  showSnackbar(context, "تم حذف عملية الانتاج", backgroundColor: Colors.green);
                } else {
                  showSnackbar(context, "حدث خطأ ما", backgroundColor: Colors.red);
                }
              },
              child: Text("حذف بدون إعادة المواد", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onClose(false);
          },
          child: Text("إغلاق", style: TextStyle(color: Colors.black)),
        ),
      ],
    ),
  );
}
