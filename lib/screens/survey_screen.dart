import 'package:flutter/material.dart';
import '../services/survey_service.dart';
import '../services/database_helper.dart';
import '../models/question.dart';
import '../models/survey_response.dart';

class SurveyScreen extends StatefulWidget {
  final String username;

  const SurveyScreen({super.key, required this.username});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  late Future<List<GetQuestion>> _futureQuestions;
  List<GetQuestion> _questions = [];
  List<int?> selectedRatings = [];

  @override
  void initState() {
    super.initState();
    _futureQuestions = SurveyService.fetchQuestions();
  }

  void rateSelected(int index, int value) {
    setState(() {
      selectedRatings[index] = value;
    });
  }

  void submitSurvey() async {
    if (selectedRatings.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm soruları cevaplayın")),
      );
      return;
    }

    try {
      // Veritabanına kaydet
      List<QuestionAnswer> answers = [];
      for (int i = 0; i < _questions.length; i++) {
        answers.add(
          QuestionAnswer(
            responseId: 0, // Geçici değer, veritabanı tarafından ayarlanacak
            questionId: _questions[i].id,
            questionText: _questions[i].question,
            rating: selectedRatings[i]!,
          ),
        );
      }

      SurveyResponse response = SurveyResponse(
        username: widget.username,
        timestamp: DateTime.now(),
        answers: answers,
      );

      await DatabaseHelper().insertSurveyResponse(response);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Anket başarıyla gönderildi ve kaydedildi!"),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  Widget _buildSurveyList(List<GetQuestion> questions) {
    _questions = questions;

    if (selectedRatings.length != _questions.length) {
      selectedRatings = List<int?>.filled(_questions.length, null);
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              final q = _questions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q.question,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(5, (i) {
                          final score = i + 1;
                          return Row(
                            children: [
                              Radio<int>(
                                value: score,
                                groupValue: selectedRatings[index],
                                onChanged: (value) =>
                                    rateSelected(index, value!),
                              ),
                              Text(score.toString()),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: submitSurvey,
              child: const Text("Gönder"),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Anket")),
      body: FutureBuilder<List<GetQuestion>>(
        future: _futureQuestions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Soru bulunamadı."));
          }

          return _buildSurveyList(snapshot.data!);
        },
      ),
    );
  }
}
