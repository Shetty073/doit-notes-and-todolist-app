import 'dart:math';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class DatabaseHelper {
  static Database db;

  static Future open() async {
    db = await openDatabase(join(await getDatabasesPath(), 'notes.db'),
        version: 1, onCreate: (Database db, int version) async {
      var sql =
          "CREATE TABLE IF NOT EXISTS Notes(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, body TEXT, list TEXT, fav INTEGER, last_edit DATETIME)";
      var sql2 =
          "CREATE TABLE IF NOT EXISTS Archives(id INTEGER, title TEXT, body TEXT, list TEXT, fav INTEGER, last_edit DATETIME)";
      var sql3 =
          "CREATE TABLE IF NOT EXISTS Deleted(id INTEGER, title TEXT, body TEXT, list TEXT, fav INTEGER, last_edit DATETIME)";
      await db.execute(sql);
      await db.execute(sql2);
      await db.execute(sql3);
    });
  }

  // retrieve
  static Future<List<Map<String, dynamic>>> getNotes(String qry) async {
    if (db == null) {
      await open();
    }
    if(qry != "") {
      String query = "SELECT * FROM Notes WHERE title LIKE '%$qry%' OR body LIKE '%$qry%' OR list LIKE '%$qry%'";
      return await db.rawQuery(query);
    }
    return await db.query("Notes");
  }

  // retrieve specific note
  static Future<List<Map<String, dynamic>>> getSpecificNote(int note_id) async {
    return await db.query("Notes", where: "id = ?", whereArgs: [note_id]);
  }

  // insert
  static Future<int> saveNote(Map<String, dynamic> note) async {
    return await db.insert("Notes", note);
  }

  // delete
  static Future<int> addToDelete(Map<String, dynamic> note) async {
    return await db.insert("Deleted", note);
  }

  static Future<int> deleteNote(int note_id) async {
    return await db.delete(
      "Notes",
      where: "id = ?",
      whereArgs: [note_id],
    );
  }

  static Future<int> deleteNoteFromArchive(int note_id) async {
    return await db.delete(
      "Archives",
      where: "id = ?",
      whereArgs: [note_id],
    );
  }

  static Future<int> deleteNoteFromDeleted(int note_id) async {
    return await db.delete(
      "Deleted",
      where: "id = ?",
      whereArgs: [note_id],
    );
  }

  // delete all deleted notes permanently
  static Future<int> permaDeleteAllNotes() async {
    return await db.delete("Deleted");
  }

  // retrieve deleted notes
  static Future<List<Map<String, dynamic>>> getDeletedNotes() async {
    return await db.query("Deleted");
  }

  // restore
  static Future<int> restoreNote(int note_id) async {
    return await db.delete(
      "Deleted",
      where: "id = ?",
      whereArgs: [note_id],
    );
  }

  // update
  static Future<int> updateNote(Map<String, dynamic> note, int note_id) async {
    return await db.update(
      "Notes",
      note,
      where: "id = ?",
      whereArgs: [note_id],
    );
  }

  // archive
  static Future<int> archiveNote(Map<String, dynamic> note) async {
    return await db.insert("Archives", note);
  }

  // retrieve archived notes
  static Future<List<Map<String, dynamic>>> getArchivedNotes() async {
    return await db.query("Archives");
  }

  // unarchive note
  static Future<int> unArchiveNote(int note_id) async {
    return await db.delete(
      "Archives",
      where: "id = ?",
      whereArgs: [note_id],
    );
  }
}
