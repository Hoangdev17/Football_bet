import 'package:flutter/material.dart';
import '../core/api_service.dart';
import 'MatchInforScreen.dart';

class MatchListScreen extends StatefulWidget {
  final int leagueId;

  MatchListScreen({required this.leagueId});

  @override
  _MatchListScreenState createState() => _MatchListScreenState();
}

class _MatchListScreenState extends State<MatchListScreen> {
  late Future<List<dynamic>> _matches;

  @override
  void initState() {
    super.initState();
    _matches = ApiService.fetchMatches(widget.leagueId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách trận đấu"),
        centerTitle: true,
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _matches,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Không có trận đấu nào!"));
          }

          final matches = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              final matchId = match["id"]; // Lấy matchId
              final homeTeam = match["homeTeam"];
              final awayTeam = match["awayTeam"];
              final score = match["score"]["fullTime"];
              final isFinished = match["status"] == "FINISHED";

              final homeScore = isFinished ? score["home"]?.toString() ?? "?" : "?";
              final awayScore = isFinished ? score["away"]?.toString() ?? "?" : "?";

              // Xác định màu đội thắng
              Color homeColor = Colors.grey;
              Color awayColor = Colors.grey;

              if (isFinished) {
                int home = int.tryParse(homeScore) ?? 0;
                int away = int.tryParse(awayScore) ?? 0;
                if (home > away) {
                  homeColor = Colors.blue; // Đội nhà thắng
                } else if (home < away) {
                  awayColor = Colors.orange; // Đội khách thắng
                }
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MatchInforScreen(matchId: matchId),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTeamInfo(homeTeam, homeColor), // Đội nhà
                        _buildScore(homeScore, awayScore), // Tỷ số
                        _buildTeamInfo(awayTeam, awayColor), // Đội khách
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Widget hiển thị logo + tên đội
  Widget _buildTeamInfo(Map<String, dynamic> team, Color textColor) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            team["crest"] ?? "",
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.sports_soccer, size: 40),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              team["name"],
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget hiển thị tỷ số cân đối
  Widget _buildScore(String homeScore, String awayScore) {
    return Container(
      width: 60,
      alignment: Alignment.center,
      child: Text(
        "$homeScore - $awayScore",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}
