import 'package:system_pvc/data/model/user_model.dart';
import 'package:system_pvc/local/user_database.dart';

class UserRepo {
  final UserDatabase _dbHelper;

  UserRepo(this._dbHelper);

  // تهيئة قاعدة البيانات
  Future<void> init() async {
    await _dbHelper.init();
  }

  // إضافة مستخدم جديد، إرجاع true إذا تمت الإضافة بنجاح
  Future<bool> addUser(UserModel user) async {
    try {
      int result = await _dbHelper.insertUser(user);
      return result > 0;
    } catch (e) {
      print("Error adding user: $e");
      return false; // إعادة false في حالة حدوث خطأ
    }
  }

  // جلب بيانات المستخدم بواسطة userId
  Future<UserModel?> getUserById(int userId) async {
    try {
      return await _dbHelper.getUserById(userId);
    } catch (e) {
      print("Error getting user by ID: $e");
      return null; // إعادة null في حالة حدوث خطأ
    }
  }

  // جلب جميع المستخدمين
  Future<List<UserModel>> getAllUsers() async {
    try {
      return await _dbHelper.getUsers();
    } catch (e) {
      print("Error getting all users: $e");
      return []; // إعادة قائمة فارغة في حالة حدوث خطأ
    }
  }

  // تحديث بيانات المستخدم، إرجاع true إذا تم التحديث بنجاح
  Future<bool> updateUser(UserModel user) async {
    if (user.userId == null || user.userId == 0) {
      print("خطأ: userId غير صالح");
      return false; // التحقق من صلاحية userId
    }

    try {
      int result = await _dbHelper.updateUser(user);
      if (result > 0) {
        print("تم تحديث المستخدم بنجاح");
        return true;
      } else {
        print("فشل في تحديث المستخدم");
        return false;
      }
    } catch (e) {
      print("Error updating user: $e");
      return false;
    }
  }


  // حذف مستخدم بناءً على userId، إرجاع true إذا تم الحذف بنجاح
  Future<bool> deleteUser(int userId) async {
    try {
      int result = await _dbHelper.deleteUser(userId);
      return result > 0;
    } catch (e) {
      print("Error deleting user: $e");
      return false; // إعادة false في حالة حدوث خطأ
    }
  }

  // جلب بيانات المستخدم بواسطة البريد الإلكتروني وكلمة المرور
  Future<UserModel?> getUserByEmailAndPassword(String email, String password) async {
    try {
      return await _dbHelper.getUserByEmailAndPassword(email, password);
    } catch (e) {
      print("Error getting user by email and password: $e");
      return null; // إعادة null في حالة حدوث خطأ
    }
  }

  // إغلاق قاعدة البيانات
  Future<void> dispose() async {
    await _dbHelper.close();
  }
}
