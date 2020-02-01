import 'package:SongSketch/ViewControllers/PreviewPage.dart';
import 'package:flutter/material.dart';
import 'StaggeredView.dart';
import '../Models/Note.dart';
import 'NotePage.dart';
import '../Models/Utility.dart';

enum viewType {
  List,
  Staggered
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  var notesViewType ;
  @override void initState() {
    notesViewType = viewType.List;
  }

  @override
  Widget build(BuildContext context) {

    return
       Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(brightness: Brightness.dark,
        actions: _appBarActions(),
        elevation: 1,
        backgroundColor: CentralStation.darkerColor,
        centerTitle: true,
        title: Text("Song Sketches", style: TextStyle(color: CentralStation.textColor)),
      ),
      body: SafeArea(child:   _body(), right: true, left:  true, top: true, bottom: true,),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _newNoteTapped(context),
        child: Icon(Icons.add_circle),
        backgroundColor: CentralStation.accentLight,
      ),
    );

  }

  Widget _body() {
    print(notesViewType);
    return Container(child: StaggeredGridPage(notesViewType: notesViewType,));
  }

  void _newNoteTapped(BuildContext ctx) {
    // "-1" id indicates the note is not new
    var emptyNote = new Note(-1, "", "", DateTime.now(), DateTime.now(), CentralStation.darkColor, ["A", "D", "E", "A"]);
    Navigator.push(ctx,MaterialPageRoute(builder: (ctx) => NotePage(emptyNote)));
  }

  void _toggleViewType(){
    setState(() {
      CentralStation.updateNeeded = true;
      if(notesViewType == viewType.List)
        {
          notesViewType = viewType.Staggered;

        } else {
        notesViewType = viewType.List;
      }

    });
  }

List<Widget> _appBarActions() {

    return [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: InkWell(
          child: GestureDetector(
            onTap: () => _toggleViewType() ,
            child: Icon(
              notesViewType == viewType.List ?  Icons.developer_board : Icons.view_headline,
              color: CentralStation.textColor,
            ),
          ),
        ),
      ),
    ];
}


}
