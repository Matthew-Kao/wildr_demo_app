import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:collection';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart' hide ImageFormat;
import 'dart:io';
import 'package:video_thumbnail/video_thumbnail.dart';

List<CameraDescription> cameras = [];

class AppColors {
  static const Color primaryColor = Color(0xFF008080);
  static const Color accentColor = Color(0xFFFF6B6B);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF333333);
  static const Color iconColor = Color(0xFFAAAAAA);
  static const Color uploadColor = Color(0xFFFF0000);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> selectedMedia = [];
  bool isCompressing = false;
  bool isUploading = false;
  int _currentIndex = 0;
  int videoCounter = 1;
  int pictureCounter = 1;

  final Queue<String> snackBarQueue = Queue<String>();

  void onSelectMedia(String mediaPath,
      {bool isVideo = false,
      bool isPicTaken = false,
      bool isVideoFromPhotos = false}) {
    if (selectedMedia.length >= 5) {
      enqueueSnackBar('Maximum of 5 items can be selected');
      return;
    }
    setState(() {
      selectedMedia.add(mediaPath);
    });

    if (isPicTaken) {
      simulateCompression(mediaPath, isPicTaken: true);
    } else if (isVideo) {
      simulateCompression(mediaPath, isVideo: true);
    } else if (isVideoFromPhotos) {
      simulateCompression(mediaPath, isVideoFromPhotos: true);
    } else {
      simulateCompression(mediaPath);
    }
  }

  void enqueueSnackBar(String message) {
    snackBarQueue.add(message);
    if (snackBarQueue.length == 1) {
      showNextSnackBar();
    }
  }

  void showNextSnackBar() {
    if (snackBarQueue.isNotEmpty) {
      final message = snackBarQueue.removeFirst();
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(message),
          duration: Duration(seconds: 3),
        )).closed.then((_) {
          if (snackBarQueue.isNotEmpty) {
            showNextSnackBar();
          }
        });
    }
  }

  Future<void> simulateCompression(String imageName,
      {bool isVideo = false,
      bool isPicTaken = false,
      bool isVideoFromPhotos = false}) async {
    setState(() {
      isCompressing = true;
    });
    await Future.delayed(Duration(seconds: Random().nextInt(2) + 3));
    int savedSize = Random().nextInt(500);
    setState(() {
      isCompressing = false;
    });

    if (isVideo) {
      enqueueSnackBar(
          'Video recorded number ${videoCounter++} compressed and saved $savedSize Kb in size.');
    } else if (isPicTaken) {
      enqueueSnackBar(
          'Image snapped number ${pictureCounter++} compressed and saved $savedSize Kb in size.');
    } else if (isVideoFromPhotos) {
      enqueueSnackBar(
          'Video $imageName compressed and saved $savedSize Kb in size.');
    } else {
      enqueueSnackBar(
          'Image $imageName compressed and saved $savedSize Kb in size.');
    }
  }

  Future<void> simulateUpload() async {
    if (selectedMedia.isEmpty) {
      enqueueSnackBar('No media selected for upload');
      return;
    }

    setState(() {
      isUploading = true;
    });

    await Future.delayed(Duration(seconds: Random().nextInt(4) + 4));

    setState(() {
      selectedMedia.clear();
      isUploading = false;
      videoCounter = 1;
      pictureCounter = 1;
    });

    enqueueSnackBar('Media uploaded successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wildr'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              color: Theme.of(context).primaryColorLight,
              height: 100,
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      itemCount: selectedMedia.length,
                      itemBuilder: (context, index) {
                        final item = selectedMedia[index];
                        final isVideo = item.contains('_cameravideo') ||
                            item.contains('thumbnail');

                        return Container(
                          margin: EdgeInsets.only(
                              left: 10.0,
                              right:
                                  index == selectedMedia.length - 1 ? 10.0 : 0),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4.0,
                                spreadRadius: 2.0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: item.contains('/')
                                    ? Image.file(
                                        File(item.replaceFirst(
                                            '_cameravideo', '')),
                                        fit: BoxFit.cover,
                                        width: 80,
                                        height: 80)
                                    : Image.asset('assets/images/$item',
                                        fit: BoxFit.cover,
                                        width: 80,
                                        height: 80),
                              ),
                              if (isVideo)
                                Icon(Icons.play_circle_outline,
                                    size: 40.0, color: Colors.white70),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (!isCompressing && !isUploading)
                    IconButton(
                      icon: Icon(Icons.cloud_upload, color: Colors.redAccent),
                      onPressed: simulateUpload,
                    ),
                  if (isCompressing)
                    Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.redAccent),
                      ),
                    ),
                  if (isUploading)
                    Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: _currentIndex == 0
                  ? CameraTab(
                      onSelectMedia: onSelectMedia,
                      simulateCompression: simulateCompression,
                    )
                  : PhotosTab(onSelectMedia: onSelectMedia),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.accentColor,
        unselectedItemColor: AppColors.iconColor,
        backgroundColor: AppColors.primaryColor,
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

