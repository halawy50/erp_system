import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:system_pvc/components/button_back.dart';
import 'package:system_pvc/components/show_snak_bar.dart';
import 'package:system_pvc/constant/color.dart';
import 'package:system_pvc/data/model/material_model.dart';
import 'package:system_pvc/repo/material_repo.dart';

class EditMaterialPage extends StatefulWidget {
  final MaterialRepo materialRepo;
  final MaterialModel material;

  const EditMaterialPage({super.key, required this.materialRepo, required this.material});

  @override
  State<EditMaterialPage> createState() => _EditMaterialPageState();
}

class _EditMaterialPageState extends State<EditMaterialPage> {
  bool isDialog = false;
  late TextEditingController _nameMaterialController;
  late TextEditingController _quantityAvailableMaterial;
  late TextEditingController _minimumMaterial;

  @override
  void initState() {
    super.initState();
    _nameMaterialController = TextEditingController(text: widget.material.materialName);
    _quantityAvailableMaterial = TextEditingController(text: widget.material.quantityAvailable.toString());
    _minimumMaterial = TextEditingController(text: widget.material.minimum.toString());

    _nameMaterialController.addListener(() => setState(() {}));
    _quantityAvailableMaterial.addListener(() => setState(() {}));
    _minimumMaterial.addListener(() => setState(() {}));
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
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                    const SizedBox(height: 40),
                    Center(
                      child: SizedBox(
                        width: 300,
                        height: MediaQuery.of(context).size.height * 0.7,

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "تعديل الخامة",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            _buildTextField("اسم الخامة", _nameMaterialController),
                            const SizedBox(height: 20),
                            _buildNumberField("الكمية (بالكيلوجرام)", _quantityAvailableMaterial),
                            const SizedBox(height: 20),
                            _buildNumberField("الحد الأدنى (بالكيلوجرام)", _minimumMaterial),
                            const SizedBox(height: 20),
                            _buildSaveButton(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isDialog) _buildExitDialog(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorApp.blue)),
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorApp.blue)),
      ),
    );
  }

  Widget _buildSaveButton() {
    final isFilled = _nameMaterialController.text.isNotEmpty &&
        _quantityAvailableMaterial.text.isNotEmpty &&
        _minimumMaterial.text.isNotEmpty;

    return InkWell(
      onTap: () async {
        if (isFilled) {
          double quantityAvailable = double.tryParse(_quantityAvailableMaterial.text) ?? 0;
          double minimum = double.tryParse(_minimumMaterial.text) ?? 0;

          bool isAlert = minimum >= quantityAvailable;

          MaterialModel updated = MaterialModel(
            materialId: widget.material.materialId,
            materialName: _nameMaterialController.text,
            quantityAvailable: quantityAvailable,
            minimum: minimum,
            isAlerts: isAlert,
            alertsMessage: isAlert ? "الكمية منخفضة عن الحد الادني او تقترب منها" : "",
          );

          bool result = await widget.materialRepo.updateMaterial(updated);

          if (result) {
            showSnackbar(context, "تم تحديث الخامة بنجاح", backgroundColor: Colors.green);
            Navigator.pop(context, true);
          } else {
            showSnackbar(context, "حدث خطأ أثناء التحديث", backgroundColor: Colors.red);
          }
        } else {
          showSnackbar(context, "يرجى تعبئة جميع الحقول", backgroundColor: Colors.red);
        }
      },
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isFilled ? ColorApp.blue : ColorApp.grey,
        ),
        alignment: Alignment.center,
        child: const Text(
          "تعديل الخامة",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("هل تريد الخروج دون حفظ التعديلات؟", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        color: ColorApp.red,
                        child: const Text("نعم", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => isDialog = false),
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        color: Colors.grey,
                        child: const Text("لا", style: TextStyle(color: Colors.white)),
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
