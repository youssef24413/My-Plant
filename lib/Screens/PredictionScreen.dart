import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({Key? key}) : super(key: key);

  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  File? _file;
  String body = '';
  bool isLoading = false;

  // دالة لتحميل الصورة
  Future<void> uploadImage() async {
    try {
      final myfile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (myfile == null) return;
      if (!mounted) return;
      setState(() {
        _file = File(myfile.path);
      });
    } catch (e) {
      print("Error picking or uploading image: $e");
    }
  }

  // دالة لإرسال الصورة إلى السيرفر والتنبؤ
  Future<void> predict() async {
    if (_file == null) {
      print("No file selected for prediction.");
      return;
    }

    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      // تحويل الصورة إلى بايتات ثم ترميزها إلى Base64
      List<int> imageBytes = _file!.readAsBytesSync();
      String base64String = base64Encode(imageBytes);

      // التأكد من أن الصورة صالحة قبل الإرسال
      if (base64String.isEmpty) {
        print("Image is empty or corrupted");
        setState(() {
          body = "Invalid image!";
        });
        return;
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // إرسال الصورة إلى السيرفر
      final response = await http.put(
        Uri.parse("http://172.20.10.2:5000/predict"),
        body: jsonEncode({'image': base64String, 'model': 'test'}),
        headers: headers,
      );

      if (!mounted) return; // تحقق مما إذا كان الـ Widget لا يزال موجودًا

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        if (!mounted) return; // تحقق مرة أخرى بعد العملية
        setState(() {
          final responseData = jsonDecode(response.body);
          if (responseData.containsKey('plant_name') && responseData.containsKey('disease_name')) {
            body = 'Plant: ${responseData['plant_name']}\nDisease: ${responseData['disease_name']}';
          } else {
            body = 'Prediction failed or no class found';
          }
        });
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      if (!mounted) return; // تحقق مما إذا كان الـ Widget لا يزال موجودًا
      setState(() {
        isLoading = false;
      });
      print("Error in prediction: $e");
    }
  }

  // دالة لعرض الحوار
  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Image'),
          content: const Text('Would you like to upload a photo?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الحوار
                uploadImage(); // استدعاء دالة تحميل الصورة
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الحوار
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  // واجهة المستخدم
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Disease Prediction"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showUploadDialog(context),
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              if (_file != null) ...[
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.file(
                    _file!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : predict,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Predict Disease'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (!mounted) return;
                    setState(() {
                      _file = null;
                      body = '';
                    });
                  },
                  child: const Text('Remove Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
              if (body.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.lightGreen[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: Text(
                    ' $body',
                    style: const TextStyle(
                        fontSize: 18, color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
