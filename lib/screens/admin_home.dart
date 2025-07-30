import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/survey_response.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SurveyResponse> surveyResponses = [];
  List<Map<String, dynamic>> statistics = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final responses = await DatabaseHelper().getAllSurveyResponses();
      final stats = await DatabaseHelper().getSurveyStatistics();

      setState(() {
        surveyResponses = responses;
        statistics = stats;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        backgroundColor: const Color.fromARGB(255, 232, 108, 149),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Anket Cevapları"),
            Tab(text: "İstatistikler"),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildResponsesTab(), _buildStatisticsTab()],
            ),
    );
  }

  Widget _buildResponsesTab() {
    if (surveyResponses.isEmpty) {
      return const Center(
        child: Text(
          "Henüz anket cevabı bulunmuyor.",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: surveyResponses.length,
      itemBuilder: (context, index) {
        final response = surveyResponses[index];

        return Card(
          margin: const EdgeInsets.all(8),
          child: ExpansionTile(
            title: Text(
              "Kullanıcı: ${response.username}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Tarih: ${_formatDate(response.timestamp)}",
              style: TextStyle(color: Colors.grey[600]),
            ),
            children: response.answers.map((answer) {
              return ListTile(
                title: Text(answer.questionText),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getRatingColor(answer.rating),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${answer.rating}/5",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsTab() {
    if (statistics.isEmpty) {
      return const Center(
        child: Text(
          "İstatistik verisi bulunmuyor.",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: statistics.length,
      itemBuilder: (context, index) {
        final stat = statistics[index];
        final avgRating = (stat['average_rating'] as double).toStringAsFixed(1);

        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat['question_text'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem("Ortalama", avgRating, Colors.blue),
                    _buildStatItem(
                      "Cevap Sayısı",
                      "${stat['response_count']}",
                      Colors.green,
                    ),
                    _buildStatItem(
                      "En Düşük",
                      "${stat['min_rating']}",
                      Colors.red,
                    ),
                    _buildStatItem(
                      "En Yüksek",
                      "${stat['max_rating']}",
                      Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow[700]!;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
