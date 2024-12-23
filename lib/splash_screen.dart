import 'package:flutter/material.dart';
import 'dart:async';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showSecondImage = false; // للتحكم في عرض الصورة الثانية

  @override
  void initState() {
    super.initState();


    Timer(const Duration(seconds: 5), () {
      setState(() {
        _showSecondImage = true; // عرض الصورة الثانية
      });


      Timer(const Duration(seconds: 4), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية
          Positioned.fill(
            child: Image.asset(
              _showSecondImage
                  ? 'assets/images/iPhone.jpg' // الصورة الثانية
                  : 'assets/images/aa.jpg', // الصورة الأولى
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // النص الرئيسي
                const Text(
                  "",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8FBC8F),
                  ),
                ),
                const SizedBox(height: 20),
                // الصورة الرئيسية (فقط عند الصورة الأولى)
                if (!_showSecondImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/dd.jpg', // مسار صورة النبات
                      height: 250,
                      width: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
