// warehouse_management_page_updated.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_pvc/components/show_snak_bar.dart';
import 'package:system_pvc/components/tableWarehouseMangment.dart';
import 'package:system_pvc/constant/color.dart';
import 'package:system_pvc/constant/stream.dart';
import 'package:system_pvc/cubit/material_cubit/material_cubit.dart';
import 'package:system_pvc/cubit/material_cubit/material_state.dart';
import 'package:system_pvc/cubit/material_cubit/material_state.dart' as custom;
import 'package:system_pvc/data/model/material_model.dart';
import 'package:system_pvc/data/model/material_with_prescriptions.dart';
import 'package:system_pvc/data/model/prescription_management_model.dart';
import 'package:system_pvc/repo/material_repo.dart';
import 'package:system_pvc/repo/prescription_management_repo.dart';
import 'package:system_pvc/screens/home_screen/pages/warehouse_management_page/sup_page/add_material_page.dart';
import 'package:system_pvc/screens/home_screen/pages/warehouse_management_page/sup_page/edit_material_page.dart';

class WarehouseManagementPage extends StatefulWidget {
  final MaterialRepo materialRepo;
  final PrescriptionRepository prescriptionRepo;

  WarehouseManagementPage({
    super.key,
    required this.materialRepo,
    required this.prescriptionRepo
  });

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

  late MaterialCubit _materialCubit;
  List<PrescriptionManagementModel> _prescriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _materialCubit = MaterialCubit(widget.materialRepo);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // جلب البيانات بالتوازي
    await Future.wait([
      _loadPrescriptions(),
      _materialCubit.fetchMaterials(),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadPrescriptions() async {
    if(StreamData.userModel.isShowPrescriptions)
    try {
      _prescriptions = await widget.prescriptionRepo.getAllPrescriptionsWithMaterials();
    } catch (e) {
      print("خطأ في جلب الخلطات: $e");
      _prescriptions = [];
    }
  }

  @override
  void dispose() {
    _materialCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: AlignmentDirectional.topStart,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 50),
                Text(
                  "المواد المتوفرة في المخزن مع الخلطات الممكنة",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
                ),
                SizedBox(height: 20),
                _buildMaterialsTable(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
              "التحكم بشكل افضل في المواد المخزنة والخلطات المرتبطة",
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
              _loadData();
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
    );
  }

  Widget _buildMaterialsTable() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return BlocProvider.value(
      value: _materialCubit,
      child: BlocBuilder<MaterialCubit, MaterialsState>(
        builder: (context, state) {
          if (state is custom.MaterialLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is custom.MaterialLoaded) {
            if (state.materials.isEmpty) {
              return Center(child: Text("لا توجد بيانات لعرضها"));
            }

            // معالجة البيانات لعرضها في الجدول
            List<MaterialWithPrescriptions> materialsWithPrescriptions = calculateMaterialsWithPrescriptions(
              materials: state.materials,
              prescriptions: _prescriptions,
            );

            return Column(
              children: [
                tableWareHouseManagementWithPrescriptions(
                  headers: headers,
                  page: state.currentPage,
                  prescriptions: _prescriptions,
                  materialsWithPrescriptions: materialsWithPrescriptions,
                  onEdit: (index) {
                    // يمكنك تنفيذ وظيفة التعديل هنا
                    print("تعديل السطر رقم $index");
                    MaterialModel material = state.materials[index];

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditMaterialPage(
                          materialRepo: widget.materialRepo,
                          material: material,
                        ),
                      ),
                    ).then((_) {
                      // Refresh user list when returning from add page
                      _materialCubit.fetchMaterials(page: state.currentPage);
                    });


                  },
                  onDelete: (index) {
                    _showDeleteConfirmationDialog(state.materials[index].materialId , state.currentPage);
                  },
                ),
                SizedBox(height: 20),
                _buildPagination(state.totalPages, state.currentPage),
              ],
            );
          } else if (state is custom.MaterialError) {
            return Center(child: Text(state.message));
          }

          return Center(child: Text("برجاء تحميل البيانات"));
        },
      ),
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
            _materialCubit.fetchMaterials(page: currentPage - 1);
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
                _materialCubit.fetchMaterials(page: pageNumbers[i]);
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
            _materialCubit.fetchMaterials(page: currentPage + 1);
          }
              : null,
          child: Text("التالي"),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(int materialId , int currentPage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("تأكيد الحذف"),
        content: Text("هل أنت متأكد من حذف هذه الخامة؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              _materialCubit.deleteMaterial(materialId);
              showSnackbar(context, "تم الحذف بنجاح" , backgroundColor: Colors.green);
              setState(() async {
                int mixProductionList = await _materialCubit.getAllMaterialCounter(page: currentPage);
                if(mixProductionList>0 && currentPage>=1){
                  _materialCubit.fetchMaterials(page: currentPage);
                  Navigator.pop(context);
                }else if(mixProductionList<=0 && currentPage>=1){
                  _materialCubit.fetchMaterials(page: currentPage-1);
                  Navigator.pop(context);

                }
              });
            },
            child: Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}