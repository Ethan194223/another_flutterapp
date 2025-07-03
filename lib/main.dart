import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'ai_chat_bot.dart'; // Import the AIChatBot widget
import 'dart:io'; // For File operations
import 'dart:convert'; // For JSON encoding/decoding
import 'login_page.dart'; // Import your login_page.dart file
import 'image_recognition.dart'; // Import the image_recognition.dart file

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animal in the Earth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(), // Start with LoginPage
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _titleController = TextEditingController();
  List<ImageData> _images = [];
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  void _onItemTapped(int index) {
    if (index == 2) {
      // Navigate to MapScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MapScreen()),
      );
    } else if (index == 3) {
      // Navigate to Image Recognition Page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ImageRecognitionPage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _loadImages() async {
    final images = await ImageStorageHelper().readImages();
    setState(() {
      _images = images;
    });
  }

  Future<void> _addImage() async {
    if (_image != null) {
      final newImage = ImageData(_image!.path, _titleController.text);
      setState(() {
        _images.add(newImage);
      });
      await ImageStorageHelper().writeImages(_images);
      setState(() {
        _image = null;
        _titleController.clear();
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal in the Earth'),
      ),
      body: Stack(
        children: [
          Center(
            child: _selectedIndex == 0
                ? ImageStorage(
              storage: ImageStorageHelper(),
              titleController: _titleController,
              images: _images,
              image: _image,
              pickImage: _pickImage,
              addImage: _addImage,
            )
                : const AIChatBot(),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ImageRecognitionPage(),
                  ),
                );
              },
              backgroundColor: Colors.blue, // Visible button background color
              elevation: 6.0, // Add elevation
              child: const Icon(Icons.camera, color: Colors.white), // Visible icon
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Images',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'AI Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Image Recognition',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange, // Set selected item color
        unselectedItemColor: Colors.grey, // Set unselected item color
        backgroundColor: Colors.white, // Set navigation bar background color
        onTap: _onItemTapped,
      ),
    );
  }
}

class ImageData {
  final String imagePath;
  final String title;

  ImageData(this.imagePath, this.title);

  Map<String, dynamic> toJson() => {
    'imagePath': imagePath,
    'title': title,
  };

  ImageData.fromJson(Map<String, dynamic> json)
      : imagePath = json['imagePath'],
        title = json['title'];
}

class ImageStorageHelper {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/images.json');
  }

  Future<List<ImageData>> readImages() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => ImageData.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<File> writeImages(List<ImageData> images) async {
    final file = await _localFile;
    return file.writeAsString(json.encode(images));
  }
}

class ImageStorage extends StatelessWidget {
  final ImageStorageHelper storage;
  final TextEditingController titleController;
  final List<ImageData> images;
  final XFile? image;
  final Function pickImage;
  final Function addImage;

  const ImageStorage({
    Key? key,
    required this.storage,
    required this.titleController,
    required this.images,
    required this.image,
    required this.pickImage,
    required this.addImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Enter Title',
                ),
              ),
              const SizedBox(height: 16),
              image == null
                  ? const Text('No image selected.')
                  : Image.file(File(image!.path)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => pickImage(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Set button color
                  elevation: 6.0, // Add elevation
                ),
                child: const Text('Pick Image', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => addImage(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Set button color
                  elevation: 6.0, // Add elevation
                ),
                child: const Text('Add Image', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Image.file(File(images[index].imagePath)),
                title: Text(images[index].title),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    images.removeAt(index);
                    await storage.writeImages(images);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
      ),
      body: const GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194), // Example coordinates
          zoom: 12.0,
        ),
      ),
    );
  }
}



