import 'package:flutter/material.dart';
import 'package:system_pvc/constant/color.dart';

/// جدول إدارة الخلطات والمواد المرتبطة بها
Widget tablePrescriptionManagement({
  required Map<String, String> headers, // المفتاح = id المادة أو idPrescription، والقيمة = الاسم الظاهر بالعربي
  required List<Map<String, dynamic>> prescriptions, // كل خلطة: تحتوي على idPrescription و namePrescription
  required List<Map<String, dynamic>> materialUses, // استخدام المواد: تحتوي على fkPrescription و fkMaterial و quntatyUse
  void Function(int index)? onEdit,
  void Function(int index)? onDelete,
}) {
  return Column(
    children: [
      // Header Row
      Row(
        children: [
          ...headers.values.map((headerName) {
            return Expanded(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorApp.gray,
                ),
                child: Text(
                  headerName,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),

          // عمود الإجراءات
          Container(
            width: 120,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorApp.gray,
            ),
            child: Text(
              "إجراءات",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),

      // Data Rows
      ...prescriptions.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> prescription = entry.value;
        String prescriptionId = prescription["idPrescription"].toString();

        // طباعة للتصحيح
        print("عرض الخلطة رقم: $prescriptionId - ${prescription["namePrescription"]}");

        return Column(
          children: [
            Row(
              children: [
                ...headers.keys.map((key) {
                  String displayText = "-";


                  if (key == "idPrescription") {
                    displayText = "${index+1}";
                  } else if (key == "namePrescription") {
                    displayText = prescription["namePrescription"].toString();
                  } else {
                    // البحث عن كمية المادة في هذه الخلطة
                    // نطبع كل قيم materialUses للتحقق
                    print("البحث عن المادة $key في الخلطة  $prescriptionId");

                    for (var material in materialUses) {
                      String matPrescId = material["fkPrescription"];
                      String matId = material["fkMaterial"];
                      print("FKMaterial : ${matId}");

                      print("مقارنة مع: fkPrescription=$matPrescId, fkMaterial=$matId");

                      if (matPrescId == prescriptionId && matId == key) {
                        displayText = material["quntatyUse"].toString();
                        print("وجدت كمية للمادة $key في الخلطة $prescriptionId: ${material["quntatyUse"]}");
                        break;
                      }
                    }
                  }
                  return Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        "${displayText}",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                }).toList(),

                // أزرار التعديل والحذف
                Container(
                  width: 120,
                  decoration: BoxDecoration(
                    color: ColorApp.gray.withOpacity(0.1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.green),
                        onPressed: () => onEdit?.call(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onDelete?.call(index),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(
              color: ColorApp.gray,
              height: 1,
            ),
          ],
        );
      }).toList(),
    ],
  );
}