import 'package:flutter/material.dart';
import '../core/api_service.dart';
import 'MatchInforScreen.dart';
import 'package:intl/intl.dart'; // Thêm để định dạng ngày giờ

class MatchListScreen extends StatefulWidget {
  final int leagueId;

  MatchListScreen({required this.leagueId});

  @override
  _MatchListScreenState createState() => _MatchListScreenState();
}

class _MatchListScreenState extends State<MatchListScreen> {
  late Future<List<dynamic>> _matches;
  Set<int> _favoriteMatches = {};

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
              final matchId = match["id"];
              final homeTeam = match["homeTeam"];
              final awayTeam = match["awayTeam"];
              final score = match["score"]["fullTime"];
              final isFinished = match["status"] == "FINISHED";
              final utcTime = match["utcDate"]; // Thời gian gốc UTC

              // Chuyển thành giờ địa phương
              final dateTime = DateTime.parse(utcTime).toLocal();
              final formattedTime = DateFormat("HH:mm dd/MM/yyyy").format(dateTime);

              final homeScore = isFinished ? score["home"]?.toString() ?? "?" : "?";
              final awayScore = isFinished ? score["away"]?.toString() ?? "?" : "?";

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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Cột đội nhà
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Home team",
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color:Colors.green)),
                              const SizedBox(height: 4),
                              Image.network(
                                homeTeam["crest"] ?? "",
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.sports_soccer, size: 40),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                homeTeam["name"],
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        // Cột giữa: Tỷ số và thời gian
                        SizedBox(
                          width: 100,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "$homeScore - $awayScore",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formattedTime,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        // Cột đội khách
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Away team",
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color:Colors.blue)),
                              const SizedBox(height: 4),
                              Image.network(
                                awayTeam["crest"] ?? "",
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.sports_soccer, size: 40),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                awayTeam["name"],
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        // Nút yêu thích
                        IconButton(
                          icon: Icon(
                            _favoriteMatches.contains(matchId)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_favoriteMatches.contains(matchId)) {
                                _favoriteMatches.remove(matchId);
                              } else {
                                _favoriteMatches.add(matchId);
                              }
                            });
                          },
                        ),
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
}
