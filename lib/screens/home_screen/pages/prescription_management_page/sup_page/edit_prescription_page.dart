import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:system_pvc/components/button_back.dart';
import 'package:system_pvc/components/show_snak_bar.dart';
import 'package:system_pvc/constant/color.dart';
import 'package:system_pvc/data/model/material_model.dart';
import 'package:system_pvc/data/model/prescription_management_model.dart';
import 'package:system_pvc/data/model/material_prescription_management_model.dart';
import 'package:system_pvc/repo/material_repo.dart';
import 'package:system_pvc/repo/prescription_management_repo.dart';

class EditPrescriptionPage extends StatefulWidget {
  final MaterialRepo materialRepo;
  final PrescriptionRepository prescriptionRepo;
  final PrescriptionManagementModel prescription;

  const EditPrescriptionPage({
    Key? key,
    required this.materialRepo,
    required this.prescriptionRepo,
    required this.prescription,
  }) : super(key: key);

  @override
  State<EditPrescriptionPage> createState() => _EditPrescriptionPageState();
}

class _EditPrescriptionPageState extends State<EditPrescriptionPage> {
  bool isDialog = false;
  List<Map<String, dynamic>> materialDetails = [];
  bool isButtonEnabled = false;
  late TextEditingController prescriptionNameController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    prescriptionNameController = TextEditingController(text: widget.prescription.name);
    _loadMaterialsAndPrescriptionDetails();
  }

  Future<void> _loadMaterialsAndPrescriptionDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 1. الحصول على جميع المواد
      final allMaterials = await widget.materialRepo.getAllMaterials();

      // 2. الحصول على مواد الخلطة الحالية
      final prescriptionMaterials = await widget.prescriptionRepo.getPrescriptionWithMaterials(widget.prescription.id!);

      // تجهيز مصفوفة المواد مع ضبط الحالة والكمية لكل مادة
      List<Map<String, dynamic>> details = [];

      for (var material in allMaterials) {
        // البحث عن المادة في مواد الخلطة
        final prescriptionMaterial = prescriptionMaterials!.materials!.firstWhere(
              (pm) => pm.fkMaterial == material.materialId,
          orElse: () => MaterialPrescriptionManagementModel(
            fkMaterial: material.materialId,
            quntatyUse: 0,
            createdAt: DateTime.now(),
          ),
        );

        // إنشاء عنصر للمادة
        final TextEditingController controller = TextEditingController();
        final bool isUsedInPrescription = prescriptionMaterial.quntatyUse > 0;

        if (isUsedInPrescription) {
          controller.text = prescriptionMaterial.quntatyUse.toString();
        }

        details.add({
          'material': material,
          'controller': controller,
          'isUsed': isUsedInPrescription ? 'مستخدم' : 'غير مستخدم',
          'isEnabled': isUsedInPrescription,
          'prescriptionMaterial': prescriptionMaterial,
        });
      }

      setState(() {
        materialDetails = details;
        isLoading = false;
      });

      // التحقق من حالة الزر
      _checkButtonState();
    } catch (e) {
      print('خطأ في تحميل البيانات: $e');
      setState(() {
        isLoading = false;
      });

      // عرض رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحميل البيانات: $e')),
      );
    }
  }

  // التحقق من حالة زر الحفظ
  void _checkButtonState() {
    bool hasValidMaterial = false;

    for (var detail in materialDetails) {
      if (detail['isUsed'] == 'مستخدم') {
        final controller = detail['controller'] as TextEditingController;
        final quantityText = controller.text.trim();
        if (quantityText.isNotEmpty && double.tryParse(quantityText) != null && double.parse(quantityText) > 0) {
          hasValidMaterial = true;
          break;
        }
      }
    }

    setState(() {
      isButtonEnabled = hasValidMaterial && prescriptionNameController.text.isNotEmpty;
    });
  }

  // حفظ التعديلات على الخلطة
  Future<void> _updatePrescription() async {
    if (!isButtonEnabled) return;

    try {
      // تحديث نموذج الخلطة
      final updatedPrescription = PrescriptionManagementModel(
        id: widget.prescription.id,
        name: prescriptionNameController.text,
        createdAt: widget.prescription.createdAt, // الحفاظ على تاريخ الإنشاء الأصلي
      );

      // تجهيز قائمة المواد مع الكميات
      final List<MaterialPrescriptionManagementModel> materialsList = [];
      for (var detail in materialDetails) {
        if (detail['isUsed'] == 'مستخدم') {
          final controller = detail['controller'] as TextEditingController;
          final quantityText = controller.text.trim();
          if (quantityText.isNotEmpty && double.tryParse(quantityText) != null && double.parse(quantityText) > 0) {
            final material = detail['material'] as MaterialModel;
            // استخدام prescriptionMaterial إذا كان موجودًا للحفاظ على المعرف
            final prescriptionMaterial = detail['prescriptionMaterial'] as MaterialPrescriptionManagementModel;

            int? idPrecription =await widget.prescription.id;
            if(idPrecription !=null){
              materialsList.add(MaterialPrescriptionManagementModel(
                idMaterialPrescriptionManagement: prescriptionMaterial.idMaterialPrescriptionManagement, // يمكن أن يكون null إذا كانت مادة جديدة
                fkMaterial: material.materialId,
                fkPrescriptionManagement: idPrecription,
                quntatyUse: double.parse(quantityText),
              ));
            }

          }
        }
      }

      // حفظ التعديلات في قاعدة البيانات
      final result = await widget.prescriptionRepo.updatePrescriptionWithMaterials(
        updatedPrescription,
        materialsList,
      );

      if (result) {
        // عرض رسالة نجاح
        showSnackbar(context, "تم تحديث الخلطة بنجاح" , backgroundColor: Colors.green);
        Navigator.pop(context, true); // العودة مع إشارة للتحديث الناجح
      } else {
        // عرض رسالة خطأ
        showSnackbar(context, "حدث خطأ أثناء تحديث الخلطة" , backgroundColor: Colors.red);
      }
    } catch (e) {
      // معالجة الخطأ
      showSnackbar(context,"حدث خطأ: $e" , backgroundColor: Colors.red);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ: $e")),
      );
    }
  }

  @override
  void dispose() {
    // التخلص من جميع وحدات التحكم لمنع تسرب الذاكرة
    for (var detail in materialDetails) {
      (detail['controller'] as TextEditingController).dispose();
    }
    prescriptionNameController.dispose();
    super.dispose();
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
                    SizedBox(height: 40),
                    Center(
                      child: SizedBox(
                        width: 600,
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: isLoading
                            ? Center(child: CircularProgressIndicator())
                            : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "تعديل الخلطة",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                                ),
                                InkWell(
                                  onTap: isButtonEnabled ? _updatePrescription : null,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: isButtonEnabled ? ColorApp.blue : Colors.grey,
                                    ),
                                    height: 55,
                                    child: Text(
                                      "حفظ التعديلات",
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
                            SizedBox(height: 20),
                            // حقل لاسم الخلطة
                            TextField(
                              controller: prescriptionNameController,
                              decoration: InputDecoration(
                                labelText: "اسم الخلطة",
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: ColorApp.blue),
                                ),
                              ),
                              onChanged: (value) {
                                _checkButtonState();
                              },
                            ),
                            SizedBox(height: 20),
                            _buildMaterialList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isDialog)
            _buildExitDialog()
        ],
      ),
    );
  }

  Widget _buildMaterialList() {
    // تحديد خيارات الاستخدام
    final List<String> usageOptions = [
      'مستخدم',
      'غير مستخدم',
    ];

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: materialDetails.length,
        itemBuilder: (context, index) {
          final materialDetail = materialDetails[index];
          final material = materialDetail['material'];
          final quantityController = materialDetail['controller'] as TextEditingController;

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "${material.materialName}",
                      style: TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: Text(
                          'اختر',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        items: usageOptions.map((option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(
                              option,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          );
                        }).toList(),
                        value: materialDetail['isUsed'],
                        onChanged: (String? value) {
                          setState(() {
                            materialDetail['isUsed'] = value;
                            // تعطيل حقل النص إذا تم تحديد 'غير مستخدم'
                            materialDetail['isEnabled'] = value == 'مستخدم';

                            // مسح حقل النص إذا كان معطلاً
                            if (value == 'غير مستخدم') {
                              quantityController.clear();
                            }

                            // التحقق من حالة الزر بعد تغيير حالة المادة
                            _checkButtonState();
                          });
                        },
                        buttonStyleData: ButtonStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          height: 40,
                          width: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: quantityController,
                      enabled: materialDetail['isEnabled'],
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      decoration: InputDecoration(
                        labelText: "الكمية",
                        border: OutlineInputBorder(),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: ColorApp.blue),
                        ),
                      ),
                      onChanged: (value) {
                        // التحقق من حالة الزر بعد تغيير الكمية
                        _checkButtonState();
                      },
                    ),
                  ),
                ],
              ),
              Divider(color: ColorApp.grey,)
            ],
          );
        },
      ),
    );
  }

  Widget _buildExitDialog() {
    return Container(
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
                "هل حقا تريد الخروج من هذه الصفحة؟ سيتم فقدان التعديلات غير المحفوظة",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
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
    );
  }
}