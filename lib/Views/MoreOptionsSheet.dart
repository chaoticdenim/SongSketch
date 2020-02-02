import 'package:flutter/material.dart';

import 'ColorSlider.dart';
import '../Models/Utility.dart';

enum moreOptions { delete, share }

class MoreOptionsSheet extends StatefulWidget {
  final Color color;
  final DateTime date_last_edited;
  final void Function(Color) callBackColorTapped;

  final void Function(moreOptions) callBackOptionTapped;

  const MoreOptionsSheet(
      {Key key,
      this.color,
      this.date_last_edited,
      this.callBackColorTapped,
      this.callBackOptionTapped})
      : super(key: key);

  @override
  _MoreOptionsSheetState createState() => _MoreOptionsSheetState();
}

class _MoreOptionsSheetState extends State<MoreOptionsSheet> {
  var song_color;

  @override
  void initState() {
    song_color = widget.color;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: this.song_color,
      child: new Wrap(
        children: <Widget>[
          new ListTile(
              leading: new Icon(Icons.delete, color: CentralStation.accentLight,),
              title: new Text('Delete permanently', style: TextStyle(color: CentralStation.textColor),),
              onTap: () {
                Navigator.of(context).pop();
                widget.callBackOptionTapped(moreOptions.delete);
              }),
          new ListTile(
              leading: new Icon(Icons.share, color: CentralStation.accentLight,),
              title: new Text('Share', style: TextStyle(color: CentralStation.textColor),),
              onTap: () {
                Navigator.of(context).pop();
                widget.callBackOptionTapped(moreOptions.share);
              }),
          new Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: SizedBox(
              height: 44,
              width: MediaQuery.of(context).size.width,
              child: ColorSlider(
                callBackColorTapped: _changeColor,
                // call callBack from songPage here
                songColor: song_color, // take color from local variable
              ),
            ),
          ),
          new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 44,
                child: Center(
                    child: Text(CentralStation.stringForDatetime(
                        widget.date_last_edited), style: TextStyle(color: CentralStation.textColor),)),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          new ListTile()
        ],
      ),
    );
  }

  void _changeColor(Color color) {
    setState(() {
      this.song_color = color;
      widget.callBackColorTapped(color);
    });
  }
}
