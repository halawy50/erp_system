import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_pvc/components/tablMixProduction.dart';
import 'package:system_pvc/constant/color.dart';
import 'package:intl/intl.dart';
import 'package:system_pvc/cubit/mix_production_cubit/mix_production_cubit.dart';
import 'package:system_pvc/data/model/mix_productions_model.dart';
import 'package:system_pvc/repo/mix_production_repo.dart';
import 'package:system_pvc/screens/home_screen/pages/mix_production_page/sup_page/add_mix_production_page.dart';
import 'package:system_pvc/screens/home_screen/pages/mix_production_page/sup_page/dialog_delete_mix_production.dart';
import 'package:system_pvc/screens/home_screen/pages/mix_production_page/sup_page/edit_mix_production_page.dart';

class MixProductionPage extends StatefulWidget {
  MixProductionRepo mixProductionRepo;
  MixProductionPage({super.key , required this.mixProductionRepo});

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

  @override
  void initState() {
    super.initState();
    mixProductionCubit = MixProductionCubit(widget.mixProductionRepo);
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //header
                  _buildHeader(),

                  SizedBox(height: 20),



                  SizedBox(height: 20),

                  _tableMixProductions(),


                  // _buildMaterialsTable(),
                ],
              ),
            ),
          ),
        ],
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

                        Divider(),

                      ],
                    ),
                  ),

                  SizedBox(height: 30),

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
                        mixProductionCubit.getAllCountMixProductionsUserFilter(
                            startDate,
                            endDate,
                            fkPrescription,
                            fkEmployee,
                            page: state.page);
                      });

                    },
                    onDelete: (index) {
                      setState(() {
                        isDialogDelete = true;
                        mixProductionModel = state.mixProductionList[index];

                        showDialogDeleteMixProduction(
                          context: context,
                          startDate: startDate,
                          endDate: endDate,
                          fkPrescription: fkPrescription,
                          fkEmployee: fkEmployee,
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

            return const SizedBox();
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