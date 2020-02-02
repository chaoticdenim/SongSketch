import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../Models/Song.dart';
import '../Models/SqliteHandler.dart';
import '../Models/Utility.dart';
import '../Views/StaggeredTiles.dart';
import 'HomePage.dart';

class StaggeredGridPage extends StatefulWidget {
  final songsViewType;
  const StaggeredGridPage({Key key, this.songsViewType}) : super(key: key);
  @override
  _StaggeredGridPageState createState() => _StaggeredGridPageState();
}

class _StaggeredGridPageState extends State<StaggeredGridPage> {
  var songDB = SongsDBHandler();
  List<Map<String, dynamic>> _allSongsInQueryResult = [];
  viewType songsViewType;

  @override
  void initState() {
    super.initState();
    this.songsViewType = widget.songsViewType;
  }

  @override
  void setState(fn) {
    super.setState(fn);
    this.songsViewType = widget.songsViewType;
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey _stagKey = GlobalKey();

    print("update needed?: ${CentralStation.updateNeeded}");
    if (CentralStation.updateNeeded) {
      retrieveAllSongsFromDatabase();
    }
    return Container(
      color: CentralStation.darkerColor,
        child: Padding(
      padding: _paddingForView(context),
      child: new StaggeredGridView.count(
        key: _stagKey,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        crossAxisCount: _colForStaggeredView(context),
        children: List.generate(_allSongsInQueryResult.length, (i) {
          return _tileGenerator(i);
        }),
        staggeredTiles: _tilesForView(),
      ),
    ));
  }

  int _colForStaggeredView(BuildContext context) {
    if (widget.songsViewType == viewType.List) return 1;
    // for width larger than 600 on grid mode, return 3 irrelevant of the orientation to accommodate more songs horizontally
    return MediaQuery.of(context).size.width > 500 ? 3 : 2;
  }

  List<StaggeredTile> _tilesForView() {
    // Generate staggered tiles for the view based on the current preference.
    return List.generate(_allSongsInQueryResult.length, (index) {
      return StaggeredTile.fit(1);
    });
  }

  EdgeInsets _paddingForView(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double padding;
    double top_bottom = 8;
    if (width > 500) {
      padding = (width) * 0.05; // 5% padding of width on both side
    } else {
      padding = 8;
    }
    return EdgeInsets.only(
        left: padding, right: padding, top: top_bottom, bottom: top_bottom);
  }

  MyStaggeredTile _tileGenerator(int i) {
    return MyStaggeredTile(Song(
        _allSongsInQueryResult[i]["id"],
        _allSongsInQueryResult[i]["title"] == null
            ? ""
            : utf8.decode(_allSongsInQueryResult[i]["title"]),
        _allSongsInQueryResult[i]["content"] == null
            ? ""
            : utf8.decode(_allSongsInQueryResult[i]["content"]),
        DateTime.fromMillisecondsSinceEpoch(
            _allSongsInQueryResult[i]["date_created"] * 1000),
        DateTime.fromMillisecondsSinceEpoch(
            _allSongsInQueryResult[i]["date_last_edited"] * 1000),
        Color(_allSongsInQueryResult[i]["song_color"]),
        jsonDecode(_allSongsInQueryResult[i]["chords"])["sequence"].cast<String>()
        ));
  }

  void retrieveAllSongsFromDatabase() {
    // queries for all the songs from the database ordered by latest edited song. excludes archived songs.
    var _testData = songDB.selectAllSongs();
    _testData.then((value) {
      setState(() {
        this._allSongsInQueryResult = value;
        CentralStation.updateNeeded = false;
      });
    });
  }
}
