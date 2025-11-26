import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class imageLabeling extends StatefulWidget {
  const imageLabeling({super.key});

  @override
  State<imageLabeling> createState() => _imageLabelingState();
}

class _imageLabelingState extends State<imageLabeling> {

  File? _image;
  late final file;
  String resultText = "";
  late ImagePicker picker;
  late final inputimage;
  late final ImageLabelerOptions options;
  late final imageLabeler;
  bool scanning = true;


  @override
  void initState(){
    super.initState();
    picker = ImagePicker();
    options = ImageLabelerOptions(confidenceThreshold: 0.5);
    imageLabeler = ImageLabeler(options: options);

  }


  void  chooseimage() async{
    XFile? selected_image = await picker.pickImage(source: ImageSource.gallery);
    if(selected_image == null) return;
    file = File(selected_image.path);
    inputimage = InputImage.fromFile(file);

    // options = ImageLabelerOptions(confidenceThreshold: 0.5);
    // imageLabeler = ImageLabeler(options: options);


    final List<ImageLabel> labels = await imageLabeler.processImage(inputimage);

    // --- Process the results ---

    for (ImageLabel label in labels) {
      final String text = label.label;
      final double confidence = label.confidence;
      resultText += "$text: ${(confidence * 100).toStringAsFixed(0)}%\n";


    }
    setState(() {
      scanning = false;
    });

    // Don't forget to close the labeler to free up resources
    imageLabeler.close();

    setState((){
      _image = File(selected_image!.path
      );
      // InputImage.fromFile(_image!); //input image is object of mlKit

    });

  }

  imageFromCamera() async{
    XFile? selected_image = await picker.pickImage(source: ImageSource.camera);

    final List<ImageLabel> labels = await imageLabeler.processImage(inputimage);

    // --- Process the results ---

    for (ImageLabel label in labels) {
      final String text = label.label;
      final double confidence = label.confidence;
      resultText += "$text: ${(confidence * 100).toStringAsFixed(0)}%\n";


    }
    setState(() {
      scanning = false;
    });

    // Don't forget to close the labeler to free up resources
    imageLabeler.close();
    setState(() {
      _image = File(selected_image!.path);
      InputImage.fromFile(_image!); //input image is object of mlKit

    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink,
          title: Text("Image labeling"),
          centerTitle: true,
        ),

        body: Center(
          child: ListView(
            children: [
              _image ==null ? Container(
                  height: 200,
                  width: 200,
                  child: Icon(
                    Icons.image_outlined, size: 180,)
              )
                  : Container(
                  height: 200,
                  width: 300,
                  child: Image.file(_image!)),
              SizedBox(
                width: 200,
                child: ElevatedButton(onPressed: (){
                  chooseimage();
                },
                    onLongPress: (){

                      imageFromCamera();
                    },

                    child: Text("Select Image")),
              ),
              SizedBox(height: 10,),

              scanning?
              Padding(padding: EdgeInsets.only(top: 60),
                  child: Center(
                      child: SpinKitThreeBounce(
                        color: Colors.black,

                      )
                  )

              ):
              Center(
                child: AnimatedTextKit(
                  isRepeatingAnimation: false,
                  animatedTexts: [
                    TypewriterAnimatedText(
                        resultText,
                        textAlign: TextAlign.center
                    )
                  ],

                ),
              )
            ],
          ),

        ),
      ),
    );
  }
}