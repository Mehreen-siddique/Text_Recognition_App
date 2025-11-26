import 'package:flutter/material.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Activity>? _activitySubscription;
  String _currentActivity = "Initializing...";
  String _statusMessage = "Starting...";
  int _detectionCount = 0;

  @override
  void initState() {
    super.initState();
    _startActivityDetection();
  }

  Future<void> _startActivityDetection() async {
    try {
      print('🔍 Starting activity detection...');
      // Check permission - returns ActivityPermission enum
      ActivityPermission permission = await FlutterActivityRecognition.instance.checkPermission();
      print('📋 Permission status: $permission');

      if (permission == ActivityPermission.PERMANENTLY_DENIED) {
        print('❌ Permission permanently denied');
        setState(() {
          _currentActivity = "Permission Permanently Denied";
        });
        return;
      } else if (permission == ActivityPermission.DENIED) {
        print('⚠️ Permission denied, requesting...');
        // Request permission
        permission = await FlutterActivityRecognition.instance.requestPermission();
        print('📋 Permission request result: $permission');
        if (permission != ActivityPermission.GRANTED) {
          print('❌ Permission still denied after request');
          setState(() {
            _currentActivity = "Permission Denied";
          });
          return;
        }
      }

      print('✅ Permission granted, starting activity stream...');

      setState(() {
        _currentActivity = "Waiting for detection...";
        _statusMessage = "Stream active, move your device";
      });

      // Start listening to activity stream
      _activitySubscription = FlutterActivityRecognition.instance.activityStream
          .handleError((error) {
        print('❌ Activity stream error: $error');
        setState(() {
          _currentActivity = "Error: $error";
          _statusMessage = "Stream error occurred";
        });
      }).listen((Activity activity) {
        _detectionCount++;
        print('🎯 Activity detected: ${activity.type} (confidence: ${activity.confidence}%)');
        setState(() {
          // Extract activity type properly
          String activityType = activity.type.toString().split('.').last;
          _currentActivity = activityType;
          _statusMessage = "Confidence: ${activity.confidence}% | Count: $_detectionCount";
        });
      });
      print('👂 Listening to activity stream...');
    } catch (e) {
      print('💥 Exception in _startActivityDetection: $e');
      setState(() {
        _currentActivity = "Error: $e";
      });
    }
  }

  @override
  void dispose() {
    _activitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Real-time Activity Detection")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Current Activity:",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 10),
                Text(
                  _currentActivity,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  _statusMessage,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "💡 Tip: Walk around or shake your device to trigger detection. It may take 10-60 seconds to start.",
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
