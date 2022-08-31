import 'dart:io';

import 'package:fast_qr_reader_view/fast_qr_reader_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'Api.dart';
import 'main.dart';

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => new _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  QRReaderController controller;

  @override
  void initState() {
    super.initState();
    availableCameras().then((value) => onUpdate(value));
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  onUpdate(List<CameraDescription> cameras){

    controller = new QRReaderController(cameras[0], ResolutionPreset.medium, [CodeFormat.qr], (dynamic value){
      print(value); // the result!
      if(value.isNotEmpty){
        Navigator.of(context).pop();
        client.getProdukt(value).then((value) => onProduktFound(value,context));
      }
    });
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      controller.startScanning();
    });
  }
  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return new Container();
    }
    return new AspectRatio(
        aspectRatio:
        controller.value.aspectRatio,
        child: new QRReaderPreview(controller));
  }
  onProduktFound(Produkt value, BuildContext context) {
    detteProdukt = value;
    Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              ProductEditEnhance(),
        ));
  }
}
