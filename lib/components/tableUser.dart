import 'package:flutter/material.dart';
import 'package:system_pvc/constant/color.dart';

Widget tableUsers({
  required Map<String, String> headers, // المفتاح إنجليزي والقيمة عربي
  required List<Map<String, String>> rows,
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
      ...rows.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, String> row = entry.value;

        if(row["isAdmin"]=="true"){return Container();}
        else
          return Column(
          children: [
            Row(
              children: [
                ...headers.keys.map((key) {
                  return Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                      ),
                      child: Text(

                        key=="id"?"${index}":row[key] ?? "",
                        style: TextStyle(fontSize: 16),
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
