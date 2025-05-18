import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_pvc/components/tablMixProduction.dart';
import 'package:system_pvc/constant/color.dart';
import 'package:intl/intl.dart';
import 'package:system_pvc/cubit/mix_production_cubit/mix_production_cubit.dart';
import 'package:system_pvc/data/model/mix_productions_model.dart';
import 'package:system_pvc/data/model/prescription_management_model.dart';
import 'package:system_pvc/data/model/user_model.dart';
import 'package:system_pvc/repo/mix_production_repo.dart';
import 'package:system_pvc/repo/prescription_management_repo.dart';
import 'package:system_pvc/repo/user_repo.dart';
import 'package:system_pvc/screens/home_screen/pages/mix_production_page/sup_page/add_mix_production_page.dart';
import 'package:system_pvc/screens/home_screen/pages/mix_production_page/sup_page/dialog_delete_mix_production.dart';
import 'package:system_pvc/screens/home_screen/pages/mix_production_page/sup_page/edit_mix_production_page.dart';

class MixProductionPage extends StatefulWidget {
  MixProductionRepo mixProductionRepo;
  PrescriptionRepository prescriptionRepository;
  UserRepo userRepo;
  MixProductionPage({super.key ,
    required this.mixProductionRepo ,
    required this.prescriptionRepository ,
    required this.userRepo,
  });

  @override
  State<MixProductionPage> createState() => _MixProductionPageState();
}

class _MixProductionPageState extends State<MixProductionPage> {
  // إضافة متغيرات للفلترة
  Map<String, String> headers = {
    "id": "رقم الانتاج",
    "name": "اسم الخلطة",
    "timeProduction": "تاريخ الانتاج",
    "quantityProduction": "عدد الخلطات المنتجة",
    "employee": "مسؤول الإنتاج",
  };

  late MixProductionCubit mixProductionCubit;

  String startDate = "";
  String endDate = "";
  List<int> fkPrescription = [];
  List<int> fkEmployee = [];
  bool isDialogDelete = false;
  int idMixProduction = 0;
  bool isFilter = false;

  List<Map<String , dynamic>> allPrescriptions = [];
  List<Map<String , dynamic>> allUsers = [];

