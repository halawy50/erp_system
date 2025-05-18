import 'package:flutter/material.dart';
import 'package:system_pvc/constant/stream.dart';
import 'package:system_pvc/screens/login_screen/login_screen.dart'; // تأكد من المسار الصحيح للـ LoginScreen

class SideBar extends StatefulWidget {
  final int selectPage;
  final List<String> titles;
  final Function(int) onItemSelected;
  final Function(bool) isSlider;

  const SideBar({
    super.key,
    required this.selectPage,
    required this.titles,
    required this.onItemSelected,
    required this.isSlider,
  });

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0 , horizontal: 10),
            child: IconButton(onPressed: () {
              setState(() {
                widget.isSlider(false);
              });
            }, icon: Icon(Icons.arrow_back_ios , color: Colors.white,)),
          ),
          // قائمة العناصر
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: widget.titles.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => widget.onItemSelected(index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      color: widget.selectPage == index
                          ? const Color(0xFF7855E5)
                          : Colors.blue,
                      child: Text(
                        widget.titles[index],
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
