import 'package:flutter/material.dart';
import 'package:practice/projects/textRecognition.dart';


void main(){
  runApp(MainFile());
}

class MainFile extends StatefulWidget {
  const MainFile({super.key});


  @override
  State<MainFile> createState() => _MainFileState();
}

class _MainFileState extends State<MainFile> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: textRecognition(),
    );
  }
}
