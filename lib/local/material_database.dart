import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:system_pvc/data/model/material_model.dart';

class MaterialDatabase {
  late Database db;
  String? _dbPath;

  // فتح قاعدة البيانات وإنشاء الجدول إذا لم يكن موجودًا
  Future<bool> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _dbPath = prefs.getString('dbPath');
      print("object : $_dbPath");
      if (_dbPath == null || _dbPath!.isEmpty) {
        print('مسار قاعدة البيانات غير محدد');
        return false;
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
      return true;
    } catch(e) {
      print('خطأ في تهيئة قاعدة البيانات: $e');
      return false;
    }
  }

  // الحصول على عدد الصفحات
  Future<int> getTotalPages({int itemsPerPage = 10}) async {
    try {
      final result = db.select('SELECT COUNT(*) AS count FROM materials');
      print('totalItemsWar: $result');

      final int totalItems = result.first['count'] as int;
      final totalPages = (totalItems / itemsPerPage).ceil(); // استخدام ceil لضمان أن الصفحة الأخيرة تحتوي على العناصر المتبقية
      print('totalItemsWar: $totalItems totalPages: $totalPages');

      return totalPages;
    } catch (e) {
      print('خطأ في حساب عدد الصفحات: $e');
      return 0;
    }
  }


  // إضافة خامة جديدة
  Future<bool> insertMaterial(MaterialModel material) async {
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
      return true;
    } catch (e) {
      print('خطأ في إدخال المادة: $e');
      return false;
    }
  }

// تحديث خامة
  Future<bool> updateMaterial(MaterialModel material) async {
    try {
      // تحويل bool إلى int (0 أو 1)
      final int isAlertsValue = material.isAlerts ? 1 : 0;

      final stmt = db.prepare('''
      UPDATE materials SET 
        materialName = ?, 
        quantityAvailable = ?, 
        minimum = ?, 
        isAlerts = ?, 
        alertsMessage = ?
      WHERE materialId = ?
    ''');

      stmt.execute([
        material.materialName,
        material.quantityAvailable,
        material.minimum,
        isAlertsValue,  // استخدام القيمة العددية
        material.alertsMessage,
        material.materialId,  // هذا هو معيار التحديث وليس حقل للتحديث
      ]);

      stmt.dispose();
      print('تم تحديث المادة بنجاح');

      return true; // نجاح التحديث
    } catch (e) {
      print('خطأ في تحديث المادة: $e');
      return false;
    }
  }

  //اضافة كميات زيادة
  Future<bool> incrementMaterialQuantity(int materialId, double quantity) async {
    try {
      final stmt = db.prepare('''
      UPDATE materials 
      SET quantityAvailable = quantityAvailable + ? 
      WHERE materialId = ?
    ''');

      stmt.execute([quantity, materialId]);
      stmt.dispose();

      print('تمت زيادة الكمية بنجاح');
      return true;
    } catch (e) {
      print('خطأ في زيادة الكمية: $e');
      return false;
    }
  }

  //تقليل كمية
  Future<bool> decrementMaterialQuantity(int materialId, double quantity) async {
    try {


      // الحصول على الكمية الحالية
      final result = db.select(
        'SELECT quantityAvailable FROM materials WHERE materialId = ?',
        [materialId],
      );

      if (result.isEmpty) {
        print('لم يتم العثور على المادة');
        return false;
      }

      final currentQuantity = (result.first['quantityAvailable'] as num).toDouble();

      if (currentQuantity < quantity) {
        print('الكمية غير كافية للطرح');
        return false;
      }



      final stmt = db.prepare('''
      UPDATE materials 
      SET quantityAvailable = quantityAvailable - ? 
      WHERE materialId = ?
    ''');

      stmt.execute([quantity, materialId]);
      stmt.dispose();

      print('تم إنقاص الكمية بنجاح');
      return true;
    } catch (e) {
      print('خطأ في إنقاص الكمية: $e');
      return false;
    }
  }



  // حذف خامة
  Future<bool> deleteMaterial(int id) async {
    try {
      db.execute('DELETE FROM materials WHERE materialId = ?', [id]);
      return true;
    } catch (e) {
      print('خطأ في حذف المادة: $e');
      return false;
    }
  }


  // الحصول على جميع الخامات
  Future<List<MaterialModel>> getMaterials(
      {int page = 1,
        int limit = 10}
      ) async {
    try {
      final offset = (page - 1) * limit;
      final String query = '''
        SELECT
         materialId,
         materialName,
         quantityAvailable,
         minimum,
         isAlerts,
         alertsMessage,
         createdAt
        FROM materials
      ORDER BY createdAt DESC
      LIMIT ? OFFSET ?
    ''';

      final result = db.select(query, [limit, offset]);
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
        ORDER BY createdAt ASC  -- ترتيب حسب التاريخ (أحدث شيء في المقدمة)
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
  Future<bool> updateAlert({
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
      return true;
    } catch (e) {
      print('خطأ في تحديث الإشعار: $e');
      return false;
    }
  }

  // إغلاق الاتصال بقاعدة البيانات
  bool close() {
    try {
      db.dispose();
      return true;
    } catch (e) {
      print('خطأ في إغلاق قاعدة البيانات: $e');
      return false;
    }
  }
}