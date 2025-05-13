import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:system_pvc/data/model/material_prescription_management_model.dart';

class MaterialPrescriptionManagementDatabase {
  late Database db;
  String? _dbPath;

  Future<int> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _dbPath = prefs.getString('dbPath');
      print("Database path: $_dbPath");
      if (_dbPath == null || _dbPath!.isEmpty) {
        print('مسار قاعدة البيانات غير محدد');
        return 0;
      }

      db = sqlite3.open(_dbPath!);
      db.execute('''
        CREATE TABLE IF NOT EXISTS material_prescription_management (
          idMaterialPrescriptionManagement INTEGER PRIMARY KEY AUTOINCREMENT,
          fkPrescription INTEGER NOT NULL,
          fkMaterial INTEGER NOT NULL,
          quntatyUse REAL NOT NULL,
          isSelected INTEGER NOT NULL DEFAULT 0,
          createdAt TEXT NOT NULL
        );
      ''');
      return 1;
    } catch (e) {
      print('خطأ في تهيئة قاعدة البيانات: $e');
      return 0;
    }
  }

  Future<int> insertMaterial(MaterialPrescriptionManagementModel model) async {
    try {
      db.execute('''
        INSERT INTO material_prescription_management (
          fkPrescription, fkMaterial, quntatyUse, isSelected, createdAt
        ) VALUES (?, ?, ?, ?, ?)
      ''', [
        model.fkPrescriptionManagement,
        model.fkMaterial,
        model.quntatyUse,
        model.isSelected ? 1 : 0,
        model.createdAt.toIso8601String(),
      ]);
      return db.lastInsertRowId;
    } catch (e) {
      print('خطأ في إدخال المادة للخلطة: $e');
      return 0;
    }
  }

  Future<List<MaterialPrescriptionManagementModel>> getMaterialsByPrescription(int fkPrescription) async {
    try {
      final result = db.select('''
        SELECT * FROM material_prescription_management
        WHERE fkPrescription = ?
        ORDER BY createdAt DESC
      ''', [fkPrescription]);

      return result.map((row) {
        print('JJJJJJJJJ : ${row}');

        return MaterialPrescriptionManagementModel(

          idMaterialPrescriptionManagement: row['idMaterialPrescriptionManagement'],
          fkPrescriptionManagement: row['fkPrescription'],
          fkMaterial: row['fkMaterial'],
          quntatyUse: row['quntatyUse'],
          isSelected: row['isSelected'] == 1,
          createdAt: DateTime.parse(row['createdAt']),
        );
      }).toList();
    } catch (e) {
      print('خطأ في جلب المواد المرتبطة بالخلطة: $e');
      return [];
    }
  }

  Future<int> updateMaterial(MaterialPrescriptionManagementModel model) async {
    try {
      db.execute('''
        UPDATE material_prescription_management
        SET fkPrescription = ?, fkMaterial = ?, quntatyUse = ?, isSelected = ?, createdAt = ?
        WHERE idMaterialPrescriptionManagement = ?
      ''', [
        model.fkPrescriptionManagement,
        model.fkMaterial,
        model.quntatyUse,
        model.isSelected ? 1 : 0,
        model.createdAt.toIso8601String(),
        model.idMaterialPrescriptionManagement,
      ]);
      return model.idMaterialPrescriptionManagement;
    } catch (e) {
      print('خطأ في تحديث المادة: $e');
      return 0;
    }
  }

  Future<int> deleteMaterial(int id) async {
    try {
      db.execute('''
        DELETE FROM material_prescription_management
        WHERE idMaterialPrescriptionManagement = ?
      ''', [id]);
      return id;
    } catch (e) {
      print('خطأ في حذف المادة: $e');
      return 0;
    }
  }

  void close() {
    db.dispose();
  }
}
