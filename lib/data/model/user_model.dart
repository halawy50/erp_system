class UserModel {
  int userId;
  String name;
  String jobTitle;
  String userName;
  String password;
  final DateTime createdAt;

  // إدارة المخزن
  bool isWarehouseManagement;
  bool insertWarehouseManagement;
  bool updateWarehouseManagement;
  bool deleteWarehouseManagement;

  // عمليات الشراء
  bool isPurchase;
  bool insertPurchase;
  bool updatePurchase;
  bool deletePurchase;

  // إنتاج الخلطات
  bool isMixProduction;
  bool insertMixProduction;
  bool updateMixProduction;
  bool deleteMixProduction;

  // إدارة الخلطات
  bool isPrescriptionManagement;
  bool insertPrescriptionManagement;
  bool updatePrescriptionManagement;
  bool deletePrescriptionManagement;

  // العمليات السابقة
  bool isHistory;

  // الجرد
  bool isInventory;

  // خاصية المسؤول
  bool isAdmin;

  UserModel({
    this.userId = 0,
    this.name = '',
    this.jobTitle = '',
    this.userName = '',
    this.password = '',
    DateTime? createdAt,

    // إدارة المخزن
    this.isWarehouseManagement = false,
    this.insertWarehouseManagement = false,
    this.updateWarehouseManagement = false,
    this.deleteWarehouseManagement = false,

    // عمليات الشراء
    this.isPurchase = false,
    this.insertPurchase = false,
    this.updatePurchase = false,
    this.deletePurchase = false,

    // إنتاج الخلطات
    this.isMixProduction = false,
    this.insertMixProduction = false,
    this.updateMixProduction = false,
    this.deleteMixProduction = false,

    // إدارة الخلطات
    this.isPrescriptionManagement = false,
    this.insertPrescriptionManagement = false,
    this.updatePrescriptionManagement = false,
    this.deletePrescriptionManagement = false,

    // العمليات السابقة
    this.isHistory = false,

    // الجرد
    this.isInventory = false,

    // خاصية المسؤول
    this.isAdmin = false,
  }) : createdAt = createdAt ?? DateTime.now();
}