  bool isPrescriptions = false;
  bool isUser = false;
  bool isDateTime = false;
  int counterSelectedPrescriptions = 0;
  int counterSelectedUsers = 0;
  int counterSelectedDateTime = 0;
  Map<String, dynamic>? selectedDateTime = {};
  DateTime? selectedDateFrom;
  DateTime? selectedDateTo;
  DateTime? selectedDateJustOne;
  bool isStartTimeEmpty = false;
  bool isEndTimeEmpty = false;
  bool isJustDayEmpty = false;
  bool filterDone = false;
  List<Map<String , dynamic>> allTimes =  [
    {
      "id": 1,
      "name" : "جميع الفترات",
    },
    {
      "id": 2,
      "name" : "يوم معين",
    },
    {
      "id": 3,
      "name" : "فترة زمنية معينة",
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedDateTime = allTimes[0];
    mixProductionCubit = MixProductionCubit(widget.mixProductionRepo);

    getAllPrescriptions();
    getAllUsers();
  }

  @override
  void dispose() {
    super.dispose();
  }




  Future<void> getAllPrescriptions() async{
    try{
      var prescriptions = await widget.prescriptionRepository.getAllPrescriptionsWithMaterials();
      for(PrescriptionManagementModel prescription in prescriptions) {
        allPrescriptions.add(
          {
            "isSelected" : false,
            "prescription" : prescription
          }
        );
      }
      print("asd : ${allPrescriptions.length}");
    }catch(e){
      print("asdError : ${allPrescriptions.length}");
    }
  }

  Future<void> getAllUsers() async{
    try{
      var allUsersList = await widget.userRepo.getAllUsers();
      for(UserModel user in allUsersList) {
        allUsers.add(
            {
              "isSelected" : false,
              "user" : user
            }
        );
      }
      print("asd : ${allPrescriptions.length}");
    }catch(e){
      print("asdError : ${allPrescriptions.length}");
    }
  }

  void _handleOutsideTap() {
    setState(() {
      isPrescriptions = false;
      isUser = false;

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _handleOutsideTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),

                  SizedBox(height: 20),

                  // الفلتر
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            isFilter = !isFilter;
                            if(!isFilter){
                              isPrescriptions = false  ;
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("فلتر"),
                              Icon(
                                isFilter
                                    ? Icons.keyboard_arrow_down_sharp
                                    : Icons.keyboard_arrow_up_sharp,
                                color: ColorApp.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      // محتوى الفلتر
                      if (isFilter)
                        Container(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  //Prescriptions
                                  IgnorePointer(
                                    ignoring: false, // يتيح تفاعل المستخدم مع الزر
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("الخلطات" , style: TextStyle(fontWeight: FontWeight.bold),),
                                        SizedBox(height: 5,),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 0),
                                          child: Wrap(
                                            crossAxisAlignment: WrapCrossAlignment.start,
                                            spacing: 10,
                                            runSpacing: 10,
                                            children: [
                                              Container(
                                                width: 250,
                                                decoration: BoxDecoration(
                                                    border: Border.all(color: ColorApp.black),
                                                    borderRadius: BorderRadius.circular(5)
                                                ),
                                                child: IntrinsicWidth(
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            isUser = false;
                                                            isPrescriptions = !isPrescriptions;
                                                          });
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 7 , horizontal: 10),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                  counterSelectedPrescriptions==0?
                                                                  "تحديد الكل":
                                                                  "${
                                                                      allPrescriptions
                                                                          .where((prescription) =>
                                                                      prescription['isSelected'] == true &&
                                                                          prescription['prescription'].name != '')
                                                                          .map((prescription) => prescription['prescription'].name)
                                                                          .toList()
                                                                  }"
                                                              ),

                                                              Icon(

                                                                isPrescriptions
                                                                    ? Icons.keyboard_arrow_down_sharp
                                                                    : Icons.keyboard_arrow_up_sharp,
                                                                color: ColorApp.black,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),

                                                      isPrescriptions?
                                                      Column(
                                                        children: allPrescriptions.map((prescription) {
                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              CheckboxListTile(
                                                                value: prescription['isSelected'],
                                                                onChanged: (value) {
                                                                  setState(() {
                                                                    prescription['isSelected'] = !prescription['isSelected'];
                                                                    if(prescription['isSelected']==true){
                                                                      counterSelectedPrescriptions++;
                                                                    }else{
                                                                      counterSelectedPrescriptions--;
                                                                    }
                                                                  });
                                                                },
                                                                title: Text("${prescription['prescription'].name}"),
                                                                contentPadding: EdgeInsets.zero,
                                                                controlAffinity: ListTileControlAffinity.leading,
                                                              ),

                                                            ],
                                                          );
                                                        }).toList(),

                                                      ):Container(),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // يمكنك إضافة المزيد من الخيارات هنا بنفس الطريقة
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(width: 20,),

                                  //Employees
                                  IgnorePointer(
                                    ignoring: false, // يتيح تفاعل المستخدم مع الزر
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("الموظفين" , style: TextStyle(fontWeight: FontWeight.bold),),
                                        SizedBox(height: 5,),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 0),
                                          child: Wrap(
                                            crossAxisAlignment: WrapCrossAlignment.start,
                                            spacing: 10,
                                            runSpacing: 10,
                                            children: [
                                              Container(
                                                width: 250,
                                                decoration: BoxDecoration(
                                                    border: Border.all(color: ColorApp.black),
                                                    borderRadius: BorderRadius.circular(5)
                                                ),
                                                child: IntrinsicWidth(
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            isPrescriptions = false;
                                                            isUser = !isUser;
                                                          });
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 7 , horizontal: 10),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  counterSelectedUsers == 0
                                                                      ? "تحديد الكل"
                                                                      : "${allUsers.where((user)
                                                                  => user['isSelected'] == true &&

                                                                      user['user'].name != '').map((user)
                                                                  => user['user'].name).toList()}",
                                                                  overflow: TextOverflow.ellipsis,  // مهم جداً هنا
                                                                  maxLines: 1,                       // خلي النص في سطر واحد
                                                                ),
                                                              ),
                                                              SizedBox(width: 10),
                                                              Icon(
                                                                isUser
                                                                    ? Icons.keyboard_arrow_down_sharp
                                                                    : Icons.keyboard_arrow_up_sharp,
                                                                color: ColorApp.black,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),

