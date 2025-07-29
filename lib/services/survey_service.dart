import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class SurveyService {
  static const String apiUrl = 'https://raw.githubusercontent.com/zeynpakn/survey-api/main/db.json';

  static Future<List<GetQuestion>> fetchQuestions() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> questionsJson = data['questions'];

      return questionsJson.map((q) => GetQuestion.fromJson(q)).toList();
    } else {  
      throw Exception('Veriler alınamadı');
    }
  }
}
