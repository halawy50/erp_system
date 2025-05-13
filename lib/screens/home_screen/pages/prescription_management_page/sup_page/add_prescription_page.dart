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

class AddPrescriptionPage extends StatefulWidget {
  final MaterialRepo materialRepo;
  PrescriptionRepository prescriptionRepo;

  AddPrescriptionPage({
    super.key,
    required this.materialRepo,
    required this.prescriptionRepo
  });

  @override
  State<AddPrescriptionPage> createState() => _AddPrescriptionPageState();
}

class _AddPrescriptionPageState extends State<AddPrescriptionPage> {
  bool isDialog = false;
  List<Map<String, dynamic>> materialDetails = [];
  bool isButtonEnabled = false;
  final TextEditingController prescriptionNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    final allMaterials = await widget.materialRepo.getAllMaterials();
    setState(() {
      materialDetails = allMaterials.map((material) => {
        'material': material,
        'controller': TextEditingController(),
        'isUsed': 'مستخدم', // Default to 'مستخدم'
        'isEnabled': true
      }).toList();
    });
    // Initial check for button state
    _checkButtonState();
  }

  // Check if button should be enabled
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
      isButtonEnabled = hasValidMaterial;
    });
  }

  // Save the prescription with materials
  Future<void> _savePrescription() async {
    if (!isButtonEnabled) return;

    try {
      // Create prescription model
      final prescriptionModel = PrescriptionManagementModel(
        name: prescriptionNameController.text.isEmpty ? "خلطة جديدة" : prescriptionNameController.text,
        createdAt: DateTime.now(), // Ensure this matches the model's expected type
      );

      // Prepare materials list with quantities
      final List<MaterialPrescriptionManagementModel> materialsList = [];
      for (var detail in materialDetails) {
        if (detail['isUsed'] == 'مستخدم') {
          final controller = detail['controller'] as TextEditingController;
          final quantityText = controller.text.trim();
          if (quantityText.isNotEmpty && double.tryParse(quantityText) != null && double.parse(quantityText) > 0) {
            final material = detail['material'] as MaterialModel;
            // Use appropriate method to get material ID
            // This might be different based on your MaterialModel implementation
            // Common variations include:
            // material.id, material.materialId, material.getId(), etc.
            materialsList.add(MaterialPrescriptionManagementModel(
             fkMaterial: material.materialId,
             quntatyUse: double.parse(quantityText),
             createdAt: DateTime.now(), // This will be set by the repository
            ));
          }
        }
      }

      // Save to database
      final result = await widget.prescriptionRepo.insertPrescriptionWithMaterials(
        prescriptionModel,
        materialsList,
      );

      if (result != 0) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تم إضافة الخلطة بنجاح")),
        );
        Navigator.pop(context);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حدث خطأ أثناء حفظ الخلطة")),
        );
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ: $e")),
      );
    }
  }

  @override
  void dispose() {
    // Dispose of all controllers to prevent memory leaks
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "اضف خلطة جديد",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                                ),
                                InkWell(
                                  onTap: (
                                      prescriptionNameController.text.isNotEmpty &&
                                      isButtonEnabled
                                  ) ? _savePrescription : null,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: isButtonEnabled ? ColorApp.blue : Colors.grey,
                                    ),
                                    height: 55,
                                    child: Text(
                                      "اضف خلطة",
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
                            // Field for prescription name
                            TextField(
                              controller: prescriptionNameController,
                              decoration: InputDecoration(
                                labelText: "اسم الخلطة",
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: ColorApp.blue),
                                ),
                              ),
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
    // Define selection options
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
                            // Disable TextField if 'غير مستخدم' is selected
                            materialDetail['isEnabled'] = value == 'مستخدم';

                            // Clear the text field if disabled
                            if (value == 'غير مستخدم') {
                              quantityController.clear();
                            }

                            // Check button state after changing material status
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
                        // Check button state after changing quantity
                        _checkButtonState();
                      },
                    ),
                  ),
                ],
              ),
              Divider(color: ColorApp.gray,)
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
    );
  }
}


