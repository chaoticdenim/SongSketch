import 'dart:convert';
import 'package:flutter/material.dart';

class Song {
  int id;
  String title;
  String content;
  DateTime date_created;
  DateTime date_last_edited;
  Color song_color;
  int is_archived = 0;
  List<String> chords;

  Song(this.id, this.title, this.content, this.date_created,
      this.date_last_edited, this.song_color, this.chords);

  Map<String, dynamic> toMap(bool forUpdate) {
    var data = {
//      'id': id,  since id is auto incremented in the database we don't need to send it to the insert query.
      'title': utf8.encode(title),
      'content': utf8.encode(content),
      'date_created': epochFromDate(date_created),
      'date_last_edited': epochFromDate(date_last_edited),
      'song_color': song_color.value,
      'is_archived': is_archived, //  for later use for integrating archiving
      'chords': jsonEncode({
        "sequence": chords
      }),
    };
    if (forUpdate) {
      data["id"] = this.id;
    }
    return data;
  }

// Converting the date time object into int representing seconds passed after midnight 1st Jan, 1970 UTC
  int epochFromDate(DateTime dt) {
    return dt.millisecondsSinceEpoch ~/ 1000;
  }

// overriding toString() of the song class to print a better debug description of this custom class
  @override
  toString() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date_created': epochFromDate(date_created),
      'date_last_edited': epochFromDate(date_last_edited),
      'song_color': song_color.toString(),
      'is_archived': is_archived,
      'chords': jsonEncode({
        "sequence": chords
      }),
    }.toString();
  }
}
