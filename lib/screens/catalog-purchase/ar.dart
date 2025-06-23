import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class DebugOptions extends StatefulWidget {
  const DebugOptions({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<DebugOptions> createState() => _DebugOptionsState();
}

class _DebugOptionsState extends State<DebugOptions> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Model Viewer')),
        body: const ModelViewer(
          backgroundColor: Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
          //src: 'https://smartcart-bucket.s3.amazonaws.com/public/products/3d_models/panasonic_nn-sn755s_microwave.glb',
          src: 'assets/panasonic_nn-sn755s_microwave.glb',
          alt: 'Microondas',
          ar: true,
          arModes: ['scene-viewer'],
          autoRotate: true,
          disableZoom: false,
        ),
      ),
    );
  }
}