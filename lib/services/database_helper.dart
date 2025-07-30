import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/survey_response.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'survey_app.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE survey_responses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE question_answers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        response_id INTEGER NOT NULL,
        question_id INTEGER NOT NULL,
        question_text TEXT NOT NULL,
        rating INTEGER NOT NULL,
        FOREIGN KEY(response_id) REFERENCES survey_responses(id)
      )
    ''');
  }

  Future<int> insertSurveyResponse(SurveyResponse response) async {
    final db = await database;

    // Anket yanıtını ekle
    int responseId = await db.insert('survey_responses', response.toMap());

    // Soru cevaplarını ekle
    for (var answer in response.answers) {
      await db.insert('question_answers', {
        'response_id': responseId,
        'question_id': answer.questionId,
        'question_text': answer.questionText,
        'rating': answer.rating,
      });
    }

    return responseId;
  }

  Future<List<SurveyResponse>> getAllSurveyResponses() async {
    final db = await database;

    final List<Map<String, dynamic>> responsesMaps = await db.query(
      'survey_responses',
      orderBy: 'timestamp DESC',
    );

    List<SurveyResponse> responses = [];

    for (var responseMap in responsesMaps) {
      final List<Map<String, dynamic>> answersMaps = await db.query(
        'question_answers',
        where: 'response_id = ?',
        whereArgs: [responseMap['id']],
      );

      List<QuestionAnswer> answers = answersMaps
          .map((answerMap) => QuestionAnswer.fromMap(answerMap))
          .toList();

      SurveyResponse response = SurveyResponse.fromMap(responseMap);
      response = SurveyResponse(
        id: response.id,
        username: response.username,
        timestamp: response.timestamp,
        answers: answers,
      );

      responses.add(response);
    }

    return responses;
  }

  Future<List<Map<String, dynamic>>> getSurveyStatistics() async {
    final db = await database;

    final List<Map<String, dynamic>> stats = await db.rawQuery('''
      SELECT 
        question_text,
        AVG(rating) as average_rating,
        COUNT(*) as response_count,
        MIN(rating) as min_rating,
        MAX(rating) as max_rating
      FROM question_answers 
      GROUP BY question_id, question_text
      ORDER BY question_id
    ''');

    return stats;
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