class CameraTab extends StatefulWidget {
  final Function(String,
      {bool isVideo, bool isPicTaken, bool isVideoFromPhotos}) onSelectMedia;
  final Function(String,
      {bool isVideo,
      bool isPicTaken,
      bool isVideoFromPhotos}) simulateCompression;

  CameraTab({required this.onSelectMedia, required this.simulateCompression});

  @override
  _CameraTabState createState() => _CameraTabState();
}

class _CameraTabState extends State<CameraTab> {
  CameraController? controller;
  List<File> files = [];
  bool isRecording = false;
  int pictureCounter = 1;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _takePicture() async {
    if (!controller!.value.isInitialized) {
      print("Controller is not initialized");
      return;
    }
    if (controller!.value.isTakingPicture) {
      return;
    }
    try {
      final xFile = await controller!.takePicture();

      widget.onSelectMedia(xFile.path, isVideo: false, isPicTaken: true);
    } catch (e) {
      print(e);
    }
  }

  void _recordVideo() async {
    if (controller!.value.isRecordingVideo) {
      final xFile = await controller!.stopVideoRecording();
      setState(() {
        isRecording = false;
      });
      final String? thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: xFile.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 128,
        quality: 25,
      );
      if (thumbnailPath != null) {
        String cameraVideoThumbnail = "${thumbnailPath}_cameravideo";
        widget.onSelectMedia(cameraVideoThumbnail, isVideo: true);
      } else {
        print("Failed to generate thumbnail.");
      }
    } else {
      await controller!.startVideoRecording();
      setState(() {
        isRecording = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!controller!.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: CameraPreview(controller!),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            backgroundColor: AppColors.accentColor,
            child: Icon(Icons.camera_alt),
            onPressed: _takePicture,
          ),
          SizedBox(width: 20),
          FloatingActionButton(
            backgroundColor: AppColors.accentColor,
            child: Icon(
              Icons.videocam,
              color: isRecording ? Colors.red : null,
            ),
            onPressed: _recordVideo,
          ),
        ],
      ),
    );
  }
}

class PhotosTab extends StatelessWidget {
  final Function(
    String, {
    bool isVideo,
    bool isVideoFromPhotos,
  }) onSelectMedia;

  PhotosTab({required this.onSelectMedia});

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
    'natureTrees_thumbnail.png',
    'bunnyKids_thumbnail.png',
    'mountainDrive_thumbnail.png'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.all(10),
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
            onTap: () {
              final isVideo = _imageNames[index].endsWith('_thumbnail.png');

              if (isVideo) {
                onSelectMedia(_imageNames[index], isVideoFromPhotos: true);
              } else {
                onSelectMedia(_imageNames[index]);
              }
            },
            onDoubleTap: () {
              if (_imageNames[index].endsWith('_thumbnail.png')) {
                String videoAssetPath = 'assets/images/';
                if (_imageNames[index].endsWith('natureTrees_thumbnail.png')) {
                  videoAssetPath += 'video1.mp4';
                } else if (_imageNames[index]
                    .endsWith('bunnyKids_thumbnail.png')) {
                  videoAssetPath += 'video2.mp4';
                } else if (_imageNames[index]
                    .endsWith('mountainDrive_thumbnail.png')) {
                  videoAssetPath += 'video3.mp4';
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VideoPlayerScreen(videoAsset: videoAssetPath),
                  ),
                );
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned.fill(
                  child: Image.asset('assets/images/${_imageNames[index]}',
                      fit: BoxFit.cover),
                ),
                if (_imageNames[index].endsWith('_thumbnail.png'))
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                    ),
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 50.0,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoAsset;

  VideoPlayerScreen({required this.videoAsset});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  Future<void> initializePlayer() async {
    _controller = VideoPlayerController.asset(widget.videoAsset)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
      });
    _controller.setLooping(true);
  }

  @override
  void initState() {
    super.initState();
    initializePlayer();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Video Player',
            style: TextStyle(
              color: AppColors.textColor,
            ),
          ),
          iconTheme: IconThemeData(
            color: AppColors.iconColor,
          ),
          backgroundColor: AppColors.primaryColor,
        ),
        body: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.accentColor),
                ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.accentColor,
          onPressed: () {
            setState(() {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
