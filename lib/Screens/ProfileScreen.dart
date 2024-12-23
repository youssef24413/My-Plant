import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? currentUser;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  // الحصول على بيانات المستخدم الحالي
  void getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUser = user;
      profileImageUrl = user?.photoURL;
    });
  }

  // اختيار صورة من المعرض
  Future<void> pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      uploadImageToFirebase(file);
    }
  }

  // رفع الصورة إلى Firebase Storage
  Future<void> uploadImageToFirebase(File file) async {
    try {
      String uid = currentUser!.uid;
      Reference storageRef =
      FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');
      await storageRef.putFile(file);
      String downloadUrl = await storageRef.getDownloadURL();

      // تحديث رابط الصورة الشخصية في Firebase Auth
      await currentUser!.updatePhotoURL(downloadUrl);
      setState(() {
        profileImageUrl = downloadUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  // وظيفة زر التحديث
  void refreshProfile() {
    getCurrentUser();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile refreshed successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, // تغطية العرض بالكامل
        height: double.infinity, // تغطية الارتفاع بالكامل
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Untitled3 1.jpg"), // صورة الخلفية
            fit: BoxFit.cover, // تجعل الصورة تغطي الشاشة بالكامل
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // صورة المستخدم
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: profileImageUrl != null
                          ? NetworkImage(profileImageUrl!)
                          : AssetImage('assets/placeholder.png')
                      as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.edit, color: Colors.green),
                        onPressed: pickImage, // وظيفة تغيير الصورة
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // اسم المستخدم والبريد الإلكتروني
                Text(
                  currentUser?.displayName ?? "No Name",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  currentUser?.email ?? "No Email",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 30),
                // مفتاح الإشعارات
                SwitchListTile(
                  value: true, // قيمة مفتاح الإشعارات (true: قيد التشغيل)
                  onChanged: (value) {
                    // تحديث حالة الإشعارات
                  },
                  title: Text(
                    "Care notification",
                    style: TextStyle(color: Colors.black),
                  ),
                  secondary:
                  Icon(Icons.notifications_active, color: Colors.green),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: refreshProfile, // زر التحديث
        backgroundColor: Colors.green[400],
        child: Icon(Icons.refresh),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
