import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../core/match_odds_service.dart';
import '../widgets/match/match_scoreboard.dart';
import '../widgets/match/match_overview.dart' as match_overview; // Thêm alias
import '../widgets/match/match_odds.dart';
import '../widgets/match/match_stats.dart' as match_stats; // Thêm alias
import '../widgets/match/match_lineups.dart';
import '../widgets/match/match_h2h.dart';
import '../widgets/match/match_standings.dart';

class MatchInforScreen extends StatefulWidget {
  final int matchId;

  const MatchInforScreen({required this.matchId, Key? key}) : super(key: key);

  @override
  _MatchInforScreenState createState() => _MatchInforScreenState();
}

class _MatchInforScreenState extends State<MatchInforScreen> {
  late Future<Map<String, dynamic>> _matchDetail;
  late Future<Map<String, dynamic>> _matchStats;
  late Future<Map<String, dynamic>> _standings;
  late Future<Map<String, dynamic>> _h2hMatches;
  late Future<Map<String, dynamic>> _homeTeamDetail;
  late Future<Map<String, dynamic>> _awayTeamDetail;
  int? homeTeamId;
  int? awayTeamId;
  final MatchOddsService _matchOddsService = MatchOddsService();

  @override
  void initState() {
    super.initState();
    _matchStats = ApiService.fetchMatchStats(widget.matchId);
    _matchDetail = ApiService.fetchMatchDetail(widget.matchId).then((match) {
      homeTeamId = match["homeTeam"]["id"];
      awayTeamId = match["awayTeam"]["id"];
      return match;
    });
    _standings = _matchDetail.then((match) {
      final competitionId = match["competition"]["id"];
      return ApiService.fetchStandings(competitionId);
    });
    _h2hMatches = ApiService.fetchHeadToHead(widget.matchId);
    _homeTeamDetail = _matchDetail.then((_) => ApiService.fetchTeamDetail(homeTeamId!));
    _awayTeamDetail = _matchDetail.then((_) => ApiService.fetchTeamDetail(awayTeamId!));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _matchDetail,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Lỗi khi tải dữ liệu trận đấu: ${snapshot.error}")),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text("Không có dữ liệu trận đấu")),
          );
        }

        final match = snapshot.data!;
        final homeTeam = match["homeTeam"];
        final awayTeam = match["awayTeam"];
        final score = match["score"]["fullTime"];
        final isFinished = match["status"] == "FINISHED";
        final homeScore = isFinished ? score["home"]?.toString() ?? "?" : "?";
        final awayScore = isFinished ? score["away"]?.toString() ?? "?" : "?";

        return DefaultTabController(
          length: 6,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: const Text("Chi tiết trận đấu"),
              centerTitle: true,
              bottom: const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: "Tổng quan"),
                  Tab(text: "Tỷ lệ cược"),
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
                      match_overview.MatchOverview( // Sử dụng với alias
                        matchDetail: _matchDetail,
                        homeTeamDetail: _homeTeamDetail,
                      ),
                      MatchOdds(
                        match: match,
                        matchOddsService: _matchOddsService,
                      ),
                      match_stats.MatchStats( // Sử dụng với alias
                        statsFuture: _matchStats,
                      ),
                      MatchLineups(
                        homeTeamDetail: _homeTeamDetail,
                        awayTeamDetail: _awayTeamDetail,
                        homeTeamId: homeTeamId,
                        awayTeamId: awayTeamId,
                      ),
                      MatchH2H(h2hFuture: _h2hMatches),
                      MatchStandings(
                        standingsFuture: _standings,
                        homeTeamId: homeTeamId,
                        awayTeamId: awayTeamId,
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