import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_pvc/components/show_snak_bar.dart';
import 'package:system_pvc/components/tableUser.dart';
import 'package:system_pvc/constant/color.dart';
import 'package:system_pvc/constant/stream.dart';
import 'package:system_pvc/cubit/user_cubit/user_cubit.dart';
import 'package:system_pvc/cubit/user_cubit/user_state.dart';
import 'package:system_pvc/local/user_database.dart';
import 'package:system_pvc/repo/user_repo.dart';
import 'package:system_pvc/screens/home_screen/pages/setting_page/sup_page/add_employee_page.dart';
import 'package:system_pvc/screens/home_screen/pages/setting_page/sup_page/edit_employee_page.dart';

class SettingPage extends StatefulWidget {
  final UserRepo userRepo;
  SettingPage({super.key, required this.userRepo});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  bool isPasswordEmpty = false;
  bool isPasswordValid = true;
  bool isPasswordVisible = false;

  // Error messages
  String? nameError;
  String? emailError;
  String? passwordError;

  late UserCubit _userCubit;

  Map<String, String> headers = {
    "id": "رقم الموظف",
    "name": "الاسم",
    "jobTitle": "المسمي الوظيفي",
    "hireDate": "تاريخ التوظيف",
    "permissions": "الصلاحيات",
  };

  @override
  void initState() {
    super.initState();

    // Initialize the UserCubit
    _userCubit = UserCubit(widget.userRepo);

    // Load users when the page initializes
    _userCubit.loadUsers();

    _nameController.text = "${StreamData.userModel.name}";
    _jobTitleController.text = "${StreamData.userModel.jobTitle}";
    _emailController.text = "${StreamData.userModel.userName}";
    _passwordController.text = "${StreamData.userModel.password}";

    _nameController.addListener(_updateState);
    _jobTitleController.addListener(_updateState);
    _emailController.addListener(_updateState);
    _passwordController.addListener(_updateState);
  }

  void _updateState() {
    setState(() {}); // إعادة بناء الواجهة لتحديث لون الزر
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jobTitleController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _userCubit.close(); // Don't forget to close the cubit
    super.dispose();
  }

  void validateAndSave() {
    setState(() {
      nameError = _nameController.text.isEmpty ? "برجاء إدخال الاسم" : null;
      emailError = !_emailController.text.contains('@') ? "بريد غير صالح" : null;
      passwordError = _passwordController.text.isEmpty
          ? "برجاء إدخال كلمة المرور"
          : (_passwordController.text.length < 6 ? "كلمة المرور ضعيفة (6 أحرف على الأقل)" : null);
    });

    if (nameError == null && emailError == null && passwordError == null) {
      // تم التحقق: نفذ الحفظ هنا
      print("تم التحقق، جاري الحفظ...");
      StreamData.userModel.name = _nameController.text;
      StreamData.userModel.userName = _emailController.text;
      StreamData.userModel.password = _passwordController.text;

      // إرسال البيانات المحدثة إلى الكيوبت
      _userCubit.updateUser(StreamData.userModel);

      // عرض Snackbar باللون الأخضر
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ البيانات بنجاح'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // showSnackbar(context, "setting");
    print("FFFUCL");
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              //header
              Container(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "اعدادات النظام",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: ColorApp.black),
                        ),
                        Text(
                          "التحكم في الحساب",
                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20, color: ColorApp.black),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: validateAndSave,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        height: 55,
                        color: (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty)
                            ? ColorApp.grey
                            : ColorApp.blue,
                        child: Text("حفظ الاعدادات", style: TextStyle(fontSize: 20, color: ColorApp.white)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Form fields
              Container(
                child: Column(
                  children: [
                    // Name field
                    Container(
                      child:  TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "الاسم بالكامل",
                          errorText: nameError,
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: ColorApp.blue),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Email field
                    Container(
                      child: TextField(
                        controller: _jobTitleController,
                        readOnly: true, // ❌ غير قابل للتعديل
                        decoration: InputDecoration(
                          labelText: "المسمي الوظيفي",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: ColorApp.blue),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Email field
                    Container(
                      child:  TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "البريد الاليكتروني",
                          errorText: emailError,
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: ColorApp.blue),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Password field
                    Container(
                      child: TextField(
                        controller: _passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: "كلمة المرور",
                          errorText: passwordError,
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: ColorApp.blue),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),
              StreamData.userModel.isAdmin?
              Divider(color: Colors.grey, thickness: 1) : Container(),
              SizedBox(height: 20),


              StreamData.userModel.isAdmin?
              // Employees section
              Container(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "الموظفيين",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: ColorApp.black),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEmployeePage(userRepo: widget.userRepo),
                                ),
                              ).then((_) {
                                // Refresh user list when returning from add page
                                _userCubit.loadUsers();
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                color: ColorApp.blue.withAlpha(20),
                              ),
                              height: 55,
                              child: Text(
                                "اضف موظف",
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 20,
                                  color: ColorApp.blue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // User table with proper BlocProvider
                    BlocProvider.value(
                      value: _userCubit,
                      child: BlocBuilder<UserCubit, UserState>(
                        builder: (context, state) {
                          if (state is UserLoading) {
                            return Center(child: CircularProgressIndicator());
                          } else if (state is UserLoaded) {
                            if (state.users.isEmpty) {
                              return Center(child: Text("لا توجد بيانات لعرضها"));
                            }

                            List<Map<String, String>> data = state.users.map((user) {
                              return {
                                "id": user.userId.toString(),
                                "isAdmin": user.isAdmin==true ? "true" : "false",
                                "name": user.name,
                                "jobTitle": user.jobTitle,
                                "hireDate": user.createdAt.toString().split(' ').first,
                                "permissions": permession(
                                  user.isWarehouseManagement,
                                  user.insertWarehouseManagement,
                                  user.updateWarehouseManagement,
                                  user.deleteWarehouseManagement,

                                  user.isPurchase,
                                  user.insertPurchase,
                                  user.updatePurchase,
                                  user.deletePurchase,

                                  user.isMixProduction,
                                  user.insertMixProduction,
                                  user.updateMixProduction,
                                  user.deleteMixProduction,

                                  user.isPrescriptionManagement,
                                  user.insertPrescriptionManagement,
                                  user.updatePrescriptionManagement,
                                  user.deletePrescriptionManagement,

                                  user.isInventory,
                                  user.isHistory,
                                  user.isShowPrescriptions,
                                ) ?? "", // Assuming permissions field exists
                              };
                            }).toList();


                            return tableUsers(
                              headers: headers,
                              rows: data,
                              onEdit: (index) {
                                // Handle edit action
                                print("تعديل السطر رقم $index");

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditEmployeePage(
                                      userRepo: widget.userRepo
                                      , userModel:state.users[index] ,
                                    ),
                                  ),
                                ).then((_) {
                                  // Refresh user list when returning from add page
                                  _userCubit.loadUsers();
                                });

                                // Implement edit functionality
                              },
                              onDelete: (index) {
                                // Handle delete action
                                print("حذف السطر رقم $index");
                                // Show confirmation dialog
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("تأكيد الحذف"),
                                    content: Text("هل أنت متأكد من حذف هذا المستخدم؟"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("إلغاء"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          // Delete the user and refresh the list
                                          bool isDelete = await _userCubit.deleteUser(int.parse(data[index]["id"]!));
                                          if(isDelete){
                                            showSnackbar(context, "تم حذف الموظف" , backgroundColor: Colors.green);
                                            Navigator.pop(context);
                                          }else{
                                            showSnackbar(context, "حدث خطأ ما" , backgroundColor: Colors.red);
                                          }

                                        },
                                        child: Text("حذف", style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          } else if (state is UserError) {
                            return Center(child: Text(state.message));
                          }
                          // Initial state or any other state
                          return Center(child: Text("برجاء تحميل البيانات"));
                        },
                      ),
                    )
                  ],
                ),
              ) : Container(),
            ],
          ),
        ),
      ),
    );
  }

