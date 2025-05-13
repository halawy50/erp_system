
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_pvc/screens/first_screen/first_screen.dart';
import 'package:system_pvc/screens/home_screen/home_screen.dart';
import 'package:system_pvc/screens/login_screen/login_screen.dart';

void main()  {

  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'TajawalMedium'
      ),
      title: 'برنامج بصفحتين و SQLite',
      debugShowCheckedModeBanner: false,
      // إعداد اللغة والاتجاه
      locale: const Locale('ar', ''), // اللغة العربية
      supportedLocales: const [
        Locale('ar', ''), // العربية
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      routes: {
        '/': (_) => FirstScreen(),
        'login': (_) => LoginScreen(),
        'home': (_) =>  Directionality( // اتجاه التطبيق من اليمين لليسار
            textDirection: TextDirection.rtl,
            child: HomeScreen(),
        ),
      },
    );
  }
}
