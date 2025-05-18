import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_pvc/components/show_snak_bar.dart';
import 'package:system_pvc/components/tablePrescription.dart';
import 'package:system_pvc/constant/color.dart';
import 'package:system_pvc/cubit/prescription_cubit/prescription_cubit.dart';
import 'package:system_pvc/cubit/prescription_cubit/prescription_state.dart';
import 'package:system_pvc/data/model/material_model.dart';
import 'package:system_pvc/data/model/material_prescription_management_model.dart';
import 'package:system_pvc/data/model/prescription_management_model.dart';
import 'package:system_pvc/repo/material_repo.dart';
import 'package:system_pvc/repo/prescription_management_repo.dart';
import 'package:system_pvc/screens/home_screen/pages/prescription_management_page/sup_page/add_prescription_page.dart' show AddPrescriptionPage;
import 'package:system_pvc/screens/home_screen/pages/prescription_management_page/sup_page/edit_prescription_page.dart';

class PrescriptionManagementPage extends StatefulWidget {
  final MaterialRepo materialRepo;
  PrescriptionRepository prescriptionRepo;
  PrescriptionManagementPage({super.key, required this.prescriptionRepo, required this.materialRepo});

  @override
  State<PrescriptionManagementPage> createState() => _PrescriptionManagementPageState();
}

class _PrescriptionManagementPageState extends State<PrescriptionManagementPage> {
  late Map<String, String> headers;
  List<Map<String, dynamic>> prescriptions = [];
  List<Map<String, dynamic>> materialUses = [];

  late PrescriptionCubit _prescriptionCubit;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _prescriptionCubit = PrescriptionCubit(widget.prescriptionRepo);

    headers = {
      "idPrescription": "رقم الخلطة",
      "namePrescription": "اسم الخلطة",
    };

    _prescriptionCubit.loadAllPrescriptionsWithMaterials();
    loadDataAndSetup();
  }

  Future<void> loadDataAndSetup() async {
    setState(() {
      isLoading = true;
    });

    // تفريغ البيانات القديمة
    prescriptions.clear();
    materialUses.clear();

    try {
      // 1. تحميل المواد وإضافتها للرأس
      List<MaterialModel> allMaterial = await widget.materialRepo.getMaterials();
      Map<String, String> dynamicHeaders = {};

      for (var mat in allMaterial) {
        if (mat.materialId != null && mat.materialName != null) {
          dynamicHeaders["${mat.materialId}"] = "${mat.materialName}";
          print("${mat.materialId} = ${mat.materialName}");
        }
      }

      // 2. تحميل الخلطات
      List<PrescriptionManagementModel> allPrescriptionsWithMaterials =
      await widget.prescriptionRepo.getAllPrescriptionsWithMaterials();

      for (var prescription in allPrescriptionsWithMaterials) {
        if (prescription.id != null) {
          prescriptions.add({
            "idPrescription": "${prescription.id}",
            "namePrescription": "${prescription.name ?? 'بدون اسم'}",
          });

          // إضافة بيانات المواد المستخدمة في هذه الخلطة
          if (prescription.materials != null) {
            for (var material in prescription.materials!) {
              if (material.fkPrescriptionManagement != null &&
                  material.fkMaterial != null &&
                  material.quntatyUse != null) {

                print("FKMaterial /FUCK : ${material.fkMaterial}");

                materialUses.add({
                  "fkPrescription": "${material.fkPrescriptionManagement}",
                  "fkMaterial": "${material.fkMaterial}",
                  "quntatyUse": "${material.quntatyUse}",
                });

                // طباعة للتحقق من البيانات
                print("DEBUG: خلطة ${prescription.name} - مادة ID: ${material.fkMaterial} - كمية: ${material.quntatyUse}");
              }
            }
          }
        }
      }

      setState(() {
        headers.addAll(dynamicHeaders);
        isLoading = false;
      });

      // طباعة البيانات للتحقق
      print("DEBUG: تم تحميل ${prescriptions.length} خلطة");
      print("DEBUG: تم تحميل ${materialUses.length} استخدام مادة");
      print("DEBUG: الرؤوس: ${headers}");

    } catch (e) {
      print("ERROR: خطأ في تحميل البيانات: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Container(
              alignment: AlignmentDirectional.topStart,
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ادارة الخلطة",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
                            ),
                            Text(
                              "التحكم بشكل كامل في الخلطات المتوفرة",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 20),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddPrescriptionPage(
                                  materialRepo: widget.materialRepo,
                                  prescriptionRepo: widget.prescriptionRepo,
                                ),
                              ),
                            ).then((_) async {
                              // await _prescriptionCubit.loadAllPrescriptionsWithMaterials();
                              await loadDataAndSetup();
                            });

                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(color: ColorApp.blue),
                            height: 55,
                            child: Text(
                              "اضافة خلطة جديدة",
                              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20, color: ColorApp.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                    Text(
                      "جميع الخلطات المتوفرة",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    SizedBox(height: 20),
                    if (isLoading)
                      Center(child: CircularProgressIndicator())
                    else if (prescriptions.isEmpty)
                      Center(child: Text("لا توجد بيانات لعرضها"))
                    else
                      BlocProvider(
                      create: (context) => _prescriptionCubit,
                      child: BlocBuilder<PrescriptionCubit, PrescriptionState>
                        (builder: (context, state) {
                        if (state is PrescriptionLoadingState) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if(state is PrescriptionLoadedState){

                          return tablePrescriptionManagement
                            (
                            headers: headers,
                            prescriptions: prescriptions,
                            materialUses: materialUses,
                            onEdit: (index) {
                              print("تعديل السطر رقم $index");
                              PrescriptionManagementModel prescrption = state.prescriptions[index];

                              // أضف وظائف التعديل هنا
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditPrescriptionPage(
                                      materialRepo: widget.materialRepo,
                                      prescriptionRepo: widget.prescriptionRepo,
                                      prescription: prescrption
                                  ),
                                ),
                              ).then((_) async {
                                 _prescriptionCubit.loadAllPrescriptionsWithMaterials();
                                await loadDataAndSetup();
                              });
                            },
                            onDelete: (index) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("تأكيد الحذف"),
                                  content: Text("هل أنت متأكد من حذف هذه الخلطة؟"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("إلغاء"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (index < prescriptions.length) {
                                          String prescriptionId = prescriptions[index]["idPrescription"];
                                          _prescriptionCubit.deletePrescriptionWithMaterials(int.parse(prescriptionId));
                                          Navigator.pop(context);
                                          showSnackbar(context, "تم حذف الخلطة بنجاح", backgroundColor: Colors.green);
                                          // إعادة تحميل البيانات بعد الحذف
                                          Future.delayed(Duration(milliseconds: 500), () {
                                            loadDataAndSetup();
                                          });
                                        }
                                      },
                                      child: Text("حذف", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }

                      else if (state is PrescriptionErrorState) {
                          return Center(child: Text(state.errorMessage));
                        }
                        return Center(child: Text("برجاء تحميل البيانات"));
                      },

                    ),
                    ),
                    
                    SizedBox(height: 20)
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}