import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:system_pvc/data/model/prescription_management_model.dart';

class PrescriptionManagementDatabase {
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
        CREATE TABLE IF NOT EXISTS prescription_management (
          prescription_managementId INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          createdAt TEXT NOT NULL
        );
      ''');
      return 1;
    } catch (e) {
      print('خطأ في تهيئة قاعدة البيانات: $e');
      return 0;
    }
  }

  // الحصول على عدد الصفحات
  Future<int> getTotalPages({int itemsPerPage = 10}) async {
    try {
      final result = db.select('SELECT COUNT(*) AS count FROM prescription_management');
      final int totalItems = result.first['count'] as int;
      final totalPages = (totalItems / itemsPerPage).ceil();
      print('totalItems: $totalItems totalPages: $totalPages');
      return totalPages;
    } catch (e) {
      print('خطأ في حساب عدد الصفحات: $e');
      return 0;
    }
  }

  // إدراج سجل جديد
  Future<int> insertPrescription(PrescriptionManagementModel prescription_management) async {
    try {
      db.execute('''
        INSERT INTO prescription_management (name, createdAt)
        VALUES (?, ?)
      ''', [
        prescription_management.name,
        prescription_management.createdAt.toIso8601String(),
      ]);
      final int newId = db.lastInsertRowId;
      return newId;
    } catch (e) {
      print('خطأ في إدخال المادة: $e');
      return 0;
    }
  }

  // الحصول على جميع الخامات
  Future<List<PrescriptionManagementModel>> getAllPrescriptionManagement() async {
    try {
      final result = db.select('''
        SELECT * FROM prescription_management
        ORDER BY createdAt ASC  -- ترتيب حسب التاريخ (أحدث شيء في المقدمة)
      ''');
      print('data: $result');
      return result.map((row) {
        return PrescriptionManagementModel(
          id: row['prescription_managementId'],
          name: row['name'],
          createdAt: DateTime.parse(row['createdAt']),
        );
      }).toList();
    } catch (e) {
      print('خطأ في استرجاع المواد: $e');
      // إعادة قائمة فارغة في حالة حدوث أخطاء
      return [];
    }
  }


  // تحديث سجل موجود
  Future<int> updatePrescription(PrescriptionManagementModel prescription_management) async {
    try {
      db.execute('''
        UPDATE prescription_management
        SET name = ?
        WHERE prescription_managementId = ?
      ''', [
        prescription_management.name,
        prescription_management.id,
      ]);
      return prescription_management.id ?? 0;
    } catch (e) {
      print('خطأ في تحديث المادة: $e');
      return 0;
    }
  }

  // حذف سجل
  Future<int> deletePrescription(int materialId) async {
    try {
      db.execute('''
        DELETE FROM prescription_management
        WHERE prescription_managementId = ?
      ''', [materialId]);
      return materialId;
    } catch (e) {
      print('خطأ في حذف المادة: $e');
      return 0;
    }
  }

  // إغلاق قاعدة البيانات
  void close() {
    db.dispose();
  }
}
