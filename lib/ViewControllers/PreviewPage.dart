import 'package:flutter/material.dart';
import 'package:SongSketch/Models/Note.dart';

class PreviewPage extends StatefulWidget {
  final Note noteToPreview;

  PreviewPage(this.noteToPreview);
  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  String text;
  String title;
  Color color;
  @override void initState() {
    text = widget.noteToPreview.content;
    title = widget.noteToPreview.title;
    color = widget.noteToPreview.note_color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        brightness: Brightness.light,
          leading: BackButton(
            color: Colors.black,
          ),
        backgroundColor: color,
        elevation: 1,
      ),
      body: Center(
        child: Text(
          text
        ),
      ),
    );
  }
}