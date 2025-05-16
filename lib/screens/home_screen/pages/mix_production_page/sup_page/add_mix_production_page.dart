import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:system_pvc/components/button_back.dart';
import 'package:system_pvc/components/show_snak_bar.dart';
import 'package:system_pvc/constant/color.dart';
import 'package:system_pvc/constant/stream.dart';
import 'package:system_pvc/data/model/mix_productions_model.dart';
import 'package:system_pvc/data/model/prescription_management_model.dart';
import 'package:system_pvc/repo/mix_production_repo.dart';

class AddMixProductionPage extends StatefulWidget {
  final MixProductionRepo mixProductionRepo;

  const AddMixProductionPage({super.key, required this.mixProductionRepo});

  @override
  State<AddMixProductionPage> createState() => _AddMixProductionPageState();
}

class _AddMixProductionPageState extends State<AddMixProductionPage> {
  final List<Map<String, dynamic>> itemsWarehouseManagement = [];
  Map<String, dynamic>? selectedPrescription;
  int maxPrescriptions = 0;
  int _counter = 0;
  bool isLoading = true;
  bool isDialog = false;
  late TextEditingController _counterController;
  bool isProduction = false;

  TextEditingController _dateController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _counterController = TextEditingController();
    loadPrescriptions();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _dateController.text = today;
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> loadPrescriptions() async {
    List<PrescriptionManagementModel> prescriptions =
    await widget.mixProductionRepo.getAllPrescriptions();

    itemsWarehouseManagement.clear();

    for (var prescription in prescriptions) {
      itemsWarehouseManagement.add({
        'name': prescription.name,
        'prescriptionId': prescription.id,
      });
    }

    if (itemsWarehouseManagement.isNotEmpty) {
      selectedPrescription = itemsWarehouseManagement.first;
      maxPrescriptions = await widget.mixProductionRepo
          .getAvailablePrescription(selectedPrescription!['prescriptionId']);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> onPrescriptionChanged(Map<String, dynamic>? value) async {
    if (value == null) return;
    int prescriptionId = value['prescriptionId'];
    int available =
    await widget.mixProductionRepo.getAvailablePrescription(prescriptionId);

    setState(() {
      selectedPrescription = value;
      maxPrescriptions = available;
      _counter = 0; // نرجع العداد إلى 1 عند تغيير الخلطة
    });
  }

  void showInvalidCountDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("عدد غير مسموح"),
        content: Text("يجب أن يكون العدد بين 1 و $maxPrescriptions"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("حسنًا"),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // today's date
      firstDate: DateTime(2000), // lower bound
      lastDate: DateTime(2101), // upper bound
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        _dateController.text = formattedDate;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30.0, left: 30, right: 30),
            child: Column(
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
                Expanded(
                  child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 300,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "انتاج الخلطات",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "اختر الخلطة",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 3),
                                DropdownButtonHideUnderline(
                                  child:
                                  DropdownButton2<Map<String, dynamic>>(
                                    isExpanded: true,
                                    hint: Text(
                                      'اختر',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                        Theme.of(context).hintColor,
                                      ),
                                    ),
                                    items: itemsWarehouseManagement
                                        .map((option) {
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
                                    value: selectedPrescription,
                                    onChanged: onPrescriptionChanged,
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
                                const SizedBox(height: 16),
                                Text(
                                  "يمكن إنتاج $maxPrescriptions عملية انتاج كحد أقصى من هذه الخلطة بناءا علي الارصدة الموجودة في المخزن.",
                                  style: const TextStyle(fontSize: 16),
                                ),

                                const SizedBox(height: 16),
                                // Divider(color: ColorApp.grey,),
                                const SizedBox(height: 16),

                                // Text(
                                //   "تاريخ الانتاج",
                                //   style: TextStyle(fontSize: 16),
                                // ),
                                // const SizedBox(height: 12),

                                TextFormField(
                                  controller: _dateController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    icon: Icon(Icons.calendar_today),
                                    labelText: "حدد تاريخ الانتاج",
                                    border: OutlineInputBorder(),
                                  ),
                                  onTap: () => _selectDate(context),
                                ),

                                const SizedBox(height: 16),

                                //created At

                                Divider(color: ColorApp.grey,),
                                const SizedBox(height: 16),
                                Text(
                                  "حدد عدد الخلطات المطلوب إنتاجها:",
                                  style: TextStyle(fontSize: 16),
                                ),

                                const SizedBox(height: 8),

                                TextField(
                                  controller: _counterController,
                                  keyboardType: TextInputType.number,

                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    hintText: "ادخل عدد انتاج الخلطات",
                                    contentPadding: EdgeInsets.symmetric(vertical: 10 , horizontal: 10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    final int? parsed = int.tryParse(value);
                                    if (parsed != null && parsed >= 1 && parsed != 0) {
                                      setState(() {
                                        _counter = parsed;
                                      });
                                    }else{
                                      setState(() {
                                        _counter = 0;
                                      });
                                    }
                                  },
                                ),


                                const SizedBox(height: 30),

                                InkWell(
                                  onTap: (_counter >= 1 &&
                                      _counter <= maxPrescriptions)
                                      ? () {
                                          setState(() {

                                            isProduction = true;
                                          });
                                  } : () => showInvalidCountDialog(),

                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: (_counter >= 1 &&
                                          _counter <= maxPrescriptions && _counter>0)
                                          ? ColorApp.blue
                                          : Colors.grey,
                                      borderRadius:
                                      BorderRadius.circular(8),
                                    ),
                                    height: 55,
                                    width: double.infinity,
                                    child: Text(
                                      "انتج الخلطات",
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
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
                                child: Text("نعم",
                                    style: TextStyle(color: ColorApp.white)),
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
                                child: Text("لا",
                                    style: TextStyle(color: ColorApp.white)),
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

          if (isProduction)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  width: 350,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "هل تريد اتمام عملية الانتاج",
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: (_counter >= 1 &&
                                  _counter <= maxPrescriptions)
                                  ? () async {
                                // نفذ العملية هنا
                                print("تم إنتاج $_counter خلطات");
                                int prescriptionId = selectedPrescription!['prescriptionId'];
                                String prescriptionName = selectedPrescription!['name'];
                                if(prescriptionName!=null &&
                                    prescriptionName.isNotEmpty &&
                                    prescriptionId!=null &&
                                    prescriptionId>0
                                ){
                                  MixProductionModel mixProductionModel = MixProductionModel(
                                      mixProductionsId: 0,
                                      quantityMixProductions: _counter,
                                      employeeName: StreamData.userModel.name,
                                      fkEmployee: StreamData.userModel.userId,
                                      nameMixProductions: prescriptionName,
                                      fkPrescription: prescriptionId,
                                      dateTimeProduction: _dateController.text,
                                      createdAt: DateTime.now()
                                  );
                                  print('mixProduction_PageADD : ${mixProductionModel.dateTimeProduction}');

                                  bool isMixProductionInserted = await widget.mixProductionRepo.insertMixProduction(mixProductionModel);
                                  if(isMixProductionInserted){
                                    print("تم انتاج عدد ${_counter} خلطة");
                                    showSnackbar(context, "تم انتاج ${_counter} خلطات بنجاح" ,backgroundColor: Colors.green);
                                    Navigator.pop(context);
                                  }else{
                                    showSnackbar(context, "حدث خطأ ما" ,backgroundColor: Colors.red);

                                  }
                                }

                              } : () => showInvalidCountDialog(),
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10),
                                color: ColorApp.blue,
                                child: Text("نعم",
                                    style: TextStyle(color: ColorApp.white)),
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  setState(() {
                                    isProduction = false;
                                  });
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10),
                                color: Colors.grey,
                                child: Text("لا",
                                    style: TextStyle(color: ColorApp.white)),
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
