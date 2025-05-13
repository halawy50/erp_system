import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:system_pvc/data/model/material_model.dart';

class MaterialDatabase {
  late Database db;
  String? _dbPath;

  // فتح قاعدة البيانات وإنشاء الجدول إذا لم يكن موجودًا
  Future<int> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _dbPath = prefs.getString('dbPath');
      print("object : $_dbPath");
      if (_dbPath == null || _dbPath!.isEmpty) {
        print('مسار قاعدة البيانات غير محدد');
        return 0;
      }
      db = sqlite3.open(_dbPath!);

      db.execute('''
        CREATE TABLE IF NOT EXISTS materials (
          materialId INTEGER PRIMARY KEY AUTOINCREMENT,
          materialName TEXT NOT NULL,
          quantityAvailable REAL NOT NULL,
          minimum REAL NOT NULL,
          isAlerts INTEGER NOT NULL,
          alertsMessage TEXT NOT NULL,
          createdAt TEXT NOT NULL
        );
      ''');
      return 1;
    } catch(e) {
      print('خطأ في تهيئة قاعدة البيانات: $e');
      return 0;
    }
  }

  // الحصول على عدد الصفحات
  Future<int> getTotalPages({int itemsPerPage = 10}) async {
    try {
      final result = db.select('SELECT COUNT(*) AS count FROM materials');
      final int totalItems = result.first['count'] as int;

      final totalPages = (totalItems / itemsPerPage).ceil(); // استخدام ceil لضمان أن الصفحة الأخيرة تحتوي على العناصر المتبقية
      print('totalItems: $totalItems totalPages: $totalPages');

      return totalPages;
    } catch (e) {
      print('خطأ في حساب عدد الصفحات: $e');
      return 0;
    }
  }


  // إضافة خامة جديدة
  Future<void> insertMaterial(MaterialModel material) async {
    try {
      // تحويل bool إلى int (0 أو 1)
      final int isAlertsValue = material.isAlerts ? 1 : 0;

      db.execute('''
        INSERT INTO materials (materialName, quantityAvailable, minimum, isAlerts, alertsMessage, createdAt)
        VALUES (?, ?, ?, ?, ?, ?)
      ''', [
        material.materialName,
        material.quantityAvailable,
        material.minimum,
        isAlertsValue,  // استخدام القيمة العددية
        material.alertsMessage,
        material.createdAt.toIso8601String(),
      ]);
    } catch (e) {
      print('خطأ في إدخال المادة: $e');
      rethrow;
    }
  }

  // تحديث خامة
  Future<void> updateMaterial(MaterialModel material) async {
    try {
      // تحويل bool إلى int (0 أو 1)
      final int isAlertsValue = material.isAlerts ? 1 : 0;

      db.execute('''
        UPDATE materials SET 
          materialName = ?, 
          quantityAvailable = ?, 
          minimum = ?, 
          isAlerts = ?, 
          alertsMessage = ?, 
          createdAt = ?
        WHERE materialId = ?
      ''', [
        material.materialName,
        material.quantityAvailable,
        material.minimum,
        isAlertsValue,  // استخدام القيمة العددية
        material.alertsMessage,
        material.createdAt.toIso8601String(),
        material.materialId,
      ]);
    } catch (e) {
      print('خطأ في تحديث المادة: $e');
      rethrow;
    }
  }

  // حذف خامة
  Future<void> deleteMaterial(int id) async {
    try {
      db.execute('DELETE FROM materials WHERE materialId = ?', [id]);
    } catch (e) {
      print('خطأ في حذف المادة: $e');
      rethrow;
    }
  }

  // الحصول على جميع الخامات
  Future<List<MaterialModel>> getMaterials({required int page, int itemsPerPage = 10}) async {
    try {
      final offset = (page - 1) * itemsPerPage;
      final result = db.select('''
        SELECT * FROM materials
        ORDER BY createdAt DESC  -- ترتيب حسب التاريخ (أحدث شيء في المقدمة)
        LIMIT ? OFFSET ?
      ''', [itemsPerPage, offset]);

      print('data: $result');

      return result.map((row) {
        // تحويل int إلى bool (0 = false, أي قيمة أخرى = true)
        final bool isAlertsValue = row['isAlerts'] == 1;

        return MaterialModel(
          materialId: row['materialId'],
          materialName: row['materialName'],
          isAlerts: isAlertsValue,  // استخدام القيمة المنطقية
          alertsMessage: row['alertsMessage'],
          quantityAvailable: row['quantityAvailable'] is double
              ? row['quantityAvailable']
              : (row['quantityAvailable'] is int
              ? row['quantityAvailable'].toDouble()
              : double.parse(row['quantityAvailable'].toString())),
          minimum: row['minimum'] is double
              ? row['minimum']
              : (row['minimum'] is int
              ? row['minimum'].toDouble()
              : double.parse(row['minimum'].toString())),
          createdAt: DateTime.parse(row['createdAt']),
        );
      }).toList();
    } catch (e) {
      print('خطأ في استرجاع المواد: $e');
      // إعادة قائمة فارغة في حالة حدوث أخطاء
      return [];
    }
  }

  // الحصول على جميع الخامات
  Future<List<MaterialModel>> getAllMaterials() async {
    try {
      final result = db.select('''
        SELECT * FROM materials
        ORDER BY createdAt DESC  -- ترتيب حسب التاريخ (أحدث شيء في المقدمة)
      ''');

      print('data: $result');

      return result.map((row) {
        // تحويل int إلى bool (0 = false, أي قيمة أخرى = true)
        final bool isAlertsValue = row['isAlerts'] == 1;

        return MaterialModel(
          materialId: row['materialId'],
          materialName: row['materialName'],
          isAlerts: isAlertsValue,  // استخدام القيمة المنطقية
          alertsMessage: row['alertsMessage'],
          quantityAvailable: row['quantityAvailable'] is double
              ? row['quantityAvailable']
              : (row['quantityAvailable'] is int
              ? row['quantityAvailable'].toDouble()
              : double.parse(row['quantityAvailable'].toString())),
          minimum: row['minimum'] is double
              ? row['minimum']
              : (row['minimum'] is int
              ? row['minimum'].toDouble()
              : double.parse(row['minimum'].toString())),
          createdAt: DateTime.parse(row['createdAt']),
        );
      }).toList();
    } catch (e) {
      print('خطأ في استرجاع المواد: $e');
      // إعادة قائمة فارغة في حالة حدوث أخطاء
      return [];
    }
  }

  // الحصول على خامة معينة
  Future<MaterialModel?> getMaterialById(int id) async {
    try {
      final result = db.select('SELECT * FROM materials WHERE materialId = ?', [id]);
      if (result.isEmpty) return null;

      final row = result.first;

      // تحويل int إلى bool (0 = false, أي قيمة أخرى = true)
      final bool isAlertsValue = row['isAlerts'] == 1;

      return MaterialModel(
        materialId: row['materialId'],
        materialName: row['materialName'],
        isAlerts: isAlertsValue,  // استخدام القيمة المنطقية
        alertsMessage: row['alertsMessage'],
        quantityAvailable: row['quantityAvailable'] is double
            ? row['quantityAvailable']
            : (row['quantityAvailable'] is int
            ? row['quantityAvailable'].toDouble()
            : double.parse(row['quantityAvailable'].toString())),
        minimum: row['minimum'] is double
            ? row['minimum']
            : (row['minimum'] is int
            ? row['minimum'].toDouble()
            : double.parse(row['minimum'].toString())),
        createdAt: DateTime.parse(row['createdAt']),
      );
    } catch (e) {
      print('خطأ في استرجاع المادة بالمعرف: $e');
      return null;
    }
  }

  // تحديث إشعار الخامة
  Future<void> updateAlert({
    required int id,
    required bool isAlerts,
    required String alertsMessage,
  }) async {
    try {
      // تحويل bool إلى int (0 أو 1)
      final int isAlertsValue = isAlerts ? 1 : 0;

      db.execute('''
        UPDATE materials
        SET isAlerts = ?, alertsMessage = ?
        WHERE materialId = ?
      ''', [isAlertsValue, alertsMessage, id]);
    } catch (e) {
      print('خطأ في تحديث الإشعار: $e');
      rethrow;
    }
  }

  // إغلاق الاتصال بقاعدة البيانات
  void close() {
    try {
      db.dispose();
    } catch (e) {
      print('خطأ في إغلاق قاعدة البيانات: $e');
    }
  }
}