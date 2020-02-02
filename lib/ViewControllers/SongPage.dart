import 'package:flutter/material.dart';
import '../Models/Song.dart';
import '../Models/SqliteHandler.dart';
import 'dart:async';
import '../Models/Utility.dart';
import '../Views/MoreOptionsSheet.dart';
import 'package:share/share.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:SongSketch/Models/ChordData.dart';

class SongPage extends StatefulWidget {
  final Song songInEditing;

  SongPage(this.songInEditing);
  @override
  _SongPageState createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  var song_color;
  bool _isNewSong = false;
  final _titleFocus = FocusNode();
  final _contentFocus = FocusNode();

  String _titleFrominitial;
  String _contentFromInitial;
  List<String> _chordScheme;
  List<String> _chordsFromInitial;
  DateTime _lastEditedForUndo;

  var _editableSong;

  // the timer variable responsible to call persistData function every 5 seconds and cancel the timer when the page pops.
  Timer _persistenceTimer;

  final GlobalKey<ScaffoldState> _globalKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _editableSong = widget.songInEditing;
    _titleController.text = _editableSong.title;
    _contentController.text = _editableSong.content;
    song_color = _editableSong.song_color;
    _lastEditedForUndo = widget.songInEditing.date_last_edited;

    _titleFrominitial = widget.songInEditing.title;
    _contentFromInitial = widget.songInEditing.content;
    _chordsFromInitial = _editableSong.chords;
    _chordScheme = _editableSong.chords;
    if (widget.songInEditing.id == -1) {
      _isNewSong = true;
    }
    _persistenceTimer = new Timer.periodic(Duration(seconds: 5), (timer) {
      // call insert query here
      print("5 seconds passed");
      print("editable song id: ${_editableSong.id}");
      _persistData();
    });
  }

  showPicker(BuildContext context, int i) {
     Picker(
        adapter: PickerDataAdapter<String>(
          pickerdata: JsonDecoder().convert(ChordData),
          isArray: true
        ),
        hideHeader: true,
        confirmText: "OK",
        confirmTextStyle: TextStyle(color: CentralStation.accentLight),
        cancel: FlatButton(onPressed: () {
          Navigator.pop(context);
        }, child: Icon(Icons.cancel), color: CentralStation.accentLight,),
        onConfirm: (Picker picker, List value) {
          setState(() {
            _chordScheme[i] = picker.getSelectedValues().join();
          });
        }
    ).showDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        key: _globalKey,
        appBar: AppBar(
          brightness: Brightness.light,
          leading: BackButton(
            color: CentralStation.textColor,
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          actions: _archiveAction(context),
          elevation: 1,
          backgroundColor: song_color,
          title: _pageTitle(),
        ),
        body: _body(context),
      ),
      onWillPop: _readyToPop,
    );
  }

  Widget _body(BuildContext ctx) {
    return Container(
        color: song_color,
        padding: EdgeInsets.only(left: 16, right: 16, top: 12),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Center(
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    for (var i = 0; i < 4; i++)
                      RaisedButton(
                        child: Text(_chordScheme[i], style: TextStyle(color: CentralStation.textColor),),
                        onPressed: () {
                          showPicker(context, i);
                        },
                        color: CentralStation.accentLight,
                      ),   
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: TextField(
                    onChanged: (str) => {updateSongObject()},
                    maxLines: null,
                    controller: _titleController,
                    focusNode: _titleFocus,
                    style: TextStyle(
                        color: CentralStation.textColor,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                    cursorColor: CentralStation.accentLight,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Title",
                      hintStyle: TextStyle(color: CentralStation.mutedColor, fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
              ),
              Divider(
                color: CentralStation.textColor,
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(5),
//    decoration: BoxDecoration(border: Border.all(color: CentralStation.borderColor,width: 1),borderRadius: BorderRadius.all(Radius.circular(10)) ),
                  child: TextField(
                    onChanged: (str)  {
                      updateSongObject();
                    },
                    maxLines: 500, // line limit extendable later
                    controller: _contentController,
                    focusNode: _contentFocus,
                    style: TextStyle(color: CentralStation.textColor, fontSize: 20),
                    cursorColor: CentralStation.accentLight,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Lyrics",
                      hintStyle: TextStyle(color: CentralStation.mutedColor, fontWeight: FontWeight.normal)
                    ),
                  )
                )
              ),
            ],
          ),
          left: true,
          right: true,
          top: false,
          bottom: false,
        )
      );
  }

  Widget _pageTitle() {
    return Text(_editableSong.id == -1 ? "New Song" : "Edit Song", style: TextStyle(color: CentralStation.textColor),);
  }

  List<Widget> _archiveAction(BuildContext context) {
    List<Widget> actions = [];
    if (widget.songInEditing.id != -1) {
      actions.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: InkWell(
          child: GestureDetector(
            onTap: () => _undo(),
            child: Icon(
              Icons.undo,
              color: CentralStation.textColor,
            ),
          ),
        ),
      ));
    }
    actions += [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: InkWell(
          child: GestureDetector(
            onTap: () => bottomSheet(context),
            child: Icon(
              Icons.more_vert,
              color: CentralStation.textColor,
            ),
          ),
        ),
      ),
    ];
    return actions;
  }

  void bottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx) {
          return MoreOptionsSheet(
            color: song_color,
            callBackColorTapped: _changeColor,
            callBackOptionTapped: bottomSheetOptionTappedHandler,
            date_last_edited: _editableSong.date_last_edited,
          );
        });
  }

  void _persistData() {
    updateSongObject();

    if (_editableSong.content.isSongmpty) {
      var songDB = SongsDBHandler();

      if (_editableSong.id == -1) {
        Future<int> autoIncrementedId =
            songDB.insertSong(_editableSong, true); // for new song
        // set the id of the song from the database after inserting the new song so for next persisting
        autoIncrementedId.then((value) {
          _editableSong.id = value;
        });
      } else {
        songDB.insertSong(
            _editableSong, false); // for updating the existing song
      }
    }
  }

