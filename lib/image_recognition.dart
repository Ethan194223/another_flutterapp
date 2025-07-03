import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ML Kit Image Recognition',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ImageRecognitionPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ImageRecognitionPage extends StatefulWidget {
  const ImageRecognitionPage({Key? key}) : super(key: key);

  @override
  State<ImageRecognitionPage> createState() => _ImageRecognitionPageState();
}

class _ImageRecognitionPageState extends State<ImageRecognitionPage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  List<ImageLabel> _labels = [];

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _labels = [];
      });
      _recognizeImage(_image!);
    }
  }

  Future<void> _recognizeImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));
    try {
      final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
      setState(() {
        _labels = labels;
      });
    } catch (e) {
      setState(() {
        _labels = [];
      });
    } finally {
      imageLabeler.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Recognition'),
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_image != null)
                Image.file(
                  _image!,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                )
              else
                const Text('No image selected'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Select Image'),
              ),
              const SizedBox(height: 16),
              Text(
                'Recognized Labels:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._labels.map((label) => Text('${label.label}: ${label.confidence.toStringAsFixed(2)}')),
            ],
          ),
          // Add Floating Action Button (FAB)
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _pickImage,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.camera_alt),
            ),
          ),
        ],
      ),
    );
  }
}

