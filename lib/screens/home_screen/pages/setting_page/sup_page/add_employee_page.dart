import 'package:flutter/material.dart';
import 'package:system_pvc/components/button_back.dart';
import 'package:system_pvc/components/show_snak_bar.dart';
import 'package:system_pvc/constant/color.dart'; // تأكد من استيراد buttonBack
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:system_pvc/data/model/user_model.dart';
import 'package:system_pvc/repo/user_repo.dart';

class AddEmployeePage extends StatefulWidget {
  UserRepo userRepo;
  AddEmployeePage({super.key , required this.userRepo});

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _jobTitleController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool isDialog = false;
  // ادارة المخازن
  Map<String, dynamic>? isWarehouseManagement; // Keep this as a Map
  bool isAddWarehouseManagement = false;
  bool isUpdateWarehouseManagement = false;
  bool isDeleteWarehouseManagement = false;
  bool isShowPrescriptions = false;
  final List<Map<String, dynamic>> itemsWarehouseManagement = [
    {'name': 'ظاهر', 'isSelected': true},
    {'name': 'مخفي', 'isSelected': false},
  ];

  // عمليات الشراء
  Map<String, dynamic>? isPurchase; // Keep this as a Map
  bool isAddPurchase = false;
  bool isUpdatePurchase = false;
  bool isDeletePurchase = false;
  final List<Map<String, dynamic>> itemsPurchase = [
    {'name': 'ظاهر', 'isSelected': true},
    {'name': 'مخفي', 'isSelected': false},
  ];

  // انتاج الحلطات
  Map<String, dynamic>? isMixProduction; // Keep this as a Map
  bool isAddMixProduction = false;
  bool isUpdateMixProduction = false;
  bool isDeleteMixProduction = false;
  final List<Map<String, dynamic>> itemsMixProduction = [
    {'name': 'ظاهر', 'isSelected': true},
    {'name': 'مخفي', 'isSelected': false},
  ];

  // ادارة الخلطات
  Map<String, dynamic>? isPrescriptionManagement; // Keep this as a Map
  bool isAddPrescriptionManagement = false;
  bool isUpdatePrescriptionManagement = false;
  bool isDeletePrescriptionManagement = false;
  final List<Map<String, dynamic>> itemsPrescriptionManagement = [
    {'name': 'ظاهر', 'isSelected': true},
    {'name': 'مخفي', 'isSelected': false},
  ];

  // الجرد
  Map<String, dynamic>? isInventory; // Keep this as a Map
  final List<Map<String, dynamic>> itemsInventory = [
    {'name': 'تفعيل الجرد', 'isSelected': true},
    {'name': 'مخفي', 'isSelected': false},
  ];

  // تتبع العمليات
  Map<String, dynamic>? isHistory; // Keep this as a Map
  final List<Map<String, dynamic>> itemsHistory = [
    {'name': 'تفعيل تتبع العمليات', 'isSelected': true},
    {'name': 'مخفي', 'isSelected': false},
  ];