                                                      isUser?
                                                      Column(
                                                        children: allUsers.map((user) {
                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              CheckboxListTile(
                                                                value: user['isSelected'],
                                                                onChanged: (value) {
                                                                  setState(() {
                                                                    user['isSelected'] = !user['isSelected'];
                                                                    if(user['isSelected']==true){
                                                                      counterSelectedUsers++;
                                                                    }else{
                                                                      counterSelectedUsers--;
                                                                    }
                                                                  });
                                                                },
                                                                title: Text("${user['user'].name}"),
                                                                contentPadding: EdgeInsets.zero,
                                                                controlAffinity: ListTileControlAffinity.leading,
                                                              ),

                                                            ],
                                                          );
                                                        }).toList(),

                                                      ):Container(),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // يمكنك إضافة المزيد من الخيارات هنا بنفس الطريقة
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(width: 20,),

                                  //Date Time
                                  Container(
                                    width: 250,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        IgnorePointer(
                                          ignoring: false, // يتيح تفاعل المستخدم مع الزر
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("الفترة الزمنية" , style: TextStyle(fontWeight: FontWeight.bold),),
                                              SizedBox(height: 5,),
                                              IntrinsicWidth(
                                                stepWidth: 250,
                                                child: DropdownButtonHideUnderline(
                                                  child: DropdownButton2<Map<String, dynamic>>(
                                                    isExpanded: true,
                                                    hint: selectedDateTime == null
                                                        ? Text(
                                                      'جميع الفترات',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Theme.of(context).hintColor,
                                                      ),
                                                    ) : Text(
                                                      '${selectedDateTime!['name']}',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Theme.of(context).hintColor,
                                                      ),
                                                    ) ,
                                                    items: allTimes.map((option) {
                                                      return DropdownMenuItem<
                                                          Map<String, dynamic>>(
                                                        value: option,
                                                        child: Text(
                                                          option['name'],
                                                          style: const TextStyle(
                                                              fontSize: 16),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    value: selectedDateTime,
                                                    onChanged: (value) {
                                                      if (value == null) {
                                                        print("DateFFFFF : ${12}");
                                                        return;
                                                      }
                                                      setState(() {
                                                        isPrescriptions = false;
                                                        isUser =false;
                                                        selectedDateTime = value;
                                                        int prescriptionId = value['id'];
                                                        print("DateFFFFF : ${prescriptionId}");
                                                      });
                                                    },
                                                    buttonStyleData: ButtonStyleData(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 0),
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        border:
                                                        Border.all(color: Colors.grey),
                                                        borderRadius:
                                                        BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                    menuItemStyleData:
                                                    const MenuItemStyleData(height: 40),
                                                  ),
                                                ),

                                              ),
                                            ],
                                          ),
                                        ),

                                        selectedDateTime!['id']==2?
                                       //JustDay
                                        Container(
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.only(top: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("حدد",
                                                style: TextStyle(color: isJustDayEmpty?ColorApp.red:ColorApp.black),),
                                              SizedBox(width: 10,),

                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        _selectDateJustOne(context);
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(10),
                                                        decoration: BoxDecoration(
                                                          border: Border.all(color: isJustDayEmpty?ColorApp.red:ColorApp.black  ),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text("${
                                                                selectedDateJustOne!=null?
                                                                selectedDateJustOne!.toLocal().toString().split(' ')[0]:
                                                                "حدد اليوم"
                                                            }",
                                                              style: TextStyle(color: isJustDayEmpty?ColorApp.red:ColorApp.black),),
                                                            Icon(Icons.date_range_sharp , color: isJustDayEmpty?ColorApp.red:ColorApp.black),

                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    isJustDayEmpty?
                                                    Text("برجاء تحديد التاريخ" , style: TextStyle(
                                                        color: ColorApp.red
                                                    ),):Container()
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ):Container(),


                                        selectedDateTime!['id']==3?
                                        //TimeZone
                                        Container(
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.only(top: 10),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text("من" ,
                                                    style: TextStyle(color: isStartTimeEmpty?ColorApp.red:ColorApp.black),),
                                                  SizedBox(width: 10,),

                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            _selectDateFrom(context);
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets.all(10),
                                                            decoration: BoxDecoration(
                                                              border: Border.all(color: isStartTimeEmpty?ColorApp.red:ColorApp.black),
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Text("${
                                                                    selectedDateFrom!=null?
                                                                  selectedDateFrom!.toLocal().toString().split(' ')[0]:
                                                                      "يبدأ من"
                                                                }" , style: TextStyle(
                                                                    color: isStartTimeEmpty?ColorApp.red:ColorApp.black
                                                                ),),
                                                                Icon(Icons.date_range_sharp,
                                                                    color: isStartTimeEmpty?ColorApp.red:ColorApp.black
                                                                ),

                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        isStartTimeEmpty?
                                                        Text("برجاء تحديد التاريخ" , style: TextStyle(
                                                          color: ColorApp.red
                                                        ),):Container()
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),

                                              SizedBox(height: 10,),

                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text("الي",
                                                  style: TextStyle(color: isEndTimeEmpty?ColorApp.red:ColorApp.black),),

                                                  SizedBox(width: 10,),

                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            _selectDateTo(context);
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets.all(10),
                                                            decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: isEndTimeEmpty?ColorApp.red:ColorApp.black),
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Text("${
                                                                selectedDateTo!=null?
                                                                selectedDateTo!.toLocal().toString().split(' ')[0]:
                                                                "وينتهي في"
                                                                }",
                                                                  style: TextStyle(color: isEndTimeEmpty?ColorApp.red:ColorApp.black),),

                                                                Icon(Icons.date_range_sharp ,
                                                                    color: isEndTimeEmpty?ColorApp.red:ColorApp.black),

                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        isEndTimeEmpty?
                                                        Text("برجاء تحديد التاريخ" , style: TextStyle(
                                                            color: ColorApp.red
                                                        ),):Container()
                                                      ],
                                                    ),
                                                  )

                                                ],
                                              ),

                                            ],
                                          ),
                                        ):Container()
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: Row(
                                  children: [
                                    filterDone?
                                    IconButton(onPressed: () {
                                      setState(() {
                                        //تعالي هنا
                                        mixProductionCubit.getAllCountMixProductionsUserFilter("", "",
                                          [],
                                          [],
                                        );

                                        allPrescriptions.forEach((item) {
                                          item["isSelected"] = false;
                                        });

                                        allUsers.forEach((item) {
                                          item["isSelected"] = false;
                                        });

                                        selectedDateTime = allTimes[0];

                                        isPrescriptions = false;
                                         isUser = false;
                                         isDateTime = false;
                                         counterSelectedPrescriptions = 0;
                                         counterSelectedUsers = 0;
                                         counterSelectedDateTime = 0;
                                         selectedDateFrom = null;
                                         selectedDateTo = null ;
                                         selectedDateJustOne = null ;
                                         isStartTimeEmpty = false;
                                         isEndTimeEmpty = false;
                                         isJustDayEmpty = false;

                                         filterDone = false;
                                      });
                                    }, icon: Icon(Icons.cancel_outlined , color: ColorApp.red,)):Container(),
                                    SizedBox(width: 10,),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: ColorApp.blue,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: IconButton(onPressed: () {
                                        setState(() {
                                          if(selectedDateTime?['id'] == 1){

                                            isPrescriptions = false;
                                            isUser = false;
                                            isDateTime = false;

                                            List<int> prescriptionsIdList = [];
                                            List<int> usersIdList = [];

                                            for (Map<String, dynamic> prescriptionMap in allPrescriptions) {
                                              if (prescriptionMap['isSelected'] == true) {
                                                prescriptionsIdList.add(prescriptionMap['prescription'].id);
                                              }
                                            }

                                            for (Map<String, dynamic> user in allUsers) {
                                              if (user['isSelected'] == true) {
                                                usersIdList.add(user['user'].userId);
                                              }
                                            }

                                            mixProductionCubit.getAllCountMixProductionsUserFilter("", "",
                                              prescriptionsIdList,
                                              usersIdList,
                                            );
                                            filterDone = true;
                                          }
                                          else if (selectedDateTime?['id'] == 3) {
                                           if (selectedDateFrom == null) {
                                              print("MixFilter selectedDateFrom: التاريخ غير مُحدد");
                                                isStartTimeEmpty = true;
                                              return;
                                            }else{
                                              isStartTimeEmpty = false;
                                            }

                                            if (selectedDateTo == null) {
                                              print("MixFilter selectedDateFrom: التاريخ غير مُحدد");
                                              isEndTimeEmpty = true;
                                              return;
                                            }else{
                                              isEndTimeEmpty = false ;
                                            }

                                            print("مرحبا");

                                              isPrescriptions = false;
                                              isUser = false;
                                              isDateTime = false;

                                              List<int> prescriptionsIdList = [];
                                              List<int> usersIdList = [];

                                              for (Map<String, dynamic> prescriptionMap in allPrescriptions) {
                                                if (prescriptionMap['isSelected'] == true) {
                                                  prescriptionsIdList.add(prescriptionMap['prescription'].id);
                                                }
                                              }

                                              for (Map<String, dynamic> user in allUsers) {
                                                if (user['isSelected'] == true) {
                                                  usersIdList.add(user['user'].userId);
                                                }
                                              }

                                              String fromDate = selectedDateFrom!.toLocal().toString().split(' ')[0];
                                              String toDate = selectedDateTo!.toLocal().toString().split(' ')[0];

                                              print("MixFilter ( "
                                                  "selectedDateFrom : $fromDate\n"
                                                  "selectedDateTo : $toDate\n"
                                                  "prescriptionsIdList : $prescriptionsIdList\n"
                                                  "usersIdList : $usersIdList\n"
                                              );

                                              mixProductionCubit.getAllCountMixProductionsUserFilter(
                                                fromDate,
                                                toDate,
                                                prescriptionsIdList,
                                                usersIdList,
                                              );
                                           filterDone = true;

                                          }
                                          else if (selectedDateTime?['id'] == 2) {
                                            if (selectedDateJustOne == null) {
                                              print("MixFilter selectedDateFrom: التاريخ غير مُحدد");
                                              isJustDayEmpty = true;
                                              return;
                                            }else{
                                              isJustDayEmpty = false;
                                            }
                                            isPrescriptions = false;
                                            isUser = false;
                                            isDateTime = false;

                                            List<int> prescriptionsIdList = [];
                                            List<int> usersIdList = [];

                                            for (Map<String, dynamic> prescriptionMap in allPrescriptions) {
                                              if (prescriptionMap['isSelected'] == true) {
                                                prescriptionsIdList.add(prescriptionMap['prescription'].id);
                                              }
                                            }

                                            for (Map<String, dynamic> user in allUsers) {
                                              if (user['isSelected'] == true) {
                                                usersIdList.add(user['user'].userId);
                                              }
                                            }

                                            String fromDate = selectedDateJustOne!.toLocal().toString().split(' ')[0];
                                            String toDate = selectedDateJustOne!.toLocal().toString().split(' ')[0];

                                            print("MixFilter ( "
                                                "selectedDateFrom : $fromDate\n"
                                                "selectedDateTo : $toDate\n"
                                                "prescriptionsIdList : $prescriptionsIdList\n"
                                                "usersIdList : $usersIdList\n"
                                            );

                                            mixProductionCubit.getAllCountMixProductionsUserFilter(
                                              fromDate,
                                              toDate,
                                              prescriptionsIdList,
                                              usersIdList,
                                            );
                                            filterDone = true;

                                          }

                                        });

                                      }, icon: Icon(Icons.filter_alt , color: ColorApp.white,)),
                                    ),


                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // جدول الإنتاجات
                  _tableMixProductions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _selectDateJustOne(BuildContext context) async {
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateJustOne ?? now, // اليوم الحالي
      firstDate: DateTime(2000),
      lastDate: now.add(const Duration(days: 3)),
      locale: const Locale("ar", "EG"),
    );

    if (picked != null && picked != selectedDateJustOne) {
      setState(() {
        selectedDateJustOne = picked;
      });
    }
  }


  Future<void> _selectDateFrom(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initial = now.subtract(const Duration(days: 3));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateFrom ?? initial, // اليوم - 10 أيام
      firstDate: DateTime(2000),
      lastDate: now.add(const Duration(days: 3)),
      locale: const Locale("ar", "EG"),
    );

    if (picked != null && picked != selectedDateFrom) {
      setState(() {
        selectedDateFrom = picked;
      });
    }
  }

  Future<void> _selectDateTo(BuildContext context) async {
    if (selectedDateFrom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار تاريخ البداية أولاً')),
      );
      return;
    }

    final DateTime now = DateTime.now();
    final DateTime firstSelectableDate = selectedDateFrom!.add(const Duration(days: 1));

    // اجعل اليوم الحالي هو الاختيار الافتراضي إذا كان مسموحًا به
    final DateTime initialDate =
    now.isAfter(firstSelectableDate) ? now : firstSelectableDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstSelectableDate,
      lastDate: DateTime(2100),
      locale: const Locale("ar", "EG"),
    );

    if (picked != null && picked != selectedDateTo) {
      setState(() {
        selectedDateTo = picked;
      });
    }
  }



  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "انتاج الخلطات",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
            ),
            Text(
              "صفحة إدارة وإنشاء خلطات الإنتاج بسهولة وفعالية",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 20),
            ),
          ],
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddMixProductionPage(mixProductionRepo: widget.mixProductionRepo,),
              ),
            ).then((_) {
              mixProductionCubit.getAllCountMixProductionsUserFilter(
                startDate,
                endDate,
                fkPrescription,
                fkEmployee
              );
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(color: ColorApp.blue),
            height: 55,
            child: Text(
              "انتاج الخلطات",
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20, color: ColorApp.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tableMixProductions(){
    return BlocProvider(
        create: (context) => mixProductionCubit..getAllCountMixProductionsUserFilter(
          startDate,
          endDate,
          fkPrescription,
          fkEmployee),
        child: BlocBuilder<MixProductionCubit, MixProductionState>
          (builder: (context , state) {

            if(state is MixProductionLoading){
              return CircularProgressIndicator();
            }

            if(state is MixProductionLoaded){
              if (state.mixProductionList.isEmpty) {
                return Center(child: Text("لا توجد بيانات لعرضها"));
              }

              List<Map<String , String>> data = state.mixProductionList.map((mixProduction){
                return {
                  "id": "${mixProduction.mixProductionsId}",
                  "name": "${mixProduction.nameMixProductions}",
                  "timeProduction": "${mixProduction.dateTimeProduction}",
                  "quantityProduction": "${mixProduction.quantityMixProductions}",
                  "employee": "${mixProduction.employeeName}",
           };
          }).toList();
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Divider(),
                  SizedBox(height: 10),

                  filterDone?
                  Text(
                    "نتائج الفلتر",
                      style: TextStyle(
                        fontSize: 18, // جرب 16 أو 18 أو أكثر
                        color: ColorApp.blue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),)
                      :Container(),


                  SizedBox(height: 30),

                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,

                          children: [
                            Text(
                              "جميع الخلطات التي تم انتاجها",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                            ),

                            Text(
                              "${state.totalCount}",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
                            ),
                          ],
                        ),


                      ],
                    ),
                  ),

                  SizedBox(height: 15),

                  tableMixProduction(
                    headers: headers,
                    page: state.page,
                    rows: data,
                    onEdit: (index) {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditMixProductionPage(
                            mixProductionRepo: widget.mixProductionRepo,
                            mixProductionModel: state.mixProductionList[index],
                          ),
                        ),
                      ).then((_) {
                          setState(() {
                            print("FuckenTrue");

                            // إعادة إنشاء القوائم بعد الرجوع
                            List<int> prescriptionsIdList = [];
                            List<int> usersIdList = [];

                            for (Map<String, dynamic> prescriptionMap in allPrescriptions) {
                              if (prescriptionMap['isSelected'] == true) {
                                prescriptionsIdList.add(prescriptionMap['prescription'].id);
                              }
                            }

                            for (Map<String, dynamic> user in allUsers) {
                              if (user['isSelected'] == true) {
                                usersIdList.add(user['user'].userId);
                              }
                            }


                            if (filterDone&& selectedDateTime!['id']==3) {
                              String fromDate = selectedDateFrom!.toLocal().toString().split(' ')[0];
                              String toDate = selectedDateTo!.toLocal().toString().split(' ')[0];

                            if(fromDate!=null&& toDate!=null){
                              mixProductionCubit.getAllCountMixProductionsUserFilter(
                                fromDate,
                                toDate,
                                prescriptionsIdList,
                                usersIdList,
                                page: state.page,
                              );
                              print("FuckenTrue3");
                            }


                            } else if(filterDone&& selectedDateTime!['id']==2){
                              print("FuckenTrue2111111111 : ${selectedDateTime}");

                              String fromDate = selectedDateJustOne!.toLocal().toString().split(' ')[0];
                              String toDate = selectedDateJustOne!.toLocal().toString().split(' ')[0];
                              if(fromDate!=null&& toDate!=null){
                                mixProductionCubit.getAllCountMixProductionsUserFilter(
                                  fromDate,
                                  toDate,
                                  prescriptionsIdList,
                                  usersIdList,
                                  page: state.page,
                                );
                                print("FuckenTrue2");
                              }

                            }
                            else{
                              print("FuckenTrue22222222222 : ${fkPrescription}");

                              mixProductionCubit.getAllCountMixProductionsUserFilter(
                                startDate,
                                endDate,
                                prescriptionsIdList,
                                usersIdList,
                                page: state.page,
                              );
                              print("FuckenTrue2");

                            }
                          });

                      });

                    },
                    onDelete: (index) {
                      setState(() {
                        isDialogDelete = true;
                        MixProductionModel mixProductionModel = state.mixProductionList[index];

                        print("FuckenTrue");
                          // إعادة إنشاء القوائم بعد الرجوع
                          List<int> prescriptionsIdList = [];
                          List<int> usersIdList = [];

                          for (Map<String, dynamic> prescriptionMap in allPrescriptions) {
                            if (prescriptionMap['isSelected'] == true) {
                              prescriptionsIdList.add(prescriptionMap['prescription'].id);
                            }
                          }

                          for (Map<String, dynamic> user in allUsers) {
                            if (user['isSelected'] == true) {
                              usersIdList.add(user['user'].userId);
                            }
                          }


                          if (filterDone&& selectedDateTime!['id']==3) {
                            String fromDate = selectedDateFrom!.toLocal().toString().split(' ')[0];
                            String toDate = selectedDateTo!.toLocal().toString().split(' ')[0];

                            if(fromDate!=null&& toDate!=null){

                              showDialogDeleteMixProduction(
                                context: context,
                                startDate: fromDate,
                                endDate: toDate,
                                fkPrescription: prescriptionsIdList,
                                fkEmployee: usersIdList,
                                mixProduction: mixProductionModel,
                                mixProductionRepo: widget.mixProductionRepo,
                                mixProductionCubit: mixProductionCubit,
                                page: state.page,
                                onClose: (isShow) {
                                  setState(() {
                                    isDialogDelete = false;
                                  });
                                },
                              );
                              print("FuckenTrue3");
                            }


                          } else if(filterDone&& selectedDateTime!['id']==2){
                            print("FuckenTrue2111111111 : ${selectedDateTime}");

                            String fromDate = selectedDateJustOne!.toLocal().toString().split(' ')[0];
                            String toDate = selectedDateJustOne!.toLocal().toString().split(' ')[0];
                            if(fromDate!=null&& toDate!=null){

                              showDialogDeleteMixProduction(
                                context: context,
                                startDate: fromDate,
                                endDate: toDate,
                                fkPrescription: prescriptionsIdList,
                                fkEmployee: usersIdList,
                                mixProduction: mixProductionModel,
                                mixProductionRepo: widget.mixProductionRepo,
                                mixProductionCubit: mixProductionCubit,
                                page: state.page,
                                onClose: (isShow) {
                                  setState(() {
                                    isDialogDelete = false;
                                  });
                                },
                              );
                              print("FuckenTrue2");
                            }

                          }
                          else{
                            print("FuckenTrue22222222222 : ${fkPrescription}");

                            showDialogDeleteMixProduction(
                              context: context,
                              startDate: "",
                              endDate: "",
                              fkPrescription: prescriptionsIdList,
                              fkEmployee: usersIdList,
                              mixProduction: mixProductionModel,
                              mixProductionRepo: widget.mixProductionRepo,
                              mixProductionCubit: mixProductionCubit,
                              page: state.page,
                              onClose: (isShow) {
                                setState(() {
                                  isDialogDelete = false;
                                });
                              },
                            );
                            print("FuckenTrue2");

                          }




                      });

                    },
                  ),


                  SizedBox(height: 20),
                  Container(
                    alignment: AlignmentDirectional.center,
                      child: _buildPagination(state.totalPage, state.page)),

                ],
              );
            }

            return  Container(
              height: 300 ,
              alignment: Alignment.center,
              width: double.infinity ,
              child: Text("لا تتوفر بيانات"),
            );
        }),
    );
  }

  Widget _buildPagination(int totalPages, int currentPage) {
    int maxPagesToShow = 5;
    List<int> pageNumbers = [];

    if (totalPages <= maxPagesToShow) {
      pageNumbers = List.generate(totalPages, (index) => index + 1);
    } else {
      if (currentPage <= 3) {
        pageNumbers = [1, 2, 3, 4, -1, totalPages];
      } else if (currentPage >= totalPages - 2) {
        pageNumbers = [1, -1, totalPages - 3, totalPages - 2, totalPages - 1, totalPages];
      } else {
        pageNumbers = [1, -1, currentPage - 1, currentPage, currentPage + 1, currentPage + 2, -1, totalPages];
      }
    }

    return Wrap(
      spacing: 10,
      children: [
        ElevatedButton(
          onPressed: currentPage > 1
              ? () {
            mixProductionCubit.getAllCountMixProductionsUserFilter(
                startDate,
                endDate,
                fkPrescription,
                fkEmployee,
                page: currentPage - 1);
          }
              : null,
          child: Text("السابق"),
        ),

        for (int i = 0; i < pageNumbers.length; i++)
          pageNumbers[i] == -1
              ? Text("...")
              : ElevatedButton(
            onPressed: () {
              if (pageNumbers[i] != currentPage) {
                mixProductionCubit.getAllCountMixProductionsUserFilter(
                    startDate,
                    endDate,
                    fkPrescription,
                    fkEmployee,
                    page: pageNumbers[i]);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: pageNumbers[i] == currentPage ? ColorApp.blue : Colors.grey,
            ),
            child: Text('${pageNumbers[i]}', style: TextStyle(color: Colors.white)),
          ),

        ElevatedButton(
          onPressed: currentPage < totalPages
              ? () {
            mixProductionCubit.getAllCountMixProductionsUserFilter(
                startDate,
                endDate,
                fkPrescription,
                fkEmployee,
                page: currentPage + 1);
          }
              : null,
          child: Text("التالي"),
        ),
      ],
    );
  }

}