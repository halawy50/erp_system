
import 'package:flutter/material.dart';
import 'package:system_pvc/components/side_bar.dart';
import 'package:system_pvc/constant/stream.dart';
import 'package:system_pvc/data/model/user_model.dart';
import 'package:system_pvc/local/material_database.dart';
import 'package:system_pvc/local/mix_productions_database.dart';
import 'package:system_pvc/local/prescription_management_database/material_prescription_management_database.dart';
import 'package:system_pvc/local/prescription_management_database/prescription_management_database.dart';
import 'package:system_pvc/local/user_database.dart';
import 'package:system_pvc/repo/material_repo.dart';
import 'package:system_pvc/repo/mix_production_repo.dart';
import 'package:system_pvc/repo/prescription_management_repo.dart';
import 'package:system_pvc/repo/user_repo.dart';
import 'package:system_pvc/screens/home_screen/pages/mix_production_page/MixProductionPage.dart';
import 'package:system_pvc/screens/home_screen/pages/PurchasePage.dart';
import 'package:system_pvc/screens/home_screen/pages/setting_page/SettingPage.dart';
import 'package:system_pvc/screens/home_screen/pages/warehouse_management_page/WarehouseManagementPage.dart';
import 'pages/HistoryPage.dart';
import 'pages/InventoryPage.dart';
import 'pages/prescription_management_page/PrescriptionManagementPage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectPage = 0;
  List<Widget> pages = []; // تأكد من أن هذه هي قائمة الـ Widgets
  List<String> titles = [];

  @override
  void initState() {
    super.initState();

    // تأجيل التنفيذ حتى بعد إنشاء الواجهة
    Future.microtask(() async {
      try {
        final userDB = UserDatabase();
        await userDB.init(); // تهيئة قاعدة البيانات
        final userRepo = UserRepo(userDB);
        ////////
        final materialDB = MaterialDatabase();
        await materialDB.init(); // تهيئة قاعدة البيانات
        final materialRepo = MaterialRepo(materialDB);
        ////////////////
        //ادارة الخلطات
        final materialPrescriptionDb = MaterialPrescriptionManagementDatabase();
        final prescriptionDb = PrescriptionManagementDatabase();
        final prescriptionRepo = PrescriptionRepository(
          materialDb: materialPrescriptionDb,
          prescriptionDb: prescriptionDb
        );
        prescriptionRepo.init();
        ///////////////////////

        //انتاج الخلطات
        final mixProductionDB = MixProductionsDatabase();
        final mixPrescriptionRepo = MixProductionRepo(
            mixProductionDB ,
            materialRepo ,
            prescriptionRepo
        );
        await mixPrescriptionRepo.init();
        // int availableQuantityPrescription = await mixPrescriptionRepo.getAvailablePrescription();
        // print("AvailableQuantityPrescription 1 : ${availableQuantityPrescription}");

        setState(() {
          permissionSystem(userRepo , materialRepo , prescriptionRepo , mixPrescriptionRepo);
        });
      } catch (e) {
        // التعامل مع الأخطاء
        print("Error initializing database or loading pages: $e");
        // يمكنك هنا عرض رسالة للمستخدم في حالة حدوث خطأ
      }
    });
  }

  void permissionSystem(
      UserRepo userRepo,
      MaterialRepo materialRepo,
      PrescriptionRepository prescriptionRepo,
      MixProductionRepo mixProductionRepo,
      ) {
    pages = [];
    titles = [];

    if (StreamData.userModel.isAdmin) {
      pages = [
        WarehouseManagementPage(
            materialRepo: materialRepo, prescriptionRepo: prescriptionRepo),
        PurchasePage(),
        MixProductionPage(
          mixProductionRepo: mixProductionRepo ,
          prescriptionRepository: prescriptionRepo,
          userRepo: userRepo,
        ),
        PrescriptionManagementPage(
            prescriptionRepo: prescriptionRepo, materialRepo: materialRepo),
        InventoryPage(),
        HistoryPage(),
        SettingPage(userRepo: userRepo),
      ];
      titles = [
        "إدارة المخزن",
        "عمليات الشراء",
        "إنتاج الخلطات",
        "إدارة الخلطة",
        "الجرد",
        "تتبع العمليات",
        "إعدادات النظام",
      ];
    } else {
      if (StreamData.userModel.isWarehouseManagement) {
        pages.add(WarehouseManagementPage(
            materialRepo: materialRepo, prescriptionRepo: prescriptionRepo));
        titles.add("إدارة المخزن");
      }
      if (StreamData.userModel.isPurchase) {
        pages.add(PurchasePage());
        titles.add("عمليات الشراء");
      }
      if (StreamData.userModel.isMixProduction) {
        pages.add(MixProductionPage(
          mixProductionRepo: mixProductionRepo ,
          prescriptionRepository: prescriptionRepo,
          userRepo: userRepo,
        ));
        titles.add("إنتاج الخلطات");
      }
      if (StreamData.userModel.isPrescriptionManagement) {
        pages.add(PrescriptionManagementPage(
            prescriptionRepo: prescriptionRepo, materialRepo: materialRepo));
        titles.add("إدارة الخلطة");
      }
      if (StreamData.userModel.isInventory) {
        pages.add(InventoryPage());
        titles.add("الجرد");
      }
      if (StreamData.userModel.isHistory) {
        pages.add(HistoryPage());
        titles.add("تاريخ");
      }

      // نضيف صفحة الإعدادات دائمًا
      pages.add(SettingPage(userRepo: userRepo));
      titles.add("إعدادات النظام");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        StreamData.isSlider?
        SideBar(
        selectPage: selectPage,
        titles: titles,
        isSlider: (p0) {
          setState(() {
            StreamData.isSlider = false;
          });
        },
        onItemSelected: (index) {
          setState(() {
            selectPage = index;
            print("object : ${pages[index]}");
          });
        },
      ):Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0 , horizontal: 10),
            child: IconButton(onPressed: () {
              setState(() {
                StreamData.isSlider = true;
              });
            }, icon: Icon(Icons.arrow_forward_ios, color: Colors.black,)),
          ),
        ),
          Expanded(
            child: pages.isNotEmpty
                ? pages[selectPage] // تأكد من أن الصفحة موجودة في القائمة
                : Center(child: CircularProgressIndicator()), // عرض تحميل إذا كانت الصفحات غير جاهزة
          ),
        ],
      ),
    );
  }
}
