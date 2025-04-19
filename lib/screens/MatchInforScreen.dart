import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../widgets/match/match_overview.dart' as match_overview; // Thêm alias
import '../widgets/match/match_stats.dart' as match_stats; // Thêm alias
import '../widgets/match/match_lineups.dart';
import '../widgets/match/match_h2h.dart';
import '../widgets/match/match_standings.dart';
import '../widgets/match/match_scoreboard.dart';

class MatchInforScreen extends StatefulWidget {
  final int matchId;

  const MatchInforScreen({required this.matchId, Key? key}) : super(key: key);

  @override
  _MatchInforScreenState createState() => _MatchInforScreenState();
}

class _MatchInforScreenState extends State<MatchInforScreen> {
  late Future<Map<String, dynamic>> _matchData;

  @override
  void initState() {
    super.initState();
    _matchData = _fetchAllData();
  }

  Future<Map<String, dynamic>> _fetchAllData() async {

    try {
      // Gọi tất cả API song song
      final matchDetail = await ApiService.fetchMatchDetail(widget.matchId);
      final homeTeamId = matchDetail["homeTeam"]["id"];
      final awayTeamId = matchDetail["awayTeam"]["id"];

      final results = await Future.wait([
        ApiService.fetchMatchStats(widget.matchId),
        ApiService.fetchStandings(matchDetail["competition"]["id"]),
        ApiService.fetchHeadToHead(widget.matchId),
        ApiService.fetchTeamDetail(homeTeamId),
        ApiService.fetchTeamDetail(awayTeamId),
      ]);

      return {
        "matchDetail": matchDetail,
        "matchStats": results[0],
        "standings": results[1],
        "h2hMatches": results[2],
        "homeTeamDetail": results[3],
        "awayTeamDetail": results[4],
        "homeTeamId": homeTeamId,
        "awayTeamId": awayTeamId,
      };
    } catch (e) {
      throw Exception("Lỗi tải dữ liệu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _matchData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Lỗi khi tải dữ liệu: ${snapshot.error}")),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text("Không có dữ liệu trận đấu")),
          );
        }

        final data = snapshot.data!;
        final match = data["matchDetail"];
        final homeTeam = match["homeTeam"];
        final awayTeam = match["awayTeam"];
        final score = match["score"]["fullTime"];
        final isFinished = match["status"] == "FINISHED";
        final homeScore = isFinished ? score["home"]?.toString() ?? "?" : "?";
        final awayScore = isFinished ? score["away"]?.toString() ?? "?" : "?";

        return DefaultTabController(
          length: 5,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: const Text("Chi tiết trận đấu"),
              centerTitle: true,
              bottom: const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: "Tổng quan"),
                  Tab(text: "Thống kê"),
                  Tab(text: "Đội hình"),
                  Tab(text: "Đối đầu"),
                  Tab(text: "Bảng xếp hạng"),
                ],
              ),
            ),
            body: Column(
              children: [
                MatchScoreboard(
                  homeTeam: homeTeam,
                  awayTeam: awayTeam,
                  homeScore: homeScore,
                  awayScore: awayScore,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      match_overview.MatchOverview(
                        matchDetail: Future.value(data["matchDetail"]),
                        homeTeamDetail: Future.value(data["homeTeamDetail"]),
                      ),
                      match_stats.MatchStats(
                        statsFuture: Future.value(data["matchStats"]),
                      ),
                      MatchLineups(
                        homeTeamDetail: Future.value(data["homeTeamDetail"]),
                        awayTeamDetail: Future.value(data["awayTeamDetail"]),
                        homeTeamId: data["homeTeamId"],
                        awayTeamId: data["awayTeamId"],
                      ),
                      MatchH2H(
                        h2hFuture: Future.value(data["h2hMatches"]),
                      ),
                      MatchStandings(
                        standingsFuture: Future.value(data["standings"]),
                        homeTeamId: data["homeTeamId"],
                         awayTeamId: data["awayTeamId"],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
