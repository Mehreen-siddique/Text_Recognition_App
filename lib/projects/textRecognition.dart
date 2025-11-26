import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart'
    show ImagePicker, ImageSource, XFile;

class textRecognition extends StatefulWidget {
  const textRecognition({super.key});

  @override
  State<textRecognition> createState() => _textRecognitionState();
}

class _textRecognitionState extends State<textRecognition> {
  File? _image;
  late ImagePicker picker;
  late InputImage inputImage;
  late TextRecognizer textRecognizer;
  late RecognizedText recognizedText;
   String resultText = '';

  @override
  void initState() {
    // TODO: implement initState
    picker = ImagePicker();
    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    super.initState();
  }

  chooseImageFromGallery() async {
    XFile? file = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = File(file!.path);
      inputImage = InputImage.fromFile(_image!);
      TextDetector();
    });
  }

  chooseImageFromCamera() async {
    XFile? file = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = File(file!.path);
      inputImage = InputImage.fromFile(_image!);
      TextDetector();
    });
  }

  TextDetector() async {
     recognizedText = await textRecognizer.processImage(
      inputImage,
    );

    String text = recognizedText.text;

    setState(() {
      resultText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.grey[300],
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 250,
                width: 250,
                padding: EdgeInsets.only(left: 30, top: 10),
                margin: EdgeInsets.only(left: 30),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/1.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    // textAlign: TextAlign.center,
                    resultText,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              Container(
                height: 200,
                width: 200,
                margin: EdgeInsets.only(top: 100, left: 70),
                child: Stack(
                  children: [
                    Center(child: Image(image: AssetImage('images/2.jpg'))),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: chooseImageFromGallery,
                      onLongPress: chooseImageFromCamera,

                      child: Container(
                       // margin: EdgeInsets.only(left: 25, top: 20),

                        child:
                            _image != null
                                ? Image.file(
                                  _image!,
                                  fit: BoxFit.fill,
                                  height: 250,
                                  width: 300,
                                )
                                : Container(
                                  child: Center(
                                    child: Icon(Icons.camera_alt, size: 40),
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
