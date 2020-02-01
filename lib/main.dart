import 'package:SongSketch/Models/Utility.dart';
import 'package:flutter/material.dart';
import 'ViewControllers/HomePage.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SongSketch',
      home: HomePage(),

    );
  }
}
