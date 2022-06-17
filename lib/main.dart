import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _imageFileList;
  Future<void> _imagePicker() async {
    final List<XFile>? pickedFileList = await _picker.pickMultiImage(
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 100,
    );
    setState(() {
      _imageFileList = pickedFileList;
    });

    // for (int i = 1; i <= _imageFileList.length!; i++) {
    //   File s = await getImageFileFromAssets('$i.jpeg');
    //   imageFiles.add(s);
    // }
    final img.JpegDecoder decoder = img.JpegDecoder();
    final List<img.Image> images = [];
    for (var imgFile in _imageFileList!) {
      Uint8List data = await imgFile.readAsBytes();
      img.Image? temp = decoder.decodeImage(data);
      images.add(temp!);
    }
    List<int>? gifData = generateGIF(images);
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath = tempPath + '/file_01.gif';
    File x = await File(filePath).writeAsBytes(Uint8List.fromList(gifData!));
    final result =
        await ImageGallerySaver.saveFile(x.path, isReturnPathOfIOS: true);
    print(result);
    print("End of here");
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Load gif',
            ),
            Text(
              '',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _imagePicker,
        tooltip: 'Pick image',
        child: const Icon(Icons.add),
      ),
    );
  }

  List<int>? generateGIF(Iterable<img.Image> images) {
    final img.Animation animation = img.Animation();
    for (img.Image image in images) {
      animation.addFrame(image);
    }
    return img.encodeGifAnimation(animation);
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }
}
