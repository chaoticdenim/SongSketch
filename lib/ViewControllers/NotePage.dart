import 'package:flutter/material.dart';
import '../Models/Note.dart';
import '../Models/SqliteHandler.dart';
import 'dart:async';
import '../Models/Utility.dart';
import '../Views/MoreOptionsSheet.dart';
import 'package:share/share.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:SongSketch/Models/ChordData.dart';

class NotePage extends StatefulWidget {
  final Note noteInEditing;

  NotePage(this.noteInEditing);
  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  var note_color;
  bool _isNewNote = false;
  final _titleFocus = FocusNode();
  final _contentFocus = FocusNode();

  String _titleFrominitial;
  String _contentFromInitial;
  List<String> _chordScheme;
  List<String> _chordsFromInitial;
  DateTime _lastEditedForUndo;

  var _editableNote;

  // the timer variable responsible to call persistData function every 5 seconds and cancel the timer when the page pops.
  Timer _persistenceTimer;

  final GlobalKey<ScaffoldState> _globalKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _editableNote = widget.noteInEditing;
    _titleController.text = _editableNote.title;
    _contentController.text = _editableNote.content;
    note_color = _editableNote.note_color;
    _lastEditedForUndo = widget.noteInEditing.date_last_edited;

    _titleFrominitial = widget.noteInEditing.title;
    _contentFromInitial = widget.noteInEditing.content;
    _chordsFromInitial = _editableNote.chords;
    _chordScheme = _editableNote.chords;
    if (widget.noteInEditing.id == -1) {
      _isNewNote = true;
    }
    _persistenceTimer = new Timer.periodic(Duration(seconds: 5), (timer) {
      // call insert query here
      print("5 seconds passed");
      print("editable note id: ${_editableNote.id}");
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
          backgroundColor: note_color,
          title: _pageTitle(),
        ),
        body: _body(context),
      ),
      onWillPop: _readyToPop,
    );
  }

  Widget _body(BuildContext ctx) {
    return Container(
        color: note_color,
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
                    onChanged: (str) => {updateNoteObject()},
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
                      updateNoteObject();
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
    return Text(_editableNote.id == -1 ? "New Song" : "Edit Song", style: TextStyle(color: CentralStation.textColor),);
  }

  List<Widget> _archiveAction(BuildContext context) {
    List<Widget> actions = [];
    if (widget.noteInEditing.id != -1) {
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
            color: note_color,
            callBackColorTapped: _changeColor,
            callBackOptionTapped: bottomSheetOptionTappedHandler,
            date_last_edited: _editableNote.date_last_edited,
          );
        });
  }

  void _persistData() {
    updateNoteObject();

    if (_editableNote.content.isNotEmpty) {
      var noteDB = NotesDBHandler();

      if (_editableNote.id == -1) {
        Future<int> autoIncrementedId =
            noteDB.insertNote(_editableNote, true); // for new note
        // set the id of the note from the database after inserting the new note so for next persisting
        autoIncrementedId.then((value) {
          _editableNote.id = value;
        });
      } else {
        noteDB.insertNote(
            _editableNote, false); // for updating the existing note
      }
    }
  }

// this function will ne used to save the updated editing value of the note to the local variables as user types
  void updateNoteObject() {
    _editableNote.content = _contentController.text;
    _editableNote.title = _titleController.text;
    _editableNote.note_color = note_color;
    _editableNote.chords = _chordScheme;
    print("new content: ${_editableNote.content}");
    print("same title? ${_editableNote.title == _titleFrominitial}");
    print("same content? ${_editableNote.content == _contentFromInitial}");

    if (!(_editableNote.title == _titleFrominitial &&
            _editableNote.content == _contentFromInitial) ||
        (_isNewNote) || _editableNote.chords == _chordsFromInitial) {
      // No changes to the note
      // Change last edit time only if the content of the note is mutated in compare to the note which the page was called with.
      _editableNote.date_last_edited = DateTime.now();
      print("Updating date_last_edited");
      CentralStation.updateNeeded = true;
    }
  }

  void bottomSheetOptionTappedHandler(moreOptions tappedOption) {
    print("option tapped: $tappedOption");
    switch (tappedOption) {
      case moreOptions.delete:
        {
          if (_editableNote.id != -1) {
            _deleteNote(_globalKey.currentContext);
          } else {
            _exitWithoutSaving(context);
          }
          break;
        }
      case moreOptions.share:
        {
          if (_editableNote.content.isNotEmpty) {
            Share.share("${_editableNote.title}\n${_editableNote.content}");
          }
          break;
        }
    }
  }

  void _deleteNote(BuildContext context) {
    if (_editableNote.id != -1) {
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
                      var noteDB = NotesDBHandler();
                      Navigator.of(context).pop();
                      noteDB.deleteNote(_editableNote);
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
    print("note color changed");
    setState(() {
      note_color = newColorSelected;
      _editableNote.note_color = newColorSelected;
    });
    _persistColorChange();
    CentralStation.updateNeeded = true;
  }

  void _persistColorChange() {
    if (_editableNote.id != -1) {
      var noteDB = NotesDBHandler();
      _editableNote.note_color = note_color;
      noteDB.insertNote(_editableNote, false);
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
    _titleController.text = _titleFrominitial; // widget.noteInEditing.title;
    _contentController.text =
        _contentFromInitial; // widget.noteInEditing.content;
    _editableNote.date_last_edited =
        _lastEditedForUndo; // widget.noteInEditing.date_last_edited;
  }
}
