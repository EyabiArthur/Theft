import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(TheftApp());
}

class TheftApp extends StatelessWidget {
  const TheftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Smart Theft Detector",
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: TheftHome(),
    );
  }
}

class TheftHome extends StatefulWidget {
  const TheftHome({super.key});

  @override
  _TheftHomeState createState() => _TheftHomeState();
}

class _TheftHomeState extends State<TheftHome> {
  bool isArmed = false;
  String status = "System Disarmed";

  final AudioPlayer player = AudioPlayer();
  StreamSubscription? subscription;

  double lastX = 0, lastY = 0, lastZ = 0;

  void startDetection() {
    subscription = accelerometerEvents.listen((event) {
      double dx = (event.x - lastX).abs();
      double dy = (event.y - lastY).abs();
      double dz = (event.z - lastZ).abs();

      if (dx > 5 || dy > 5 || dz > 5) {
        triggerAlarm();
      }

      lastX = event.x;
      lastY = event.y;
      lastZ = event.z;
    });
  }

  void stopDetection() {
    subscription?.cancel();
    player.stop();
  }

  void triggerAlarm() async {
    setState(() {
      status = "⚠️ Movement Detected!";
    });

    await player.play(AssetSource('alarm.mp3'));
  }

  void toggleSystem() {
    setState(() {
      isArmed = !isArmed;
      status = isArmed ? "System Armed" : "System Disarmed";
    });

    if (isArmed) {
      startDetection();
    } else {
      stopDetection();
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Smart Theft Detector"),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.security,
            size: 100,
            color: isArmed ? Colors.red : Colors.grey,
          ),

          SizedBox(height: 20),

          Text(
            status,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 40),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isArmed ? Colors.grey : Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            onPressed: toggleSystem,
            child: Text(
              isArmed ? "DISARM" : "ARM SYSTEM",
              style: TextStyle(fontSize: 18),
            ),
          ),

          SizedBox(height: 20),

          Text(
            "Place your phone still.\nIf moved → Alarm triggers 🚨",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

