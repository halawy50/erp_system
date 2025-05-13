import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart';
import 'package:system_pvc/data/model/user_model.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class UserDatabase {
  late Database db;
  String? _dbPath;

  // الحصول على مسار قاعدة البيانات من SharedPreferences
  Future<int> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _dbPath = prefs.getString('dbPath');
      print("object : ${_dbPath}");
      if (_dbPath == null || _dbPath!.isEmpty) {
        print('مسار قاعدة البيانات غير محدد');
        return 0;
      }

      db = sqlite3.open(_dbPath!);

      db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        userId INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        jobTitle TEXT,
        userName TEXT,
        password TEXT,
        createdAt TEXT,
        isWarehouseManagement INTEGER,
        insertWarehouseManagement INTEGER,
        updateWarehouseManagement INTEGER,
        deleteWarehouseManagement INTEGER,
        isPurchase INTEGER,
        insertPurchase INTEGER,
        updatePurchase INTEGER,
        deletePurchase INTEGER,
        isMixProduction INTEGER,
        insertMixProduction INTEGER,
        updateMixProduction INTEGER,
        deleteMixProduction INTEGER,
        isPrescriptionManagement INTEGER,
        insertPrescriptionManagement INTEGER,
        updatePrescriptionManagement INTEGER,
        deletePrescriptionManagement INTEGER,
        isHistory INTEGER,
        isInventory INTEGER,
        isAdmin INTEGER,
        isShowPrescriptions INTEGER,
      );
    ''');
      return 1;
    } catch (e) {
      print('خطأ في تهيئة قاعدة البيانات: $e');
      return 0;
    }
  }

  // للحصول على مسار قاعدة البيانات الحالي
  String? get dbPath => _dbPath;

  // طريقة للبحث عن مستخدم بناءً على البريد الإلكتروني وكلمة المرور
  Future<UserModel?> getUserByEmailAndPassword(String email, String password) async {
    try {
      // استعلام SQL لجلب بيانات مستخدم معين باستخدام البريد الإلكتروني وكلمة المرور
      final result = db.select('SELECT * FROM users WHERE userName = ? AND password = ?', [email, password]);

      if (result.isNotEmpty) {
        // تحويل البيانات إلى نموذج UserModel
        final row = result.first;
        return UserModel(
          userId: row['userId'],
          name: row['name'],
          jobTitle: row['jobTitle'],
          userName: row['userName'],
          password: row['password'],
          createdAt: DateTime.parse(row['createdAt']),
          isWarehouseManagement: row['isWarehouseManagement'] == 1,
          insertWarehouseManagement: row['insertWarehouseManagement'] == 1,
          updateWarehouseManagement: row['updateWarehouseManagement'] == 1,
          deleteWarehouseManagement: row['deleteWarehouseManagement'] == 1,
          isPurchase: row['isPurchase'] == 1,
          insertPurchase: row['insertPurchase'] == 1,
          updatePurchase: row['updatePurchase'] == 1,
          deletePurchase: row['deletePurchase'] == 1,
          isMixProduction: row['isMixProduction'] == 1,
          insertMixProduction: row['insertMixProduction'] == 1,
          updateMixProduction: row['updateMixProduction'] == 1,
          deleteMixProduction: row['deleteMixProduction'] == 1,
          isPrescriptionManagement: row['isPrescriptionManagement'] == 1,
          insertPrescriptionManagement: row['insertPrescriptionManagement'] == 1,
          updatePrescriptionManagement: row['updatePrescriptionManagement'] == 1,
          deletePrescriptionManagement: row['deletePrescriptionManagement'] == 1,
          isHistory: row['isHistory'] == 1,
          isInventory: row['isInventory'] == 1,
          isAdmin: row['isAdmin'] == 1,
          isShowPrescriptions: row['isShowPrescriptions'] == 1,
        );
      } else {
        return null; // إذا لم يتم العثور على المستخدم
      }
    } catch (e) {
      print('خطأ في جلب بيانات المستخدم: $e');
      return null;
    }
  }

// طريقة لجلب بيانات مستخدم واحد بناءً على userId
  Future<UserModel?> getUserById(int userId) async {
    try {
      // استعلام SQL لجلب بيانات مستخدم معين باستخدام userId
      final result = await db.select('SELECT * FROM users WHERE userId = ?', [userId]);

      if (result.isNotEmpty) {
        // تحويل البيانات إلى نموذج UserModel
        final row = result.first;
        return UserModel(
          userId: row['userId'],
          name: row['name'],
          jobTitle: row['jobTitle'],
          userName: row['userName'],
          password: row['password'],
          createdAt: DateTime.parse(row['createdAt']),
          isWarehouseManagement: row['isWarehouseManagement'] == 1,
          insertWarehouseManagement: row['insertWarehouseManagement'] == 1,
          updateWarehouseManagement: row['updateWarehouseManagement'] == 1,
          deleteWarehouseManagement: row['deleteWarehouseManagement'] == 1,
          isPurchase: row['isPurchase'] == 1,
          insertPurchase: row['insertPurchase'] == 1,
          updatePurchase: row['updatePurchase'] == 1,
          deletePurchase: row['deletePurchase'] == 1,
          isMixProduction: row['isMixProduction'] == 1,
          insertMixProduction: row['insertMixProduction'] == 1,
          updateMixProduction: row['updateMixProduction'] == 1,
          deleteMixProduction: row['deleteMixProduction'] == 1,
          isPrescriptionManagement: row['isPrescriptionManagement'] == 1,
          insertPrescriptionManagement: row['insertPrescriptionManagement'] == 1,
          updatePrescriptionManagement: row['updatePrescriptionManagement'] == 1,
          deletePrescriptionManagement: row['deletePrescriptionManagement'] == 1,
          isHistory: row['isHistory'] == 1,
          isInventory: row['isInventory'] == 1,
          isAdmin: row['isAdmin'] == 1,
          isShowPrescriptions: row['isShowPrescriptions'] == 1,
        );
      } else {
        return null; // إرجاع null إذا لم يتم العثور على المستخدم
      }
    } catch (e) {
      print('خطأ في جلب بيانات المستخدم: $e');
      return null; // إرجاع null في حالة حدوث استثناء
    }
  }


  Future<int> insertUser(UserModel user) async {
    try {
      final stmt = db.prepare('''
      INSERT INTO users (
        name, jobTitle, userName, password, createdAt,
        isWarehouseManagement, insertWarehouseManagement, updateWarehouseManagement, deleteWarehouseManagement,
        isPurchase, insertPurchase, updatePurchase, deletePurchase,
        isMixProduction, insertMixProduction, updateMixProduction, deleteMixProduction,
        isPrescriptionManagement, insertPrescriptionManagement, updatePrescriptionManagement, deletePrescriptionManagement,
        isHistory, isInventory, isAdmin, isShowPrescriptions
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? , ?)
    ''');

      stmt.execute([
        user.name,
        user.jobTitle,
        user.userName,
        user.password,
        user.createdAt.toIso8601String(),
        user.isWarehouseManagement ? 1 : 0,
        user.insertWarehouseManagement ? 1 : 0,
        user.updateWarehouseManagement ? 1 : 0,
        user.deleteWarehouseManagement ? 1 : 0,
        user.isPurchase ? 1 : 0,
        user.insertPurchase ? 1 : 0,
        user.updatePurchase ? 1 : 0,
        user.deletePurchase ? 1 : 0,
        user.isMixProduction ? 1 : 0,
        user.insertMixProduction ? 1 : 0,
        user.updateMixProduction ? 1 : 0,
        user.deleteMixProduction ? 1 : 0,
        user.isPrescriptionManagement ? 1 : 0,
        user.insertPrescriptionManagement ? 1 : 0,
        user.updatePrescriptionManagement ? 1 : 0,
        user.deletePrescriptionManagement ? 1 : 0,
        user.isHistory ? 1 : 0,
        user.isInventory ? 1 : 0,
        user.isAdmin ? 1 : 0,
        user.isShowPrescriptions ? 1 : 0,
      ]);

      stmt.dispose();
      return 1;
    } catch (e) {
      print('خطأ في إدخال المستخدم: $e');
      return 0;
    }
  }

  Future<List<UserModel>> getUsers() async {
    final result = db.select('SELECT * FROM users');

    return result.map((row) {
      return UserModel(
        userId: row['userId'],
        name: row['name'],
        jobTitle: row['jobTitle'],
        userName: row['userName'],
        password: row['password'],
        createdAt: DateTime.parse(row['createdAt']),
        isWarehouseManagement: row['isWarehouseManagement'] == 1,
        insertWarehouseManagement: row['insertWarehouseManagement'] == 1,
        updateWarehouseManagement: row['updateWarehouseManagement'] == 1,
        deleteWarehouseManagement: row['deleteWarehouseManagement'] == 1,
        isPurchase: row['isPurchase'] == 1,
        insertPurchase: row['insertPurchase'] == 1,
        updatePurchase: row['updatePurchase'] == 1,
        deletePurchase: row['deletePurchase'] == 1,
        isMixProduction: row['isMixProduction'] == 1,
        insertMixProduction: row['insertMixProduction'] == 1,
        updateMixProduction: row['updateMixProduction'] == 1,
        deleteMixProduction: row['deleteMixProduction'] == 1,
        isPrescriptionManagement: row['isPrescriptionManagement'] == 1,
        insertPrescriptionManagement: row['insertPrescriptionManagement'] == 1,
        updatePrescriptionManagement: row['updatePrescriptionManagement'] == 1,
        deletePrescriptionManagement: row['deletePrescriptionManagement'] == 1,
        isHistory: row['isHistory'] == 1,
        isInventory: row['isInventory'] == 1,
        isAdmin: row['isAdmin'] == 1,
        isShowPrescriptions: row['isShowPrescriptions'] == 1,


      );
    }).toList();
  }

  Future<int> updateUser(UserModel user) async {
    try {
      print('محاولة التحديث للمستخدم: ${user.userId}');
      final stmt = db.prepare('''
      UPDATE users SET
        name = ?, jobTitle = ?, userName = ?, password = ?, createdAt = ?,
        isWarehouseManagement = ?, insertWarehouseManagement = ?, updateWarehouseManagement = ?, deleteWarehouseManagement = ?,
        isPurchase = ?, insertPurchase = ?, updatePurchase = ?, deletePurchase = ?,
        isMixProduction = ?, insertMixProduction = ?, updateMixProduction = ?, deleteMixProduction = ?,
        isPrescriptionManagement = ?, insertPrescriptionManagement = ?, updatePrescriptionManagement = ?, deletePrescriptionManagement = ?,
        isHistory = ?, isInventory = ?, isAdmin = ? , isShowPrescriptions = ?
      WHERE userId = ?
    ''');

      stmt.execute([
        user.name,
        user.jobTitle,
        user.userName,
        user.password,
        user.createdAt.toIso8601String(),
        user.isWarehouseManagement ? 1 : 0,
        user.insertWarehouseManagement ? 1 : 0,
        user.updateWarehouseManagement ? 1 : 0,
        user.deleteWarehouseManagement ? 1 : 0,
        user.isPurchase ? 1 : 0,
        user.insertPurchase ? 1 : 0,
        user.updatePurchase ? 1 : 0,
        user.deletePurchase ? 1 : 0,
        user.isMixProduction ? 1 : 0,
        user.insertMixProduction ? 1 : 0,
        user.updateMixProduction ? 1 : 0,
        user.deleteMixProduction ? 1 : 0,
        user.isPrescriptionManagement ? 1 : 0,
        user.insertPrescriptionManagement ? 1 : 0,
        user.updatePrescriptionManagement ? 1 : 0,
        user.deletePrescriptionManagement ? 1 : 0,
        user.isHistory ? 1 : 0,
        user.isInventory ? 1 : 0,
        user.isAdmin ? 1 : 0,
        user.isShowPrescriptions ? 1 : 0,
        user.userId
      ]);

      stmt.dispose();
      print('تم تحديث المستخدم بنجاح');

      return 1; // نجاح التحديث
    } catch (e) {
      print('خطأ في تحديث المستخدم: $e');
      return 0; // فشل التحديث
    }
  }




  int deleteUser(int userId) {
    final stmt = db.prepare('DELETE FROM users WHERE userId = ?');
    try {
      stmt.execute([userId]);
      return db.getUpdatedRows(); // ترجع عدد الصفوف المتأثرة
    } finally {
      stmt.dispose();
    }
  }

  // طريقة لجلب مسار قاعدة البيانات مباشرة من جدول settings
  Future<String?> getDatabasePathFromSettings() async {
    try {
      if (db != null) {
        final result = db.select('SELECT dbPath FROM settings LIMIT 1');
        if (result.isNotEmpty) {
          return result.first['dbPath'] as String?;
        }
      }
      return null;
    } catch (e) {
      print('خطأ في جلب مسار قاعدة البيانات من جدول settings: $e');
      return null;
    }
  }

  Future<void> close() async {
    db.dispose();
  }
}