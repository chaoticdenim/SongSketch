import 'package:flutter/material.dart';
import 'StaggeredView.dart';
import '../Models/Song.dart';
import 'SongPage.dart';
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

  var songsViewType ;
  @override void initState() {
    songsViewType = viewType.List;
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
        onPressed: () => _newSongTapped(context),
        child: Icon(Icons.add_circle),
        backgroundColor: CentralStation.accentLight,
      ),
    );

  }

  Widget _body() {
    print(songsViewType);
    return Container(child: StaggeredGridPage(songsViewType: songsViewType,));
  }

  void _newSongTapped(BuildContext ctx) {
    // "-1" id indicates the song is not new
    var emptySong = new Song(-1, "", "", DateTime.now(), DateTime.now(), CentralStation.darkColor, ["A", "D", "E", "A"]);
    Navigator.push(ctx,MaterialPageRoute(builder: (ctx) => SongPage(emptySong)));
  }

  void _toggleViewType(){
    setState(() {
      CentralStation.updateNeeded = true;
      if(songsViewType == viewType.List)
        {
          songsViewType = viewType.Staggered;

        } else {
        songsViewType = viewType.List;
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
              songsViewType == viewType.List ?  Icons.developer_board : Icons.view_headline,
              color: CentralStation.textColor,
            ),
          ),
        ),
      ),
    ];
}


}