  String permession(
      bool isWarehouseManagement,
      bool isInsertWarehouseManagement,
      bool isUpdateWarehouseManagement,
      bool isDeleteWarehouseManagement,
      bool isPurchase,
      bool isInsertPurchase,
      bool isUpdatePurchase,
      bool isDeletePurchase,
      bool isMixProduction,
      bool isInsertMixProduction,
      bool isUpdateMixProduction,
      bool isDeleteMixProduction,
      bool isPrescriptionManagement,
      bool isInsertPrescriptionManagement,
      bool isUpdatePrescriptionManagement,
      bool isDeletePrescriptionManagement,
      bool isInventory,
      bool isHistory,
      bool isShowPrescriptions,
      ) {
    String permissions = "";

    // إدارة المخزن
    permissions += "ادارة المخزن : ";
    if (isWarehouseManagement) {
      permissions += "مصرح (";
      if (isInsertWarehouseManagement) permissions += "إضافة, ";
      if (isUpdateWarehouseManagement) permissions += "تعديل, ";
      if (isDeleteWarehouseManagement) permissions += "حذف, ";
      if (isDeleteWarehouseManagement) permissions += "عرض احصائيات الخلطات";
      permissions += ")\n";
    } else {
      permissions += "غير مصرح\n";
    }

    // عمليات الشراء
    permissions += "عمليات الشراء : ";
    if (isPurchase) {
      permissions += "مصرح (";
      if (isInsertPurchase) permissions += "إضافة, ";
      if (isUpdatePurchase) permissions += "تعديل, ";
      if (isDeletePurchase) permissions += "حذف";
      permissions += ")\n";
    } else {
      permissions += "غير مصرح\n";
    }

    // انتاج خلطة
    permissions += "إنتاج خلطة : ";
    if (isMixProduction) {
      permissions += "مصرح (";
      if (isInsertMixProduction) permissions += "إضافة, ";
      if (isUpdateMixProduction) permissions += "تعديل, ";
      if (isDeleteMixProduction) permissions += "حذف";
      permissions += ")\n";
    } else {
      permissions += "غير مصرح\n";
    }

    // إدارة الوصفة
    permissions += "إدارة الوصفة : ";
    permissions += isPrescriptionManagement ? "مصرح\n" : "غير مصرح\n";

    // الجرد
    permissions += "الجرد : ";
    permissions += isInventory ? "مصرح\n" : "غير مصرح\n";

    // التاريخ
    permissions += "تتبع العمليات : ";
    permissions += isHistory ? "مصرح\n" : "غير مصرح\n";

    return permissions;
  }

}