// this function will ne used to save the updated editing value of the song to the local variables as user types
  void updateSongObject() {
    _editableSong.content = _contentController.text;
    _editableSong.title = _titleController.text;
    _editableSong.song_color = song_color;
    _editableSong.chords = _chordScheme;
    print("new content: ${_editableSong.content}");
    print("same title? ${_editableSong.title == _titleFrominitial}");
    print("same content? ${_editableSong.content == _contentFromInitial}");

    if (!(_editableSong.title == _titleFrominitial &&
            _editableSong.content == _contentFromInitial) ||
        (_isNewSong) || _editableSong.chords == _chordsFromInitial) {
      // No changes to the song
      // Change last edit time only if the content of the song is mutated in compare to the song which the page was called with.
      _editableSong.date_last_edited = DateTime.now();
      print("Updating date_last_edited");
      CentralStation.updateNeeded = true;
    }
  }

  void bottomSheetOptionTappedHandler(moreOptions tappedOption) {
    print("option tapped: $tappedOption");
    switch (tappedOption) {
      case moreOptions.delete:
        {
          if (_editableSong.id != -1) {
            _deleteSong(_globalKey.currentContext);
          } else {
            _exitWithoutSaving(context);
          }
          break;
        }
      case moreOptions.share:
        {
          if (_editableSong.content.isSongmpty) {
            Share.share("${_editableSong.title}\n${_editableSong.content}");
          }
          break;
        }
    }
  }

  void _deleteSong(BuildContext context) {
    if (_editableSong.id != -1) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Are you sure?", style: TextStyle(color: CentralStation.darkColor),),
              content: Text("This song will be deleted permanently", style: TextStyle(color: CentralStation.darkColor)),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      _persistenceTimer.cancel();
                      var songDB = SongsDBHandler();
                      Navigator.of(context).pop();
                      songDB.deleteSong(_editableSong);
                      CentralStation.updateNeeded = true;
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: Text("Yes"),
                    textColor: CentralStation.accentLight,
                ),
                FlatButton(
                    onPressed: () => {Navigator.of(context).pop()},
                    child: Text("No"),
                    textColor: CentralStation.accentLight,
                  ),
                ],
            );
          });
    }
  }

  void _changeColor(Color newColorSelected) {
    print("song color changed");
    setState(() {
      song_color = newColorSelected;
      _editableSong.song_color = newColorSelected;
    });
    _persistColorChange();
    CentralStation.updateNeeded = true;
  }

  void _persistColorChange() {
    if (_editableSong.id != -1) {
      var songDB = SongsDBHandler();
      _editableSong.song_color = song_color;
      songDB.insertSong(_editableSong, false);
    }
  }

  Future<bool> _readyToPop() async {
    _persistenceTimer.cancel();
    //show saved toast after calling _persistData function.

    _persistData();
    return true;
  }

  void _exitWithoutSaving(BuildContext context) {
    _persistenceTimer.cancel();
    CentralStation.updateNeeded = false;
    Navigator.of(context).pop();
  }

  void _undo() {
    _titleController.text = _titleFrominitial; // widget.songInEditing.title;
    _contentController.text =
        _contentFromInitial; // widget.songInEditing.content;
    _editableSong.date_last_edited =
        _lastEditedForUndo; // widget.songInEditing.date_last_edited;
  }
}
