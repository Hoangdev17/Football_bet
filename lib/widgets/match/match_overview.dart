import 'package:flutter/material.dart';
import '../shared/team_info.dart';
import '../../utils/match_utils.dart';
import '../shared/future_handler.dart';

class MatchOverview extends StatelessWidget {
  final Future<Map<String, dynamic>> matchDetail;
  final Future<Map<String, dynamic>> homeTeamDetail;

  const MatchOverview({
    required this.matchDetail,
    required this.homeTeamDetail,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sử dụng TabUtils.buildTabContent để xử lý tự động các trạng thái:
    // - Hiển thị loading khi đang chờ dữ liệu
    // - Hiển thị thông báo khi không có dữ liệu
    // - Hiển thị lỗi nếu request thất bại
    return FutureBuilder(
      future: Future.wait([matchDetail, homeTeamDetail]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.length < 2) {
          return const Center(child: Text("Không có dữ liệu tổng quan trận đấu"));
        } else {
          return _buildOverviewContent(
            snapshot.data![0] as Map<String, dynamic>,
            snapshot.data![1] as Map<String, dynamic>,
          );
        }
      },
    );
  }

  Widget _buildOverviewContent(Map<String, dynamic> match, Map<String, dynamic> homeTeamDetail) {
    final homeTeam = match["homeTeam"];
    final awayTeam = match["awayTeam"];
    final stadium = match["venue"] ?? homeTeamDetail["venue"] ?? "Không rõ";
    final matchTime = match["utcDate"] ?? "";
    final formattedTime = MatchUtils.formatMatchTime(matchTime);
    final status = _translateStatus(match["status"] ?? "UNKNOWN");
    final score = match["score"]["fullTime"];
    final homeScore = score["home"]?.toString() ?? "?";
    final awayScore = score["away"]?.toString() ?? "?";

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMatchInfo(homeTeam, awayTeam, homeScore, awayScore, formattedTime, stadium, status),
        const SizedBox(height: 16),
        _buildAdditionalInfo(match),
      ],
    );
  }

  Widget _buildMatchInfo(
      Map<String, dynamic> homeTeam,
      Map<String, dynamic> awayTeam,
      String homeScore,
      String awayScore,
      String matchTime,
      String stadium,
      String status,
      ) {
    return Column(
      children: [
        const Text(
          "Thông tin trận đấu",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TeamInfo(team: homeTeam),
            Column(
              children: [
                Text(
                  "$homeScore - $awayScore",
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Text(status, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
            TeamInfo(team: awayTeam),
          ],
        ),
        const SizedBox(height: 10),
        Text("🏟️ $stadium", style: const TextStyle(fontSize: 16)),
        Text("⏰ $matchTime", style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildAdditionalInfo(Map<String, dynamic> match) {
    final referees = match["referees"] as List<dynamic>?;
    final refereeName = (referees != null && referees.isNotEmpty)
        ? referees[0]["name"] ?? "Không rõ"
        : "Không rõ";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Thông tin bổ sung",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text("Trọng tài: $refereeName"),
        Text("Giải đấu: ${match["competition"]?["name"] ?? "Không rõ"}"),
      ],
    );
  }

  String _translateStatus(String status) {
    switch (status) {
      case "FINISHED":
        return "Đã kết thúc";
      case "IN_PLAY":
        return "Đang diễn ra";
      case "PAUSED":
        return "Tạm dừng";
      case "SCHEDULED":
        return "Đã lên lịch";
      case "POSTPONED":
        return "Bị hoãn";
      case "CANCELED":
        return "Đã hủy";
      default:
        return status;
    }
  }
}