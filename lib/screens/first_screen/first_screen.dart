import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart' as sql;
import 'package:file_picker/file_picker.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _noDatabaseFile = false;
  String _savedDbPath = '';
  bool _isLoading = true; // Add loading state to prevent UI flicker

  Future<void> _checkExistingDatabase() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    String? savedDbPath = prefs.getString('dbPath');

    if (savedDbPath != null && savedDbPath.isNotEmpty) {
      // Check if the saved database path exists and is valid
      final file = File(savedDbPath);
      if (file.existsSync()) {
        try {
          // Verify if it's a valid system database
          final db = sql.sqlite3.open(savedDbPath);
          final result = db.select("SELECT name FROM sqlite_master WHERE type='table' AND name='users';");
          db.dispose();

          if (result.isNotEmpty) {
            // Valid database exists, proceed directly to the next screen
            setState(() {
              _controller.text = savedDbPath;
              _savedDbPath = savedDbPath;
              _isLoading = false;
            });

            // Delay navigation slightly to allow state to update
            Future.microtask(() {
              Navigator.pushReplacementNamed(context, 'login');
            });
            return;
          }
        } catch (e) {
          // Error opening database, will fall back to manual selection
          print('Error validating existing database: ${e.toString()}');
        }
      }
    }

    // If we reach here, either no path was saved or the database is invalid
    setState(() {
      if (savedDbPath != null && savedDbPath.isNotEmpty) {
        _controller.text = savedDbPath;
        _savedDbPath = savedDbPath;
      }
      _isLoading = false;
    });
  }

  Future<void> _pickDirectory() async {
    if (_noDatabaseFile) {
      // اختيار مجلد لحفظ قاعدة بيانات جديدة
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        // إنشاء المسار الكامل لقاعدة البيانات الجديدة
        final fullPath = p.join(selectedDirectory, 'system_database.db');
        setState(() {
          _controller.text = fullPath; // حفظ المسار الكامل
        });
      }
    } else {
      // اختيار ملف قاعدة بيانات موجود
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['db'],
        type: FileType.custom,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _controller.text = result.files.single.path!; // حفظ المسار الكامل للملف
        });
      }
    }
  }

  Future<void> _savePathAndCreateDB() async {
    if (_controller.text.isEmpty) {
      _showErrorDialog('من فضلك حدد مسار قاعدة البيانات');
      return;
    }

    String dbPath = _controller.text;
    final prefs = await SharedPreferences.getInstance();

    if (_noDatabaseFile) {
      // التحقق من أن المسار يتضمن بالفعل اسم الملف
      if (!dbPath.toLowerCase().endsWith('.db')) {
        dbPath = p.join(dbPath, 'system_database.db');
      }

      final file = File(dbPath);
      final directory = file.parent;

      // التأكد من وجود المجلد
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      // إنشاء قاعدة بيانات جديدة
      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }

      final db = sql.sqlite3.open(dbPath);

      db.execute('''
        CREATE TABLE IF NOT EXISTS settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          dbPath TEXT
        );
      ''');

      db.execute('INSERT INTO settings (dbPath) VALUES (?);', [dbPath]);

      db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          userId INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          jobTitle TEXT,
          userName TEXT,
          password TEXT,
          createdAt TEXT,
          isWarehouseManagement INTEGER,
          insertWarehouseManagement INTEGER,
          updateWarehouseManagement INTEGER,
          deleteWarehouseManagement INTEGER,
          isPurchase INTEGER,
          insertPurchase INTEGER,
          updatePurchase INTEGER,
          deletePurchase INTEGER,
          isMixProduction INTEGER,
          insertMixProduction INTEGER,
          updateMixProduction INTEGER,
          deleteMixProduction INTEGER,
          isPrescriptionManagement INTEGER,
          insertPrescriptionManagement INTEGER,
          updatePrescriptionManagement INTEGER,
          deletePrescriptionManagement INTEGER,
          isHistory INTEGER,
          isInventory INTEGER,
          isAdmin INTEGER
        );
      ''');

      db.execute('''
        INSERT INTO users (
          name, jobTitle, userName, password, createdAt,
          isWarehouseManagement, insertWarehouseManagement, updateWarehouseManagement, deleteWarehouseManagement,
          isPurchase, insertPurchase, updatePurchase, deletePurchase,
          isMixProduction, insertMixProduction, updateMixProduction, deleteMixProduction,
          isPrescriptionManagement, insertPrescriptionManagement, updatePrescriptionManagement, deletePrescriptionManagement,
          isHistory, isInventory, isAdmin
        ) VALUES (
          'ا/حسام محمد', 'المسؤول', 'hossam@admin.com', 'admin123', '${DateTime.now().toIso8601String()}',
          1, 1, 1, 1,
          1, 1, 1, 1,
          1, 1, 1, 1,
          1, 1, 1, 1,
          1, 1, 1
        );
      ''');

      db.dispose();
    } else {
      // التحقق من أن الملف المحدد موجود
      final file = File(dbPath);
      if (!file.existsSync()) {
        _showErrorDialog('الملف المحدد غير موجود');
        return;
      }

      try {
        // التحقق من صحة قاعدة البيانات المختارة
        final db = sql.sqlite3.open(dbPath);
        final result = db.select("SELECT name FROM sqlite_master WHERE type='table' AND name='users';");
        if (result.isEmpty) {
          _showErrorDialog('الملف المحدد ليس قاعدة بيانات صالحة للنظام');
          db.dispose();
          return;
        }
        db.dispose();
      } catch (e) {
        _showErrorDialog('حدث خطأ أثناء فتح قاعدة البيانات: ${e.toString()}');
        return;
      }
    }

    // تحديث عرض المسار في واجهة المستخدم
    setState(() {
      _controller.text = dbPath;
    });

    // حفظ المسار الكامل في SharedPreferences
    await prefs.setString('dbPath', dbPath);

    Navigator.pushReplacementNamed(context, 'login');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkExistingDatabase();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking database
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("حدد مسار قاعدة البيانات على الجهاز"),
              const SizedBox(height: 30),
              Row(
                children: [
                  Checkbox(
                    value: _noDatabaseFile,
                    onChanged: (value) async {
                      final newValue = value ?? false;

                      if (newValue) {
                        // عند تحديد الخيار، نحفظ المسار الحالي ثم نمسحه
                        if (_controller.text.isNotEmpty) {
                          _savedDbPath = _controller.text;
                        }
                        setState(() {
                          _noDatabaseFile = true;
                          _controller.text = '';
                        });
                      } else {
                        // عند إلغاء التحديد، نسترجع المسار المحفوظ
                        setState(() {
                          _noDatabaseFile = false;
                          if (_savedDbPath.isNotEmpty) {
                            _controller.text = _savedDbPath;
                          } else {
                            _checkExistingDatabase();
                          }
                        });
                      }
                    },
                  ),
                  const Text('لا أمتلك ملف قاعدة بيانات'),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickDirectory,
                child: AbsorbPointer(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: _noDatabaseFile ? 'اختر مسار حفظ الملف' : 'اختر ملف قاعدة البيانات',
                      suffixIcon: const Icon(Icons.folder_open),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _savePathAndCreateDB,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  color: Colors.blue,
                  height: 55,
                  child: const Center(
                    child: Text(
                      "التالي",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}