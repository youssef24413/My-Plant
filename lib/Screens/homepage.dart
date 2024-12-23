import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Drawer.dart'; // استيراد الـ Drawer
import 'ProfileScreen.dart';
import 'SearchScreen.dart';
import 'SettingsScreen.dart';
import 'PredictionScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<String> _titles = [
    'Home Page',
    'Settings Page',
    'Profile Page',
    'Search Page',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.green,
      ),
      drawer: const AppDrawer(), // استخدام AppDrawer هنا
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Untitled3 1.jpg'), // مسار الصورة
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main Content
          IndexedStack(
            index: _currentIndex,
            children: [
              Center(
                child: Container(), // الصفحة الرئيسية
              ),
              SettingsScreen(),
              ProfileScreen(),
              SearchScreen(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.green, // إضافة اللون الأخضر للخلفية
            selectedItemColor: Colors.white, // لون الأيقونات المختارة
            unselectedItemColor: Colors.grey[300], // لون الأيقونات غير المختارة
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  decoration: const BoxDecoration(
                    color: Colors.green, // لون خلفية الأيقونة
                    shape: BoxShape.circle, // جعل الخلفية دائرية
                  ),
                  padding: const EdgeInsets.all(10), // التحكم بحجم الدائرة
                  child: const Icon(
                    Icons.home,
                    color: Colors.white, // لون الأيقونة داخل الخلفية
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                ),
                label: 'Settings',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
                label: 'Search',
              ),
            ],
          ),
          Positioned(
            top: -30,
            left: MediaQuery.of(context).size.width / 2 - 29,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PredictionScreen()),
                );
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.camera_alt, size: 30),
            ),
          ),
        ]
        ,
      ),
    );
  }
}
