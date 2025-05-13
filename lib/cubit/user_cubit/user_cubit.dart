import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_pvc/cubit/user_cubit/user_state.dart';
import 'package:system_pvc/data/model/user_model.dart';
import 'package:system_pvc/repo/user_repo.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepo userRepo;

  UserCubit(this.userRepo) : super(UserInitial());

  // Load users from repo
  Future<void> loadUsers() async {
    emit(UserLoading());
    try {
      final users = await userRepo.getAllUsers();  // Wait for the data
      if (users.isEmpty) {
        emit(UserError('لا توجد مستخدمين.'));
      } else {
        emit(UserLoaded(users));
      }
    } catch (e) {
      emit(UserError('فشل تحميل المستخدمين'));
    }
  }

  // Add a new user
  Future<void> addUser(UserModel user) async {
    emit(UserLoading());
    try {
      await userRepo.addUser(user);  // Wait for the user to be added
      final users = await userRepo.getAllUsers();  // Fetch updated users
      if (users.isEmpty) {
        emit(UserError('لا توجد مستخدمين بعد إضافة هذا المستخدم.'));
      } else {
        emit(UserLoaded(users));
      }
    } catch (e) {
      emit(UserError('فشل إضافة المستخدم'));
    }
  }

  // Update an existing user
  Future<void> updateUser(UserModel user) async {
    emit(UserLoading());
    try {
      await userRepo.updateUser(user);  // Wait for the update to complete
      final users = await userRepo.getAllUsers();  // Fetch updated users
      if (users.isEmpty) {
        emit(UserError('لا توجد مستخدمين بعد تعديل هذا المستخدم.'));
      } else {
        emit(UserLoaded(users));
      }
    } catch (e) {
      emit(UserError('فشل تعديل المستخدم'));
    }
  }

  // Delete a user
  Future<bool> deleteUser(int userId) async {
    emit(UserLoading());
    try {
      await userRepo.deleteUser(userId);  // Wait for the user to be deleted
      final users = await userRepo.getAllUsers();  // Fetch updated users
      if (users.isEmpty) {
        emit(UserError('لا توجد مستخدمين بعد حذف هذا المستخدم.'));
        return false;
      } else {
        emit(UserLoaded(users));
        return true;
      }
    } catch (e) {
      emit(UserError('فشل حذف المستخدم'));
      return false;

    }
  }
}
