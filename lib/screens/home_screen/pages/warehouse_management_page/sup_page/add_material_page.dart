import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:system_pvc/components/button_back.dart';
import 'package:system_pvc/components/show_snak_bar.dart';
import 'package:system_pvc/constant/color.dart';
import 'package:system_pvc/data/model/material_model.dart';
import 'package:system_pvc/repo/material_repo.dart';

class AddMaterialPage extends StatefulWidget {
  MaterialRepo materialRepo;
  AddMaterialPage({super.key , required this.materialRepo});

  @override
  State<AddMaterialPage> createState() => _AddMaterialPageState();
}

class _AddMaterialPageState extends State<AddMaterialPage> {
  bool isDialog = false;
  TextEditingController _nameMaterialController = TextEditingController();
  TextEditingController _quantityAvailableMaterial = TextEditingController();
  TextEditingController _minimumMaterial = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameMaterialController.addListener(buildState);
    _quantityAvailableMaterial.addListener(buildState);
    _minimumMaterial.addListener(buildState);
  }

  void buildState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0, left: 30, right: 30),
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
                      }),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Center(
                      child: SizedBox(
                        width: 300,
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "اضف خامة جديدة",
                                style: TextStyle(
                                  color: ColorApp.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              SizedBox(height: 20,),
                              TextField(
                                  controller: _nameMaterialController,
                                  decoration: InputDecoration(
                                    labelText: "اسم الخامة",
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: ColorApp.blue),
                                    ),
                                  )),
                              SizedBox(height: 20,),
                              TextField(
                                controller: _quantityAvailableMaterial,
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                                ],
                                decoration: InputDecoration(
                                  labelText: "الكمية (بالكيلوجرام)",
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: ColorApp.blue),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20,),
                              TextField(
                                controller: _minimumMaterial,
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                                ],
                                decoration: InputDecoration(
                                  labelText: "الحد الادني (بالكيلوجرام)",
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: ColorApp.blue),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20,),
                              InkWell(
                                onTap: () async {
                                  if (_nameMaterialController.text.isNotEmpty &&
                                      _quantityAvailableMaterial.text.isNotEmpty &&
                                      _minimumMaterial.text.isNotEmpty) {
                                    double quantityAvailable = double.tryParse(_quantityAvailableMaterial.text) ?? 0.0;
                                    double minimum = double.tryParse(_minimumMaterial.text) ?? 0.0;

                                    bool isAlert = minimum >= quantityAvailable;
                                    MaterialModel materialModel = MaterialModel(
                                      materialName: _nameMaterialController.text,
                                      quantityAvailable: quantityAvailable,
                                      minimum: minimum,
                                      isAlerts: isAlert,
                                      alertsMessage: isAlert
                                          ? "الكمية منخفضة عن الحد الادني او تقترب منها"
                                          : "",
                                    );

                                    bool checkAddMaterial = await widget.materialRepo.addMaterial(materialModel);
                                    if (checkAddMaterial) {
                                      showSnackbar(context, "تم إضافة الخامة بنجاح", backgroundColor: Colors.green);
                                      Navigator.pop(context);
                                    } else {
                                      showSnackbar(context, "حدث خطأ ما", backgroundColor: Colors.red);
                                    }
                                  } else {
                                    showSnackbar(context, "يرجى تعبئة جميع الحقول", backgroundColor: Colors.red);
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: (_nameMaterialController.text.isNotEmpty &&
                                        _quantityAvailableMaterial.text.isNotEmpty &&
                                        _minimumMaterial.text.isNotEmpty)
                                        ? ColorApp.blue
                                        : ColorApp.grey,
                                  ),
                                  height: 55,
                                  child: Center(
                                    child: Text(
                                      "اضف خامة جديدة",
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 20,
                                        color: ColorApp.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isDialog)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  width: 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "هل حقا تريد الخروج من هذه الصفحة",
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10),
                                color: ColorApp.red,
                                child: Text("نعم", style: TextStyle(color: ColorApp.white)),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  isDialog = false;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10),
                                color: Colors.grey,
                                child: Text("لا", style: TextStyle(color: ColorApp.white)),
                              ),
                            ),
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
