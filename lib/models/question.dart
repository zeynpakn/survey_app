class GetQuestion {
  final int id;
  final String question;

  GetQuestion({required this.id, required this.question});

  factory GetQuestion.fromJson(Map<String, dynamic> json) {
    return GetQuestion(
      id: json['id'],
      question: json['question']
    );
  }
}

class PostQuestion{
  final int id;
  final int rate;

  PostQuestion({required this.id, required this.rate});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rate': rate,
    };
  }
}