  @override
  void initState() {
    super.initState();

    isWarehouseManagement = itemsWarehouseManagement[0];
    isPurchase = itemsPurchase[0];
    isMixProduction = itemsMixProduction[0];
    isPrescriptionManagement = itemsPrescriptionManagement[0];
    isInventory = itemsInventory[0];
    isHistory = itemsHistory[0];

    _nameController.addListener(_updateState);
    _emailController.addListener(_updateState);
    _jobTitleController.addListener(_updateState);
    _passwordController.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30.0 , left: 30 , right: 30),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: buttonBack(context, (bool value) {
                      if (value) {
                            setState(() {
                              isDialog = value;
                            });
                      }
                    })
                  ),
                  SizedBox(height: 30),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "اضف موظف جديد",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                        InkWell(
                          onTap: () async {

                            if(_nameController.text.isNotEmpty &&
                                _emailController.text.isNotEmpty &&
                                _passwordController.text.isNotEmpty &&
                                _jobTitleController.text.isNotEmpty
                            ){
                              UserModel user = UserModel(
                                name: "${_nameController.text}",
                                userName: "${_emailController.text}",
                                password: "${_passwordController.text}",
                                jobTitle: "${_jobTitleController.text}",
                                isAdmin: false,
                                //ادارة المخزن
                                isWarehouseManagement: isWarehouseManagement?['isSelected'],
                                insertWarehouseManagement: isAddWarehouseManagement,
                                updateWarehouseManagement: isUpdateWarehouseManagement,
                                deleteWarehouseManagement: isDeleteWarehouseManagement,
                                isShowPrescriptions: isShowPrescriptions,
                                //عملية الشراء
                                isPurchase: isPurchase?['isSelected'],
                                insertPurchase: isAddPurchase,
                                updatePurchase: isUpdatePurchase,
                                deletePurchase : isDeletePurchase,
                                //انتاج الخلطات
                                isMixProduction: isMixProduction?['isSelected'],
                                insertMixProduction: isAddMixProduction,
                                updateMixProduction: isUpdateMixProduction,
                                deleteMixProduction : isDeleteMixProduction,
                                //ادارة الخلطات
                                isPrescriptionManagement : isPrescriptionManagement?['isSelected'],
                                insertPrescriptionManagement: isAddPrescriptionManagement,
                                updatePrescriptionManagement: isUpdatePrescriptionManagement,
                                deletePrescriptionManagement : isDeletePrescriptionManagement,
                                //الجرد
                                isInventory : isInventory?['isSelected'],
                                //تتبع العمليات
                                isHistory : isHistory?['isSelected'],
                              );
                              bool isAddUser =await widget.userRepo.addUser(user);
                              if(isAddUser){
                                showSnackbar(context, "تم اضافة موظف جديد بنجاح" , backgroundColor: Colors.green);
                                Navigator.pop(context);

                              }else{
                                showSnackbar(context, "حدث خطأ ما" , backgroundColor: Colors.red);
                              }

                            }

                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              color: (_nameController.text.isEmpty ||
                                  _emailController.text.isEmpty ||
                                  _passwordController.text.isEmpty ||
                                  _jobTitleController.text.isEmpty
                              )
                                  ? ColorApp.gray
                                  : ColorApp.blue,
                            ),
                            height: 55,
                            child: Text(
                              "اضف موظف",
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 20,
                                color: ColorApp.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  Container(
                    child: Column(
                      children: [
                        Container(
                          child: TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: "الاسم بالكامل",
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: ColorApp.blue),
                                ),
                              )),
                        ),

                        SizedBox(height: 20),

                        Container(
                          child: TextField(
                              controller: _jobTitleController,
                              decoration: InputDecoration(
                                labelText: "المسمي الوظيفي",
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: ColorApp.blue),
                                ),
                              )),
                        ),

                        SizedBox(height: 20),

                        Container(
                          child: TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: "البريد الاليكتروني",
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: ColorApp.blue),
                                ),
                              )),
                        ),

                        SizedBox(height: 20),
                        Container(
                          child: TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: "كلمة المرور",
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: ColorApp.blue),
                                ),
                              )),
                        ),

                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: 300,

                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("الصلاحيات",
                            style: TextStyle(
                                color: ColorApp.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),

                        SizedBox(height: 30),

                        //قسم ادارة المخزن
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("القسم",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal)),
                              Text("ادارة المخزن",
                                  style: TextStyle(
                                      color: ColorApp.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal)),

                              SizedBox(height: 15),

                              Row(
                                children: [
                                  Text("حالته: ",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal)),
                                  // هل قسم (ادارة المخزن ظاهر)
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton2<Map<String, dynamic>>(
                                      isExpanded: true,
                                      hint: Text(
                                        'اختر',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                      items: itemsWarehouseManagement.map((Map<String, dynamic> item) {
                                        return DropdownMenuItem<Map<String, dynamic>>(
                                          value: item, // Set map as the value
                                          child: Text(
                                            item['name'], // Show 'name' value in the dropdown
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      value: isWarehouseManagement, // Bind map to selectedValue
                                      onChanged: (Map<String, dynamic>? value) {
                                        setState(() {
                                          isWarehouseManagement = value;

                                          if(isWarehouseManagement?['isSelected']==false){
                                            isAddWarehouseManagement = false;
                                            isUpdateWarehouseManagement = false;
                                            isDeleteWarehouseManagement = false;
                                            isShowPrescriptions = false;
                                          }
                                        });
                                      },
                                      buttonStyleData: const ButtonStyleData(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        height: 40,
                                        width: 200,
                                      ),
                                      menuItemStyleData: const MenuItemStyleData(
                                        height: 40,
                                      ),
                                    ),
                                  ),

                                ],
                              ),

                              SizedBox(height: 15,),


                              // permessions
                              isWarehouseManagement?['isSelected']==false ? Container() :
                              Container(
                                child: Column(
                                  children: [
                                    // Add
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                            value: isAddWarehouseManagement,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                isAddWarehouseManagement = value ?? false;
                                              });
                                            },
                                            activeColor: ColorApp.blue,
                                            checkColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          Text(
                                            "يمكنه (اضافة) موارد جديدة",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 10),

                                    // Update
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                            value: isUpdateWarehouseManagement,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                isUpdateWarehouseManagement = value ?? false;
                                              });
                                            },
                                            activeColor: ColorApp.blue,
                                            checkColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          Text(
                                            "يمكنه (تعديل) بيانات الموارد",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 10),

                                    // Delete
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                            value: isDeleteWarehouseManagement,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                isDeleteWarehouseManagement = value ?? false;
                                              });
                                            },
                                            activeColor: ColorApp.blue,
                                            checkColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          Text(
                                            "يمكنه (حذف) بيانات الموارد",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // show Prescriptions
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                            value: isShowPrescriptions,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                isShowPrescriptions = value ?? false;
                                              });
                                            },
                                            activeColor: ColorApp.blue,
                                            checkColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          Text(
                                            "عرض احصائيات الخلطات",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),

                        SizedBox(height: 10,),
                        Divider(color: ColorApp.gray,),

                        //قسم عمليات الشراء
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("القسم",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal)),
                              Text("عمليات الشراء",
                                  style: TextStyle(
                                      color: ColorApp.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal)),

                              SizedBox(height: 15),

                              Row(
                                children: [
                                  Text("حالته: ",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal)),
                                  // هل قسم (ادارة المخزن ظاهر)
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton2<Map<String, dynamic>>(
                                      isExpanded: true,
                                      hint: Text(
                                        'اختر',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                      items: itemsPurchase.map((Map<String, dynamic> item) {
                                        return DropdownMenuItem<Map<String, dynamic>>(
                                          value: item, // Set map as the value
                                          child: Text(
                                            item['name'], // Show 'name' value in the dropdown
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      value: isPurchase, // Bind map to selectedValue
                                      onChanged: (Map<String, dynamic>? value) {
                                        setState(() {
                                          isPurchase = value;

                                          if(isPurchase?['isSelected']==false){
                                            isAddPurchase = false;
                                            isUpdatePurchase = false;
                                            isDeletePurchase = false;
                                          }
                                        });
                                      },
                                      buttonStyleData: const ButtonStyleData(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        height: 40,
                                        width: 200,
                                      ),
                                      menuItemStyleData: const MenuItemStyleData(
                                        height: 40,
                                      ),
                                    ),
                                  ),

                                ],
                              ),

                              SizedBox(height: 15,),


                              // permessions
                              isPurchase?['isSelected']==false ? Container() :
                              Container(
                                child: Column(
                                  children: [
                                    // Add
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                            value: isAddPurchase,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                isAddPurchase = value ?? false;
                                              });
                                            },
                                            activeColor: ColorApp.blue,
                                            checkColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          Text(
                                            "يمكنه (اضافة) عمليات شراء",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 10),

                                    // Update
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                            value: isUpdatePurchase,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                isUpdatePurchase = value ?? false;
                                              });
                                            },
                                            activeColor: ColorApp.blue,
                                            checkColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          Text(
                                            "يمكنه (تعديل) عمليات الشراء",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 10),

                                    // Delete
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                            value: isDeletePurchase,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                isDeletePurchase = value ?? false;
                                              });
                                            },
                                            activeColor: ColorApp.blue,
                                            checkColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          Text(
                                            "يمكنه (حذف) عمليات الشراء",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),


                        SizedBox(height: 10,),
                        Divider(color: ColorApp.gray,),

                        //قسم انتاج الخلطات
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("القسم",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal)),
                              Text("انتاج الخلطات",
                                  style: TextStyle(
                                      color: ColorApp.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal)),

                              SizedBox(height: 15),

                              Row(
                                children: [
                                  Text("حالته: ",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal)),
                                  // هل قسم (ادارة المخزن ظاهر)
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton2<Map<String, dynamic>>(
                                      isExpanded: true,
                                      hint: Text(
                                        'اختر',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                      items: itemsMixProduction.map((Map<String, dynamic> item) {
                                        return DropdownMenuItem<Map<String, dynamic>>(
                                          value: item, // Set map as the value
                                          child: Text(
                                            item['name'], // Show 'name' value in the dropdown
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      value: isMixProduction, // Bind map to selectedValue
                                      onChanged: (Map<String, dynamic>? value) {
                                        setState(() {
                                          isMixProduction = value;

                                          if(isMixProduction?['isSelected']==false){
                                            isAddMixProduction = false;
                                            isUpdateMixProduction = false;
                                            isDeleteMixProduction = false;
                                          }
                                        });
                                      },
                                      buttonStyleData: const ButtonStyleData(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        height: 40,
                                        width: 200,
                                      ),
                                      menuItemStyleData: const MenuItemStyleData(
                                        height: 40,
                                      ),
                                    ),
                                  ),

                                ],
                              ),

                              SizedBox(height: 15,),


                              // permessions
                              isMixProduction?['isSelected']==false ? Container() :
                              Container(
                                child: Column(
                                  children: [
                                    // Add
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                            value: isAddMixProduction,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                isAddMixProduction = value ?? false;
                                              });
                                            },
                                            activeColor: ColorApp.blue,
                                            checkColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          Text(
                                            "يمكنه (انتاج) خلطات",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 10),

                                    // Update
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                            value: isUpdateMixProduction,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                isUpdateMixProduction = value ?? false;
                                              });
                                            },
                                            activeColor: ColorApp.blue,
                                            checkColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          Text(
                                            "يمكنه (تعديل) عمليات انتاج الخلطات",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 10),

                                    // Delete
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                            value: isDeleteMixProduction,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                isDeleteMixProduction = value ?? false;
                                              });
                                            },
                                            activeColor: ColorApp.blue,
                                            checkColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          Text(
                                            "يمكنه (حذف) عمليات انتاج الخلطات",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),


                        SizedBox(height: 10,),
                        Divider(color: ColorApp.gray,),

                        // //قسم ادارة الخلطات
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("القسم",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal)),
                              Text("ادارة الخلطات",
                                  style: TextStyle(
                                      color: ColorApp.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal)),

                              SizedBox(height: 15),

                              Row(
                                children: [
                                  Text("حالته: ",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal)),
                                  // هل قسم (ادارة المخزن ظاهر)
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton2<Map<String, dynamic>>(
                                      isExpanded: true,
                                      hint: Text(
                                        'اختر',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                      items: itemsPrescriptionManagement.map((Map<String, dynamic> item) {
                                        return DropdownMenuItem<Map<String, dynamic>>(
                                          value: item, // Set map as the value
                                          child: Text(
                                            item['name'], // Show 'name' value in the dropdown
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      value: isPrescriptionManagement, // Bind map to selectedValue
                                      onChanged: (Map<String, dynamic>? value) {
                                        setState(() {
                                          isPrescriptionManagement = value;

                                          if(isPrescriptionManagement?['isSelected']==false){
                                            isAddPrescriptionManagement = false;
                                            isUpdatePrescriptionManagement = false;
                                            isDeletePrescriptionManagement = false;
                                          }
                                        });
                                      },
                                      buttonStyleData: const ButtonStyleData(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        height: 40,
                                        width: 200,
                                      ),
                                      menuItemStyleData: const MenuItemStyleData(
                                        height: 40,
                                      ),
                                    ),
                                  ),

                                ],
                              ),

                              SizedBox(height: 15,),


                              // permessions
                              isPrescriptionManagement?['isSelected']==false ? Container() :
                              Container(
                                child: Column(
                                  children: [
                                    // Add
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                            value: isAddPrescriptionManagement,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                isAddPrescriptionManagement = value ?? false;
                                              });
                                            },
                                            activeColor: ColorApp.blue,
                                            checkColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          Text(
                                            "يمكنه (انشاء) خلطات",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 10),

                                    // Update
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                            value: isUpdatePrescriptionManagement,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                isUpdatePrescriptionManagement = value ?? false;
                                              });
                                            },
                                            activeColor: ColorApp.blue,
                                            checkColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          Text(
                                            "يمكنه (التعديل) علي الخلطات",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 10),

                                    // Delete
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                            value: isDeletePrescriptionManagement,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                isDeletePrescriptionManagement = value ?? false;
                                              });
                                            },
                                            activeColor: ColorApp.blue,
                                            checkColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          Text(
                                            "يمكنه (حذف) الخلطات",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),

                        SizedBox(height: 10,),
                        Divider(color: ColorApp.gray,),


                        //قسم الجرد
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("القسم",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal)),
                              Text("الجرد",
                                  style: TextStyle(
                                      color: ColorApp.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal)),

                              SizedBox(height: 15),

                              Row(
                                children: [
                                  Text("حالته: ",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal)),
                                  // هل قسم (ادارة المخزن ظاهر)
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton2<Map<String, dynamic>>(
                                      isExpanded: true,
                                      hint: Text(
                                        'اختر',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                      items: itemsInventory.map((Map<String, dynamic> item) {
                                        return DropdownMenuItem<Map<String, dynamic>>(
                                          value: item, // Set map as the value
                                          child: Text(
                                            item['name'], // Show 'name' value in the dropdown
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      value: isInventory, // Bind map to selectedValue
                                      onChanged: (Map<String, dynamic>? value) {
                                        setState(() {
                                          isInventory = value;

                                        });
                                      },
                                      buttonStyleData: const ButtonStyleData(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        height: 40,
                                        width: 200,
                                      ),
                                      menuItemStyleData: const MenuItemStyleData(
                                        height: 40,
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                              SizedBox(height: 15,),
                            ],
                          ),
                        ),

                        SizedBox(height: 10,),
                        Divider(color: ColorApp.gray,),

                        //قسم تتبع العملبات
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("القسم",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal)),
                              Text("تتبع العملبات",
                                  style: TextStyle(
                                      color: ColorApp.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal)),

                              SizedBox(height: 15),

                              Row(
                                children: [
                                  Text("حالته: ",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal)),
                                  // هل قسم (ادارة المخزن ظاهر)
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton2<Map<String, dynamic>>(
                                      isExpanded: true,
                                      hint: Text(
                                        'اختر',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                      items: itemsHistory.map((Map<String, dynamic> item) {
                                        return DropdownMenuItem<Map<String, dynamic>>(
                                          value: item, // Set map as the value
                                          child: Text(
                                            item['name'], // Show 'name' value in the dropdown
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      value: isHistory, // Bind map to selectedValue
                                      onChanged: (Map<String, dynamic>? value) {
                                        setState(() {
                                          isHistory = value;

                                        });
                                      },
                                      buttonStyleData: const ButtonStyleData(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        height: 40,
                                        width: 200,
                                      ),
                                      menuItemStyleData: const MenuItemStyleData(
                                        height: 40,
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                              SizedBox(height: 15,),
                            ],
                          ),
                        ),

                        SizedBox(height: 10,),
                        Divider(color: ColorApp.gray,),


                        SizedBox(height: 50,),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          isDialog==false?Container():
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.5), // خلفية شفافة داكنة مثل الـ Dialog
            child: Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                width: 300, // يمكنك تعديل الحجم حسب الحاجة
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("هل حقا تريد الخروج من هذه الصفحة", style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),

                    Row(
                      children: [
                        
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: (){
                              // عند الضغط على الزر، سيتم العودة إلى الصفحة السابقة
                              Navigator.pop(context);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(10),
                              child: Text("نعم" , style: TextStyle(color: ColorApp.white),),
                              color: ColorApp.red,
                            ),
                          )
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: (){
                                setState(() {
                                  isDialog = false;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10),
                                child: Text("لا" , style: TextStyle(color: ColorApp.white),),
                                color: Colors.grey,
                              ),
                            )
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }
}
