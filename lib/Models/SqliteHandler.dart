import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqlite_api.dart';
import 'dart:async';
import 'Song.dart';

class SongsDBHandler {
  final databaseName = "songs.db";
  final tableName = "songs";

  final fieldMap = {
    "id": "INTEGER PRIMARY KEY AUTOINCREMENT",
    "title": "BLOB",
    "content": "BLOB",
    "date_created": "INTEGER",
    "date_last_edited": "INTEGER",
    "song_color": "INTEGER",
    "is_archived": "INTEGER",
    "chords": "TEXT"
  };

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    var path = await getDatabasesPath();
    var dbPath = join(path, 'songs.db');
    // ignore: argument_type_not_assignable
    Database dbConnection = await openDatabase(dbPath, version: 1,
        onCreate: (Database db, int version) async {
      print("executing create query from onCreate callback");
      await db.execute(_buildCreateQuery());
    });

    await dbConnection.execute(_buildCreateQuery());
    _buildCreateQuery();
    return dbConnection;
  }

// build the create query dynamically using the column:field dictionary.
  String _buildCreateQuery() {
    String query = "CREATE TABLE IF NOT EXISTS ";
    query += tableName;
    query += "(";
    fieldMap.forEach((column, field) {
      print("$column : $field");
      query += "$column $field,";
    });

    query = query.substring(0, query.length - 1);
    query += " )";

    return query;
  }

  static Future<String> dbPath() async {
    String path = await getDatabasesPath();
    return path;
  }

  Future<int> insertSong(Song song, bool isNew) async {
    // Get a reference to the database
    final Database db = await database;
    print("insert called");
    print("Trying to insert..");
    print(song.toMap(false).toString());

    // Insert the Songs into the correct table.
    await db.insert(
      'songs',
      isNew ? song.toMap(false) : song.toMap(true),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (isNew) {
      // get latest song which isn't archived, limit by 1
      var one = await db.query("songs",
          orderBy: "date_last_edited desc",
          where: "is_archived = ?",
          whereArgs: [0],
          limit: 1);
      int latestId = one.first["id"] as int;
      return latestId;
    }
    return song.id;
  }

  Future<bool> deleteSong(Song song) async {
    if (song.id != -1) {
      final Database db = await database;
      try {
        await db.delete("songs", where: "id = ?", whereArgs: [song.id]);
        return true;
      } catch (Error) {
        print("Error deleting ${song.id}: ${Error.toString()}");
        return false;
      }
    }
  }

  Future<List<Map<String, dynamic>>> selectAllSongs() async {
    final Database db = await database;
    // query all the songs sorted by last edited
    var data = await db.query("songs",
        orderBy: "date_last_edited desc",
        where: "is_archived = ?",
        whereArgs: [0]);

    return data;
  }
}
