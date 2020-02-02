import 'package:flutter/material.dart';
import '../Models/Utility.dart';
import 'package:SongSketch/Models/Song.dart';
import 'SongPage.dart';

class PreviewPage extends StatefulWidget {
  final Song songToPreview;

  PreviewPage(this.songToPreview);
  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  String text;
  String title;
  Color color;
  List<String> chords;
  Song song;
  @override void initState() {
    text = widget.songToPreview.content;
    title = widget.songToPreview.title;
    color = widget.songToPreview.song_color;
    chords = widget.songToPreview.chords;
    song = widget.songToPreview;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        brightness: Brightness.light,
          leading: BackButton(
            color: CentralStation.textColor,
          ),
        backgroundColor: color,
        elevation: 1,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
              child: InkWell(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SongPage(song))),
                  child: Icon(
                    Icons.edit,
                    color: CentralStation.textColor,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        color: color,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                makeText(text)                
              ],
            )
          ),
        )
      ),
    );
  }

  makeText(text) {
    List<String> lines = text.split("\n").where((s) => !s.isEmpty).toList();
    List<TextSpan> list = new List<TextSpan>();

    for (var i=0; i < lines.length; i++) {
      list.add(TextSpan(
        text: "${chords[i%chords.length]}",
        style: TextStyle(
          color: CentralStation.accentLight,
          fontWeight: FontWeight.bold,
          fontSize: 30
        )
      ));

      list.add(TextSpan(
        text: " ${lines[i]}\n",
        style: TextStyle(
          color: CentralStation.textColor,
          fontSize: 20
        )
      ));
    }

    return RichText(
      text: TextSpan(
        text: "\n",
        style: TextStyle(
          color: CentralStation.accentLight,
          fontSize: 20,
        ),
        children: list
      )
    );
  }
}
