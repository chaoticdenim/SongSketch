import 'package:SongSketch/ViewControllers/PreviewPage.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../ViewControllers/NotePage.dart';
import '../Models/Note.dart';
import '../Models/Utility.dart';

class MyStaggeredTile extends StatefulWidget {
  final Note note;
  MyStaggeredTile(this.note);
  @override
  _MyStaggeredTileState createState() => _MyStaggeredTileState();
}

class _MyStaggeredTileState extends State<MyStaggeredTile> {
  String _content;
  double _fontSize;
  double _chordsFontSize;
  Color tileColor;
  String title;
  List<String> chords;

  @override
  Widget build(BuildContext context) {
    _content = widget.note.content;
    _fontSize = _determineFontSizeForContent();
    tileColor = widget.note.note_color;
    title = widget.note.title;
    chords = widget.note.chords;
    _chordsFontSize = _determineChordFontSize();

    return GestureDetector(
      onTap: () => _noteTapped(context),
      child: Container(
        decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            boxShadow: [ 
              new BoxShadow(
                color: Colors.black38,
                blurRadius: 20.0
              )
            ]
          ),
        padding: EdgeInsets.all(8),
        child: constructChild(),
      ),
    );
  }

  void _noteTapped(BuildContext ctx) {
    CentralStation.updateNeeded = false;
    Navigator.push(
        ctx, MaterialPageRoute(builder: (ctx) => PreviewPage(widget.note)));
  }

  Widget constructChild() {
    List<Widget> contentsOfTiles = [];

    if (widget.note.title.length != 0) {
      contentsOfTiles.add(
        AutoSizeText(
          title,
          style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold, color: CentralStation.textColor),
          maxLines: widget.note.title.length == 0 ? 1 : 3,
          textScaleFactor: 1.5,
        ),
      );
      contentsOfTiles.add(
        Divider(
          color: Colors.transparent,
          height: 6,
        ),
      );
    }

    contentsOfTiles.add(AutoSizeText(
      _content,
      style: TextStyle(fontSize: _fontSize, color: CentralStation.textColor),
      maxLines: 10,
      textScaleFactor: 1.5,
    ));

    contentsOfTiles.add(
      Divider(
        color: Colors.transparent,
        height: 6,
      ),
    );

    contentsOfTiles.add(
      Row(
        children: <Widget>[
          for (var chord in chords)
          Container(
            child: Text(
              chord,
              style: TextStyle(fontSize: _chordsFontSize, fontWeight: FontWeight.w300, color: CentralStation.textColor),
            ),
            margin: EdgeInsets.all(3),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              color: CentralStation.accentLight,
            ),
          )
        ],
      )
    );

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: contentsOfTiles);
  }

  double _determineChordFontSize() {
    int chordsLength = chords.join().length;
    double chordFontSize = 20;
    if (chordsLength > 20) {
      chordFontSize = 8;
    } else if (chordsLength > 15) {
      chordFontSize = 9;
    } else if (chordsLength > 10) {
      chordFontSize = 12;
    } else if (chordsLength > 5) {
      chordFontSize = 14;
    } else {
      chordFontSize = 16;
    }

    print("chords: $chordsLength");
    print("font: $chordFontSize");

    return chordFontSize;
  }

  double _determineFontSizeForContent() {
    int charCount = _content.length + widget.note.title.length;
    double fontSize = 20;
    if (charCount > 110) {
      fontSize = 12;
    } else if (charCount > 80) {
      fontSize = 14;
    } else if (charCount > 50) {
      fontSize = 16;
    } else if (charCount > 20) {
      fontSize = 18;
    }
    return fontSize;
  }
}
