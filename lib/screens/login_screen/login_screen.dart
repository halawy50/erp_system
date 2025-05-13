import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_pvc/constant/color.dart';
import 'package:system_pvc/constant/stream.dart';
import 'package:system_pvc/data/model/user_model.dart';
import 'package:system_pvc/local/user_database.dart';
import 'package:system_pvc/repo/user_repo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late SharedPreferences prefs;
  late UserRepo userRepo;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isEmailValid = true;
  bool isEmailEmpty = false;

  bool isPasswordEmpty = false;
  bool isPasswordValid = true;
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    initDependencies();
  }

  Future<void> initDependencies() async {
    prefs = await SharedPreferences.getInstance();
    final userDatabase = UserDatabase();
    userRepo = UserRepo(userDatabase);
    await userRepo.init();
  }

  bool validateEmail(String value) {
    final pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    return RegExp(pattern).hasMatch(value);
  }

  bool validatePassword(String value) {
    return value.length >= 6;
  }

  Future<void> handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    setState(() {
      isEmailEmpty = email.isEmpty;
      isPasswordEmpty = password.isEmpty;
      isEmailValid = validateEmail(email);
      isPasswordValid = validatePassword(password);
    });

    if (isEmailEmpty || isPasswordEmpty || !isEmailValid || !isPasswordValid) return;

    final user = await userRepo.getUserByEmailAndPassword(email, password);

    if (user != null && user.userId > 0) {
      // يمكنك هنا حفظ المستخدم في SharedPreferences أو التنقل إلى الشاشة الرئيسية
      // prefs.setInt('user_id', user.userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم تسجيل الدخول بنجاح")),
      );
      StreamData.userModel = user;
      Navigator.pushReplacementNamed(context, 'home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("البريد الإلكتروني أو كلمة المرور غير صحيحة")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 300,
            child: Column(
              children: [
                Text("سجل دخولك الآن", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "البريد الإلكتروني",
                    errorText: isEmailEmpty
                        ? 'برجاء إدخال البريد الإلكتروني'
                        : (!isEmailValid ? 'البريد الإلكتروني غير صحيح' : null),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: ColorApp.blue),
                    ),
                  ),
                ),

                SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "كلمة المرور",
                    errorText: isPasswordEmpty
                        ? 'برجاء إدخال كلمة المرور'
                        : (!isPasswordValid ? 'كلمة المرور ضعيفة (6 أحرف على الأقل)' : null),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: ColorApp.blue),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),

                SizedBox(height: 30),
                InkWell(
                  onTap: handleLogin,
                  child: Container(
                    height: 55,
                    width: double.infinity,
                    alignment: Alignment.center,
                    color: ColorApp.blue,
                    child: Text(
                      "تسجيل الدخول",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
