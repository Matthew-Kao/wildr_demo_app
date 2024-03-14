import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Create a Post App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
  final List<Widget> _children = [
    CameraTab(),
    PhotosTab(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _children[_currentIndex],
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                'Status Area - Show selected media here',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'Photos',
          ),
        ],
      ),
    );
  }
}

class CameraTab extends StatefulWidget {
  @override
  _CameraTabState createState() => _CameraTabState();
}

class _CameraTabState extends State<CameraTab> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _setupCameras();
  }

  Future<void> _setupCameras() async {
    try {
      _cameras = await availableCameras();

      _controller = CameraController(_cameras![0], ResolutionPreset.medium);
      await _controller!.initialize();
    } on CameraException catch (e) {
      print(e);
    }

    if (!mounted) return;
    setState(() {
      _isReady = true;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return Center(child: CircularProgressIndicator());
    }

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width /
                _controller!.value.aspectRatio,
            child: CameraPreview(_controller!),
          ),
        ),
      ),
    );
  }
}

class PhotosTab extends StatelessWidget {
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
    return SafeArea(
      child: Container(
        color: Colors.lightBlue[50],
        child: GridView.builder(
          padding:
              EdgeInsets.only(top: 16.0, left: 10.0, right: 10.0, bottom: 10.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: (1 / 1),
          ),
          itemCount: _imageNames.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GestureDetector(
                onTap: () {
                  print('Selected image: ${_imageNames[index]}');
                },
                child: Image.asset(
                  'assets/images/${_imageNames[index]}',
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
