import 'package:flutter/material.dart';
import 'package:system_pvc/constant/color.dart';
import 'package:system_pvc/constant/stream.dart';

Widget tableWareHouseManagement({
  required Map<String, String> headers,
  required List<Map<String, String>> headersPrescription,
  required List<Map<String, String>> rowsMaterial,
  void Function(int index)? onEdit,
  void Function(int index)? onDelete,
}) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: ColorApp.gray.withOpacity(0.5)),
      borderRadius: BorderRadius.circular(5),
    ),
    child: ConstrainedBox(
      constraints: BoxConstraints(minWidth: 800),
      child: Column(
        children: [
          // ---------------------- Header Row ----------------------
          Row(
            children: [
              ...headers.values.map(_buildHeaderCell),
              ...headersPrescription.map(
                    (prescription) => _buildHeaderCell(prescription.values.first),
              ),
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
                    ...headers.keys.map((key) {
                      String cellValue = row[key] ?? "";
                      return _buildDataCell(cellValue);
                    }),

                    if(StreamData.userModel.isPrescriptionManagement)
                    ...headersPrescription.map((prescription) {
                      String prescriptionId = prescription.keys.first.toString();
                      String cellValue = row[prescriptionId] ?? "-";
                      return _buildDataCell(cellValue, highlight: cellValue != "-");
                    }),

                    // إجراءات
                    Container(
                      width: 120,
                      decoration: BoxDecoration(
                        color: rowIndex % 2 == 0
                            ? ColorApp.gray.withOpacity(0.1)
                            : Colors.white,
                      ),
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
      ),
    ),
  );
}

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

Widget _buildDataCell(String text, {bool highlight = false}) {
  return Expanded(
    child: Container(
      padding: EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
          color: highlight ? ColorApp.black : null,
        ),
      ),
    ),
  );
}
