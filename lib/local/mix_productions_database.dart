import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:system_pvc/data/model/material_prescription_management_model.dart';
import 'package:system_pvc/data/model/mix_productions_model.dart';

class MixProductionsDatabase {
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
        CREATE TABLE IF NOT EXISTS mix_productions (
          mixProductions INTEGER PRIMARY KEY AUTOINCREMENT,
          nameMixProductions TEXT NOT NULL,
          quantityMixProductions INTEGER NOT NULL,
          employeeName TEXT NOT NULL,
          fkEmployee INTEGER NOT NULL,
          fkPrescription INTEGER NOT NULL,
          dateTimeProduction TEXT NOT NULL,
          createdAt TEXT NOT NULL
        );
      ''');

      return true;
    } catch(e) {
      print('خطأ في تهيئة قاعدة البيانات: $e');
      return false;
    }
  }

  // انتاج خلطة جديدة
  Future<bool> insertMixProduction(MixProductionModel mixProduction) async {
    try {
      final stmt = db.prepare('''
        INSERT INTO mix_productions (nameMixProductions, quantityMixProductions, employeeName, fkEmployee, fkPrescription , dateTimeProduction, createdAt)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      ''');

      stmt.execute([
        mixProduction.nameMixProductions,
        mixProduction.quantityMixProductions,
        mixProduction.employeeName,
        mixProduction.fkEmployee,
        mixProduction.fkPrescription,
        mixProduction.dateTimeProduction,
        mixProduction.createdAt.toIso8601String(),
      ]);

      stmt.dispose();
      return true;
    } catch (e) {
      print('خطأ في إدخال المادة: $e');
      return false;
    }
  }



  Future<List<MixProductionModel>> getMixProductions({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final offset = (page - 1) * limit;
      final String query = '''
      SELECT 
        mixProductions,
        nameMixProductions,
        quantityMixProductions,
        employeeName,
        fkEmployee,
        fkPrescription,
        dateTimeProduction,
        createdAt
      FROM mix_productions
      ORDER BY createdAt DESC
      LIMIT ? OFFSET ?
    ''';

      final result = db.select(query, [limit, offset]);

      print('mixProduction : ${result}');

      return result.map((row) {
        return MixProductionModel(
          mixProductionsId: row['mixProductions'],
          nameMixProductions: row['nameMixProductions'],
          quantityMixProductions: row['quantityMixProductions'],
          employeeName: row['employeeName'],
          fkEmployee: row['fkEmployee'],
          fkPrescription: row['fkPrescription'],
          dateTimeProduction: row['dateTimeProduction'],
          createdAt: DateTime.parse(row['createdAt']),
        );
      }).toList();
    } catch (e) {
      print('خطأ في استرجاع الخلطات: $e');
      return [];
    }
  }

  // الحصول على عدد الصفحات
  Future<int> getTotalPages({int itemsPerPage = 10}) async {
    try {
      final result = db.select('SELECT COUNT(*) AS count FROM mix_productions');
      final int totalItems = result.first['count'] as int;

      final totalPages = (totalItems / itemsPerPage).ceil(); // استخدام ceil لضمان أن الصفحة الأخيرة تحتوي على العناصر المتبقية
      print('totalItemsMix: $totalItems totalPages: $totalPages');

      return totalPages;
    } catch (e) {
      print('خطأ في حساب عدد الصفحات: $e');
      return 0;
    }
  }

  // الحصول على عدد الخلطات
  Future<int> getTotalMixProduction() async {
    try {
      final result = db.select('SELECT COUNT(*) AS count FROM mix_productions');
      final int totalItems = result.first['count'] as int;
      return totalItems;
    } catch (e) {
      print('خطأ في حساب عدد الصفحات: $e');
      return 0;
    }
  }

  // جلب خلطة معينة بواسطة المعرف
  Future<MixProductionModel?> getMixProductionById(int id) async {
    try {
      final stmt = db.prepare('''
        SELECT 
          mixProductions,
          nameMixProductions,
          quantityMixProductions,
          employeeName,
          fkEmployee,
          fkPrescription,
          dateTimeProduction,
          createdAt
        FROM mix_productions
        WHERE mixProductions = ?
      ''');

      final result = stmt.select([id]);

      if (result.isEmpty) {
        stmt.dispose();
        return null;
      }

      final row = result.first;
      final mixProduction = MixProductionModel(
        mixProductionsId: row[0] as int,
        nameMixProductions: row[1] as String,
        quantityMixProductions: row[2] as int,
        employeeName: row[3] as String,
        fkEmployee: row[4] as int,
        fkPrescription: row[5] as int,
        dateTimeProduction: row[6] as String,
        createdAt: DateTime.parse(row[7] as String),
      );

      stmt.dispose();
      return mixProduction;
    } catch (e) {
      print('خطأ في جلب الخلطة: $e');
      return null;
    }
  }

  Future<bool> updateMixProduction(MixProductionModel mixProduction) async {
    try {
      if (mixProduction.mixProductionsId == null) {
        print("خطأ: معرف الخلطة غير موجود");
        return false;
      }

      final selectStmt = db.prepare('''
      SELECT quantityMixProductions FROM mix_productions WHERE mixProductions = ?
    ''');
      final currentData = selectStmt.select([mixProduction.mixProductionsId]);
      selectStmt.dispose();

      if (currentData.isEmpty) {
        print('⚠️ لم يتم العثور على الخلطة بالمعرف: ${mixProduction.mixProductionsId}');
        return false;
      }

      final oldQuantity = currentData.first['quantityMixProductions'];
      print('✅ الكمية قبل التعديل: $oldQuantity');

      final stmt = db.prepare('''
      UPDATE mix_productions
      SET 
        nameMixProductions = ?,
        quantityMixProductions = ?,
        employeeName = ?,
        fkEmployee = ?,
        fkPrescription = ?,
        dateTimeProduction = ?
      WHERE mixProductions = ?
    ''');

      stmt.execute([
        mixProduction.nameMixProductions,
        mixProduction.quantityMixProductions,
        mixProduction.employeeName,
        mixProduction.fkEmployee,
        mixProduction.fkPrescription,
        mixProduction.dateTimeProduction,
        mixProduction.mixProductionsId,
      ]);

      stmt.dispose();

      print('✅ الكمية بعد التعديل: ${mixProduction.quantityMixProductions}');
      return true;
    } catch (e) {
      print('خطأ في تحديث الخلطة: $e');
      return false;
    }
  }

  // حذف خلطة
  Future<bool> deleteMixProduction(int id) async {
    try {
      final stmt = db.prepare('DELETE FROM mix_productions WHERE mixProductions = ?');
      stmt.execute([id]);
      stmt.dispose();
      return true;
    } catch (e) {
      print('خطأ في حذف عملية الانتاج: $e');
      return false;
    }
  }

  // جلب قائمة الموظفين المسؤولين عن الخلطات (مفيد لاقتراحات البحث)
  Future<List<String>> getEmployeesList() async {
    try {
      final stmt = db.prepare('''
        SELECT DISTINCT employeeName
        FROM mix_productions
        ORDER BY employeeName
      ''');

      final result = stmt.select();
      List<String> employees = [];

      for (final row in result) {
        employees.add(row[0] as String);
      }

      stmt.dispose();
      return employees;
    } catch (e) {
      print('خطأ في جلب قائمة الموظفين: $e');
      return [];
    }
  }

  Future<List<MixProductionModel>> getAllCountMixProductionsUserFilter(
      String startDateSend,
      String endDateSend,
      List<int> fkPrescription,
      List<int> fkEmployee, {
        int page = 1,
        int limit = 10,
      }) async {
    try {
      final offset = (page - 1) * limit;

      List<String> whereClauses = [];
      List<dynamic> whereArgs = [];

      // فلترة بالتاريخ (بما أن التاريخ محفوظ كـ نص بصيغة YYYY-MM-DD)
      if (startDateSend.isNotEmpty && endDateSend.isNotEmpty) {
        whereClauses.add("dateTimeProduction BETWEEN ? AND ?");
        whereArgs.addAll([startDateSend, endDateSend]);
      }

      // فلترة بالوصفات
      if (fkPrescription.isNotEmpty) {
        final placeholders = List.filled(fkPrescription.length, '?').join(', ');
        whereClauses.add("fkPrescription IN ($placeholders)");
        whereArgs.addAll(fkPrescription);
      }

      // فلترة بالموظفين
      if (fkEmployee.isNotEmpty) {
        final placeholders = List.filled(fkEmployee.length, '?').join(', ');
        whereClauses.add("fkEmployee IN ($placeholders)");
        whereArgs.addAll(fkEmployee);
      }

      // بناء الاستعلام الديناميكي
      String query = '''
      SELECT 
        mixProductions,
        nameMixProductions,
        quantityMixProductions,
        employeeName,
        fkEmployee,
        fkPrescription,
        dateTimeProduction,
        createdAt
      FROM mix_productions
    ''';

      if (whereClauses.isNotEmpty) {
        query += ' WHERE ' + whereClauses.join(' AND ');
      }

      query += ' ORDER BY createdAt DESC LIMIT ? OFFSET ?';

      whereArgs.addAll([limit, offset]);

      final result = db.select(query, whereArgs);

      return result.map((row) {
        return MixProductionModel(
          mixProductionsId: row['mixProductions'],
          nameMixProductions: row['nameMixProductions'],
          quantityMixProductions: row['quantityMixProductions'],
          employeeName: row['employeeName'],
          fkEmployee: row['fkEmployee'],
          fkPrescription: row['fkPrescription'],
          dateTimeProduction: row['dateTimeProduction'],
          createdAt: DateTime.parse(row['createdAt']),
        );
      }).toList();
    } catch (e) {
      print('خطأ: $e');
      return [];
    }
  }



  // جلب إحصائيات عن الخلطات (مثل العدد الإجمالي، الموظف الأكثر إنتاجاً، إلخ)
  Future<Map<String, dynamic>> getMixProductionsStatistics() async {
    try {
      // إجمالي عدد الخلطات
      final totalStmt = db.prepare('SELECT COUNT(*) FROM mix_productions');
      final totalResult = totalStmt.select();
      final totalMixProductions = totalResult.isNotEmpty ? totalResult.first[0] as int : 0;
      totalStmt.dispose();

      // الموظف الأكثر إنتاجاً
      final topEmployeeStmt = db.prepare('''
        SELECT employeeName, COUNT(*) as count
        FROM mix_productions
        GROUP BY employeeName
        ORDER BY count DESC
        LIMIT 1
      ''');

      final topEmployeeResult = topEmployeeStmt.select();
      String topEmployee = "";
      int topEmployeeCount = 0;

      if (topEmployeeResult.isNotEmpty) {
        topEmployee = topEmployeeResult.first[0] as String;
        topEmployeeCount = topEmployeeResult.first[1] as int;
      }

      topEmployeeStmt.dispose();

      // الخلطات في الأسبوع الحالي
      final currentWeekStmt = db.prepare('''
        SELECT COUNT(*)
        FROM mix_productions
        WHERE date(createdAt) >= date('now', 'weekday 0', '-7 days')
        AND date(createdAt) <= date('now')
      ''');

      final currentWeekResult = currentWeekStmt.select();
      final currentWeekCount = currentWeekResult.isNotEmpty ? currentWeekResult.first[0] as int : 0;
      currentWeekStmt.dispose();

      return {
        'totalMixProductions': totalMixProductions,
        'topEmployee': topEmployee,
        'topEmployeeCount': topEmployeeCount,
        'currentWeekCount': currentWeekCount,
      };
    } catch (e) {
      print('خطأ في جلب إحصائيات الخلطات: $e');
      return {
        'totalMixProductions': 0,
        'topEmployee': '',
        'topEmployeeCount': 0,
        'currentWeekCount': 0,
      };
    }
  }

  // البحث عن الخلطات حسب اسم الخلطة
  Future<List<MixProductionModel>> searchMixProductionsByName(String name) async {
    try {
      final stmt = db.prepare('''
        SELECT 
          mixProductions,
          nameMixProductions,
          quantityMixProductions,
          employeeName,
          fkEmployee,
          fkPrescription,
          dateTimeProduction,
          createdAt
        FROM mix_productions
        WHERE nameMixProductions LIKE ?
        ORDER BY createdAt DESC
        LIMIT 20
      ''');

      final result = stmt.select(['%$name%']);
      List<MixProductionModel> mixProductions = [];

      for (final row in result) {
        mixProductions.add(MixProductionModel(
          mixProductionsId: row[0] as int,
          nameMixProductions: row[1] as String,
          quantityMixProductions: row[2] as int,
          employeeName: row[3] as String,
          fkEmployee: row[4] as int,
          fkPrescription: row[5] as int,
          dateTimeProduction: row[6] as String,
          createdAt: DateTime.parse(row[7] as String),
        ));
      }

      stmt.dispose();
      return mixProductions;
    } catch (e) {
      print('خطأ في البحث عن الخلطات: $e');
      return [];
    }
  }

  // إغلاق قاعدة البيانات
  void close() {
    db.dispose();
  }
}