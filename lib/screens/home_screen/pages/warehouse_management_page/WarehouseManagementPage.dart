import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_pvc/components/tableWarehouseMangment.dart';
import 'package:system_pvc/constant/color.dart';
import 'package:system_pvc/cubit/material_cubit/material_cubit.dart';
import 'package:system_pvc/cubit/material_cubit/material_state.dart';
import 'package:system_pvc/cubit/material_cubit/material_state.dart' as custom;
import 'package:system_pvc/data/model/prescription_management_model.dart';
import 'package:system_pvc/repo/material_repo.dart';
import 'package:system_pvc/repo/prescription_management_repo.dart';
import 'package:system_pvc/screens/home_screen/pages/warehouse_management_page/sup_page/add_material_page.dart';

class WarehouseManagementPage extends StatefulWidget {
  final MaterialRepo materialRepo;
  final PrescriptionRepository prescriptionRepo;
  WarehouseManagementPage({super.key, required this.materialRepo , required this.prescriptionRepo});

  @override
  State<WarehouseManagementPage> createState() => _WarehouseManagementPageState();
}

class _WarehouseManagementPageState extends State<WarehouseManagementPage> {
  Map<String, String> headers = {
    "id": "رقم الخامة",
    "materialName": "اسم الخامة",
    "quantityAvailable": "الكمية المتوفرة",
    "minimum": "الحد الأدنى",
    "alerts": "التنبيهات",
  };

  List<Map<String, String>> headersPrescription = [];
  late MaterialCubit _materialCubit;

  @override
  void initState() {
    super.initState();
    _materialCubit = MaterialCubit(widget.materialRepo);
    _materialCubit.fetchMaterials();
    getPrescription();
  }

  Future<void> getPrescription() async{
      List<PrescriptionManagementModel> prescriptionList = await widget.prescriptionRepo.getAllPrescriptionsWithMaterials();
      for(PrescriptionManagementModel presciption in prescriptionList){
        headersPrescription.add(
          {"${presciption.id}" : "${presciption.name}"}
        );

      }
  }

  @override
  void dispose() {
    super.dispose();
    _materialCubit.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20 , left: 20 , right: 20),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: AlignmentDirectional.topStart,
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
                          "ادارة المخزن",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                        Text(
                          "التحكم بشكل افضل في المواد المخزنة",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 20),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddMaterialPage(materialRepo: widget.materialRepo),
                          ),
                        ).then((_) {
                          _materialCubit.fetchMaterials(page: 1);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(color: ColorApp.blue),
                        height: 55,
                        child: Text(
                          "اضف خامة جديدة",
                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20, color: ColorApp.white),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                Text(
                  "المواد المتوفرة في المخزن",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
                ),
                SizedBox(height: 20),
                BlocProvider.value(
                  value: _materialCubit,
                  child:
                  BlocBuilder<MaterialCubit, MaterialsState>(
                    builder: (context, state) {
                      if (state is custom.MaterialLoading) {
                        return Center(child: CircularProgressIndicator());
                      } else if (state is custom.MaterialLoaded) {
                        if (state.materials.isEmpty) {
                          return Center(child: Text("لا توجد بيانات لعرضها"));
                        }

                        List<Map<String, String>> data = state.materials.map((material) {
                          return {
                            "id": material.materialId.toString(),
                            "materialName": material.materialName.toString(),
                            "quantityAvailable": "${material.quantityAvailable.toString()} (كجم)",
                            "minimum": "${material.minimum.toString()} (كجم)" ,
                            "alerts": material.alertsMessage,
                          };
                        }).toList();

                        int totalPages = state.totalPages;
                        int currentPage = state.currentPage;
                        int maxPagesToShow = 5;

                        // تحديد الصفحات التي سيتم عرضها بناءً على الصفحة الحالية
                        List<int> pageNumbers = [];

                        // تعديل منطق عرض أرقام الصفحات لتظهر دائماً الصفحات التالية
                        if (totalPages <= maxPagesToShow) {
                          // عرض كل الصفحات إذا كان عددها أقل من أو يساوي الحد الأقصى
                          pageNumbers = List.generate(totalPages, (index) => index + 1);
                        } else {
                          // تعديل حساب الصفحات بحيث تظهر دائماً الصفحات التالية للصفحة الحالية
                          int startPage = 1;
                          int endPage = totalPages;

                          if (currentPage <= 3) {
                            // إذا كنا في بداية الصفحات، نعرض الصفحات 1-4 ثم نقاط ثم الصفحة الأخيرة
                            pageNumbers = [1, 2, 3, 4, -1, totalPages];
                          } else if (currentPage >= totalPages - 2) {
                            // إذا كنا في نهاية الصفحات، نعرض الصفحة الأولى ثم نقاط ثم آخر 4 صفحات
                            pageNumbers = [1, -1, totalPages - 3, totalPages - 2, totalPages - 1, totalPages];
                          } else {
                            // في أي مكان آخر، نعرض الصفحة الأولى، نقاط، الصفحة الحالية - 1، الصفحة الحالية،
                            // الصفحة الحالية + 1، الصفحة الحالية + 2، نقاط، الصفحة الأخيرة
                            pageNumbers = [1, -1, currentPage - 1, currentPage, currentPage + 1, currentPage + 2, -1, totalPages];
                          }
                        }

                        return Column(
                          children: [
                            tableWareHouseManagement(
                              headers: headers,
                              rowsMaterial: data,
                              headersPrescription: headersPrescription,

                              onEdit: (index) {
                                print("تعديل السطر رقم $index");
                              },
                              onDelete: (index) {
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
                                        onPressed: () {
                                          _materialCubit.deleteMaterial(int.parse(data[index]["id"]!));
                                          Navigator.pop(context);
                                        },
                                        child: Text("حذف", style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 20),
                            // أزرار الصفحة مع زر "السابق" و "التالي"
                            Wrap(
                              spacing: 10,
                              children: [
                                // زر "السابق"
                                ElevatedButton(
                                  onPressed: currentPage > 1
                                      ? () {
                                    _materialCubit.fetchMaterials(page: currentPage - 1);
                                  }
                                      : null,
                                  child: Text("السابق"),
                                ),
                                // عرض الصفحات مع بعض النقاط إذا لزم الأمر
                                for (int i = 0; i < pageNumbers.length; i++)
                                  if (pageNumbers[i] == -1)
                                    Text("...")  // النقاط بين الصفحات
                                  else
                                    ElevatedButton(
                                      onPressed: () {
                                        if (pageNumbers[i] != currentPage) {
                                          _materialCubit.fetchMaterials(page: pageNumbers[i]);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: pageNumbers[i] == currentPage
                                            ? ColorApp.blue
                                            : Colors.grey,
                                      ),
                                      child: Text('${pageNumbers[i]}', style: TextStyle(color: Colors.white)),
                                    ),
                                // زر "التالي"
                                ElevatedButton(
                                  onPressed: currentPage < totalPages
                                      ? () {
                                    _materialCubit.fetchMaterials(page: currentPage + 1);
                                  }
                                      : null,
                                  child: Text("التالي"),
                                ),
                              ],
                            ),
                          ],
                        );
                      } else if (state is custom.MaterialError) {
                        return Center(child: Text(state.message));
                      }

                      return Center(child: Text("برجاء تحميل البيانات"));
                    },
                  )
                ),
                SizedBox(height: 20,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
