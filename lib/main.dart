import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Create a Post App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  List<String> selectedImages = [];
  bool isCompressing = false;
  bool isUploading = false;

  void onSelectImage(String imageName) async {
    if (selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum of 5 images can be selected')),
      );
      return;
    }

    setState(() {
      selectedImages.add(imageName);
    });

    simulateCompression(imageName);
  }

  Future<void> simulateCompression(String imageName) async {
    setState(() {
      isCompressing = true;
    });

    await Future.delayed(Duration(seconds: Random().nextInt(2) + 3));

    int savedSize = Random().nextInt(500);

    setState(() {
      isCompressing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Image compressed and saved $savedSize Kb in size.')),
    );
  }

  Future<void> simulateUpload() async {
    if (selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No images selected for upload')),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    await Future.delayed(Duration(seconds: Random().nextInt(4) + 4));

    setState(() {
      selectedImages.clear();
      isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Images uploaded successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.blueGrey[50],
              height: 100,
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedImages.length,
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Image.asset(
                            'assets/images/${selectedImages[index]}',
                            width: 100),
                      ),
                    ),
                  ),
                  if (!isCompressing && !isUploading)
                    IconButton(
                      icon: Icon(Icons.upload, color: Colors.red),
                      onPressed: simulateUpload,
                    ),
                  if (isCompressing || isUploading)
                    Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: _currentIndex == 0
                  ? CameraTab()
                  : PhotosTab(onSelectImage: onSelectImage),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Photos',
          ),
        ],
      ),
    );
  }
}

class CameraTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Camera Tab Content'));
  }
}

class PhotosTab extends StatelessWidget {
  final Function(String) onSelectImage;

  PhotosTab({required this.onSelectImage});

  final List<String> _imageNames = [
    'cuteCatPic1.jpeg',
    'cuteCatPic2.jpeg',
    'cuteCatPic3.jpeg',
    'cuteDogPic1.jpeg',
    'cuteDogPic2.jpeg',
    'cuteDogPic3.jpeg',
    'cuteStitch.jpeg',
    'pussInBoots.webp',
    'babyYoda.jpeg',
    'mrTripDub.webp',
    'playoffP.avif',
    'funGuy.webp',
    'childhood1.jpeg',
    'childhood2.jpeg',
    'childhood3.jpeg',
    'siPalingEstetik1.jpeg',
    'siPalingEstetik2.jpeg',
    'siPalingEstetik3.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.lightBlue[50],
      child: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemCount: _imageNames.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onSelectImage(_imageNames[index]),
            child: Image.asset('assets/images/${_imageNames[index]}',
                fit: BoxFit.cover),
          );
        },
      ),
    );
  }
}
