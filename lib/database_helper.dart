import 'dart:async'; // Import for StreamController
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  final StreamController<List<Map<String, dynamic>>> _notesStreamController =
  StreamController<List<Map<String, dynamic>>>.broadcast();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'notes.db');
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT)',
        );
      },
    );
    return db;
  }

  Future<void> insertNote(String content) async {
    final db = await database;
    await db.insert(
      'notes',
      {'content': content},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _refreshNotesStream(); // Refresh the stream after inserting a note
  }

  Future<void> updateNote(int id, String content) async {
    final db = await database;
    await db.update(
      'notes',
      {'content': content},
      where: 'id = ?',
      whereArgs: [id],
    );
    _refreshNotesStream(); // Refresh the stream after updating a note
  }

  Future<void> deleteNote(int id) async {
    final db = await database;
    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    _refreshNotesStream(); // Refresh the stream after deleting a note
  }

  // Method to refresh the notes stream
  void _refreshNotesStream() async {
    final db = await database;
    final notes = await db.query('notes');
    _notesStreamController.add(notes);
  }

  // Method to get the notes stream
  Stream<List<Map<String, dynamic>>> getNotesStream() {
    _refreshNotesStream(); // Ensure we start with current data
    return _notesStreamController.stream;
  }

  // Method to search notes
  Future<List<Map<String, dynamic>>> searchNotes(String query) async {
    final db = await database;
    return await db.query(
      'notes',
      where: 'content LIKE ?',
      whereArgs: ['%$query%'],
    );
  }

  // Method to get the search stream
  Stream<List<Map<String, dynamic>>> searchNotesStream(String query) async* {
    // Use a periodic timer to simulate real-time search updates
    final StreamController<List<Map<String, dynamic>>> searchStreamController =
    StreamController<List<Map<String, dynamic>>>.broadcast();

    Timer? timer;
    void startTimer() {
      timer = Timer.periodic(const Duration(milliseconds: 300), (_) async {
        final notes = await searchNotes(query);
        searchStreamController.add(notes);
      });
    }

    startTimer();

    yield* searchStreamController.stream;

    // Clean up timer and stream controller
    searchStreamController.onCancel = () {
      timer?.cancel();
      searchStreamController.close();
    };
  }

  // Close the stream controller when it's no longer needed
  Future<void> close() async {
    await _notesStreamController.close();
  }
}
