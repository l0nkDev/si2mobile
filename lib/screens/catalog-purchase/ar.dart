import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> _cameras;

class DebugOptions extends StatefulWidget {
  const DebugOptions({
    super.key,
    this.width,
    this.height,
    required this.itemurl,
  });

  final double? width;
  final double? height;
  final String itemurl;

  @override
  State<DebugOptions> createState() => _DebugOptionsState();
}

class _DebugOptionsState extends State<DebugOptions> {
  late CameraController controller;
  bool cameraInit = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initCams();
  }

  void initCams() async {
    _cameras = await availableCameras();
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {cameraInit = true;});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            if (cameraInit) CameraPreview(controller),
            ModelViewer(
              //src: 'https://smartcart-bucket.s3.amazonaws.com/public/products/3d_models/panasonic_nn-sn755s_microwave.glb',
              src: widget.itemurl,
              alt: '',
              ar: false,
              arModes: ['scene-viewer'],
              disableZoom: false,
            ),
          ]
        ),
      ),
    );
  }
}