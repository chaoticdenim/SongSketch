import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class CentralStation {
  static bool _updateNeeded ;

  static final textColor = Color(0xFFD8DCE7);
  static final mutedColor = Color(0xFF7F8187);
  static final darkColor = Color(0xFF373c44);
  static final darkerColor = Color(0xFF1F2128);
  static final accentLight = Color(0xFF6A77FC);
  static final accent = Color(0xFF383E5F);

  static init() {
    if (_updateNeeded == null)
      _updateNeeded = true;
  }
  static bool get updateNeeded {
    init();
    if (_updateNeeded) {
      return true;
    } else {
      return false;
    }
  }

  static set updateNeeded(value){
    _updateNeeded = value;
}

  static String stringForDatetime(DateTime dt){

    var dtInLocal = dt.toLocal();
    //DateTime.fromMillisecondsSinceEpoch( 1490489845  * 1000).toLocal(); //year:  1490489845 //>day: 1556152819  //month:  1553561845  //<day: 1556174419
    var now = DateTime.now().toLocal();
    var dateString = "Edited ";

    var diff = now.difference(dtInLocal);

    if(now.day == dtInLocal.day){                                               // creates format like: 12:35 PM,
      var todayFormat = DateFormat("h:mm a");
      dateString += todayFormat.format(dtInLocal);
    } else if ( (diff.inDays) == 1 || (diff.inSeconds < 86400 && now.day != dtInLocal.day)) {
        var yesterdayFormat = DateFormat("h:mm a");
        dateString +=  "Yesterday, " + yesterdayFormat.format(dtInLocal) ;
    } else if(now.year == dtInLocal.year && diff.inDays > 1){
        var monthFormat = DateFormat("MMM d");
        dateString +=  monthFormat.format(dtInLocal);
    } else {
        var yearFormat = DateFormat("MMM d y");
        dateString += yearFormat.format(dtInLocal);
    }

    return dateString;
  }

}