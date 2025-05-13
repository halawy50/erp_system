import 'package:flutter/material.dart';
import 'package:system_pvc/constant/color.dart';

Widget tableWareHouseManagement({
  required Map<String, String> headers, // المفتاح إنجليزي والقيمة عربي
  required List<Map<String, String>> headersPrescription, // قائمة أسماء الخلطات (العمود الإضافي)
  required List<Map<String, String>> rowsMaterial,
  void Function(int index)? onEdit,
  void Function(int index)? onDelete,
}) {
  return Column(
    children: [
      // ---------------------- Header Row ----------------------
      Row(
        children: [
          // الأعمدة الرئيسية
          ...headers.values.map((headerName) => _buildHeaderCell(headerName)),

          // أعمدة الخلطات الإضافية
          ...headersPrescription.map(
                (prescription) => _buildHeaderCell(prescription.values.first),
          ),

          // عمود الإجراءات
          Container(
            width: 120,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: ColorApp.gray),
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

      // ---------------------- Data Rows ----------------------
      ...rowsMaterial.asMap().entries.map((entry) {
        int rowIndex = entry.key;
        Map<String, String> row = entry.value;

        return Column(
          children: [
            Row(
              children: [
                // الأعمدة الرئيسية
                ...headers.keys.map((key) {
                  String cellValue = key == "id" ? "${rowIndex + 1}" : (row[key] ?? "");
                  return _buildDataCell(cellValue);
                }),

                // قيم الخلطات في هذا الصف (إذا كانت موجودة)
                ...headersPrescription.map((prescription) {

                  headers.keys.map((key) {
                  String cellValue = key == "id" ? "${rowIndex + 1}" : (row[key] ?? "");


                  return _buildDataCell(cellValue);

                  });

                  String key = prescription.keys.first;
                  String value = row[key] ?? "";
                  return _buildDataCell(value);
                }),

                // أزرار الإجراءات
                Container(
                  width: 120,
                  decoration: BoxDecoration(color: ColorApp.gray.withOpacity(0.1)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.green),
                        onPressed: () => onEdit?.call(rowIndex),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onDelete?.call(rowIndex),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(color: ColorApp.gray, height: 1),
          ],
        );
      }).toList(),
    ],
  );
}

// ---------------------- Helper Methods ----------------------
Widget _buildHeaderCell(String text) {
  return Expanded(
    child: Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: ColorApp.gray),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ),
  );
}

Widget _buildDataCell(String text) {
  return Expanded(
    child: Container(
      padding: EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(fontSize: 14),
      ),
    ),
  );
}
