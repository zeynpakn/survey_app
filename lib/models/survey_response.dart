class SurveyResponse {
  final int? id;
  final String username;
  final DateTime timestamp;
  final List<QuestionAnswer> answers;

  SurveyResponse({
    this.id,
    required this.username,
    required this.timestamp,
    required this.answers,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory SurveyResponse.fromMap(Map<String, dynamic> map) {
    return SurveyResponse(
      id: map['id'],
      username: map['username'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      answers: [],
    );
  }
}

class QuestionAnswer {
  final int? id;
  final int responseId;
  final int questionId;
  final String questionText;
  final int rating;

  QuestionAnswer({
    this.id,
    required this.responseId,
    required this.questionId,
    required this.questionText,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'response_id': responseId,
      'question_id': questionId,
      'question_text': questionText,
      'rating': rating,
    };
  }

  factory QuestionAnswer.fromMap(Map<String, dynamic> map) {
    return QuestionAnswer(
      id: map['id'],
      responseId: map['response_id'],
      questionId: map['question_id'],
      questionText: map['question_text'],
      rating: map['rating'],
    );
  }
}
