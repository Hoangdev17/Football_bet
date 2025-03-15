import 'package:flutter/material.dart';
import '../core/api_service.dart';

class MatchInforScreen extends StatefulWidget {
  final int matchId;



  MatchInforScreen({required this.matchId});

  @override
  _MatchInforScreenState createState() => _MatchInforScreenState();
}

class _MatchInforScreenState extends State<MatchInforScreen> {
  late Future<Map<String, dynamic>> _matchDetail;
  late Future<Map<String, dynamic>> _matchStats;

  @override
  void initState() {
    super.initState();
    _matchStats = ApiService.fetchMatchStats(widget.matchId);
    _matchDetail = ApiService.fetchMatchDetail(widget.matchId);
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
            body: Center(child: Text("Lỗi khi tải dữ liệu trận đấu!")),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            body: Center(child: Text("Không có dữ liệu trận đấu!")),
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
              title: Text("Chi tiết trận đấu"),
              centerTitle: true,
            ),
            body: Column(
              children: [
                _buildMatchScoreboard(homeTeam, awayTeam, homeScore, awayScore),
                TabBar(
                  tabs: [
                    Tab(text: "Overview"),
                    Tab(text: "Odds"),
                    Tab(text: "Stats"),
                    Tab(text: "Lineups"),
                    Tab(text: "H2H"),
                    Tab(text: "Standings"),
                  ],
                  isScrollable: true,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTabContent("Overview"),
                      _buildTabContent("Odds"),
                      _buildMatchStats(),
                      _buildTabContent("Lineups"),
                      _buildTabContent("H2H"),
                      _buildTabContent("Standings"),
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

  /// Widget hiển thị tab Stats
  Widget _buildMatchStats() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _matchStats,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final stats = snapshot.data?['scorers'];

        if (stats == null) {
          return const Center(child: Text('No statistics available'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatProgress('Possession', stats['possession'], isPercentage: true),
            _buildStatRow('Total Shots', stats['totalShots']),
            _buildStatRow('Shots on Target', stats['shotsOnTarget']),
            _buildStatRow('Passes', stats['totalPasses']),
            _buildStatRow('Fouls', stats['fouls']),
            _buildStatRow('Yellow Cards', stats['yellowCards']),
            _buildStatRow('Red Cards', stats['redCards']),
          ],
        );
      },
    );
  }
  /// Support for _buildMatchStats
  Widget _buildStatRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value?.toString() ?? '-', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildStatProgress(String label, dynamic value, {bool isPercentage = false}) {
    double progress = 0;
    if (value != null) {
      progress = isPercentage ? (double.tryParse(value.toString()) ?? 0) / 100 : double.tryParse(value.toString()) ?? 0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          color: Colors.blue,
          minHeight: 8,
        ),
        const SizedBox(height: 8),
      ],
    );
  }


  /// Widget hiển thị Timeline trận đấu
  Widget _buildMatchTimeline() {
    return Column(
      children: [
        Text("📅 Timeline trận đấu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        // Dữ liệu giả lập (thay bằng API Football Data nếu có)
        ListTile(
          leading: Icon(Icons.sports_soccer, color: Colors.blue),
          title: Text("29' Mohamed Salah (Diogo Jota)"),
        ),
        ListTile(
          leading: Icon(Icons.sports_soccer, color: Colors.blue),
          title: Text("38' Youri Tielemans"),
        ),
        ListTile(
          leading: Icon(Icons.sports_soccer, color: Colors.blue),
          title: Text("45+3' Ollie Watkins (Lucas Digne)"),
        ),
      ],
    );
  }

  /// Widget hiển thị tỷ số trận đấu
  Widget _buildMatchScoreboard(Map<String, dynamic> homeTeam, Map<String, dynamic> awayTeam, String homeScore, String awayScore) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: Colors.green,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTeamInfo(homeTeam),
              Text(
                "$homeScore - $awayScore",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              _buildTeamInfo(awayTeam),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget hiển thị logo + tên đội bóng
  Widget _buildTeamInfo(Map<String, dynamic> team) {
    return Column(
      children: [
        Image.network(
          team["crest"] ?? "",
          width: 50,
          height: 50,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.sports_soccer, size: 50, color: Colors.grey),
        ),
        SizedBox(height: 4),
        Text(
          team["name"],
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Hàm giả lập nội dung của các tab khác
  Widget _buildTabContent(String tabName) {
    return Center(
      child: Text(
        "Nội dung của $tabName",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
