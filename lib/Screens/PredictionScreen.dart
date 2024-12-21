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

  // دالة لتطبيع الصورة
  List<int> normalizeImage(List<int> imageBytes) {
    // تطبيع الصورة إلى نطاق [0, 1]
    return imageBytes.map((e) => (e / 255.0 * 255).round()).toList();
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
      // تحويل الصورة إلى بايتات ثم تطبيعها
      List<int> imageBytes = _file!.readAsBytesSync();
      List<int> normalizedImage = normalizeImage(imageBytes); // تطبيع الصورة

      String base64String = base64Encode(normalizedImage);

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // إرسال الصورة إلى السيرفر
      final response = await http.put(
        Uri.parse("http://192.168.1.9:5000/predict"), // تأكد من تحديث هذا العنوان
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
          if (responseData.containsKey('predicted_class')) {
            body = responseData['predicted_class'];
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

  // دالة لعرض الحوار لتحميل الصورة
  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Disease Plant'),
          content: const Text('Would you like to upload a photo?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                uploadImage();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prediction Screen"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showUploadDialog(context),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Upload Photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              if (_file != null) ...[
                Image.file(
                  _file!,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: isLoading ? null : predict,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Predict Disease Plant'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (!mounted) return;
                        setState(() {
                          _file = null;
                          body = '';
                        });
                      },
                      child: const Text('Remove Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
              if (body.isNotEmpty) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Response: $body',
                    style: const TextStyle(fontSize: 26, color: Colors.greenAccent),
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
