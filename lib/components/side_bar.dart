import 'package:flutter/material.dart';
import 'package:system_pvc/screens/login_screen/login_screen.dart'; // تأكد من المسار الصحيح للـ LoginScreen

class SideBar extends StatelessWidget {
  final int selectPage;
  final List<String> titles;
  final Function(int) onItemSelected;

  const SideBar({
    super.key,
    required this.selectPage,
    required this.titles,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: Colors.blue,
      child: Column(
        children: [
          // قائمة العناصر
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: titles.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => onItemSelected(index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      color: selectPage == index
                          ? const Color(0xFF7855E5)
                          : Colors.blue,
                      child: Text(
                        titles[index],
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // زر تسجيل الخروج
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                // الانتقال إلى صفحة تسجيل الدخول
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    "تسجيل الخروج",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
