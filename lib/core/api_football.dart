import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/live_match.dart';

class ApiFootball {
  static const String apiKey = "01402f82bd0d9d7d4815dc708fd9e180";
  static const String baseUrl = "https://v3.football.api-sports.io";

  // Get live matches
  static Future<List<LiveMatch>> getLiveMatches() async {
    final url = Uri.parse("$baseUrl/fixtures?live=all");
    final response = await http.get(
      url,
      headers: {"x-apisports-key": apiKey},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final matches = data["response"] ?? [];
      return matches.map<LiveMatch>((match) => LiveMatch.fromJson(match)).toList();
    }
    throw Exception("Failed to load live matches: ${response.statusCode}");
  }

  // Get upcomming matches
  static Future<List<LiveMatch>> getUpcomingMatches() async {
    final now = DateTime.now();
    final twoDaysLater = now.add(const Duration(days: 2));

    final fromDate = _formatDate(now);
    final toDate = _formatDate(twoDaysLater);

    final url = Uri.parse("$baseUrl/fixtures?date=$fromDate-$toDate");
    final response = await http.get(
      url,
      headers: {"x-apisports-key": apiKey},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final matches = data["response"] ?? [];
      return matches.map<LiveMatch>((match) => LiveMatch.fromJson(match)).toList();
    }
    throw Exception("Failed to load upcoming matches: ${response.statusCode}");
  }

// Date template
  static String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Get match events
  static Future<List<MatchEvent>> getMatchEvents(int fixtureId) async {
    final url = Uri.parse("$baseUrl/fixtures/events?fixture=$fixtureId");
    final response = await http.get(
      url,
      headers: {"x-apisports-key": apiKey},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('match event ${data}');
      return (data["response"] ?? []).map<MatchEvent>((e) => MatchEvent.fromJson(e)).toList();
    }
    throw Exception("Failed to load match events: ${response.statusCode}");
  }
  /// get stats
  static Future<Map<String, dynamic>> getMatchStats(int fixtureId) async {
    final url = Uri.parse("$baseUrl/fixtures/statistics?fixture=$fixtureId");
    final response = await http.get(
      url,
      headers: {"x-apisports-key": apiKey},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final statsList = data["response"];

      // Chuẩn hóa dữ liệu
      Map<String, dynamic> homeStats = {};
      Map<String, dynamic> awayStats = {};

      for (var teamStats in statsList) {
        final team = teamStats["team"];
        final isHome = statsList.indexOf(teamStats) == 0; // Theo thứ tự: [home, away]

        for (var stat in teamStats["statistics"]) {
          final key = _normalizeStatName(stat["type"]);
          final value = stat["value"] ?? "0";

          if (isHome) {
            homeStats[key] = value.toString().replaceAll('%', '');
          } else {
            awayStats[key] = value.toString().replaceAll('%', '');
          }
        }
      }

      return {
        "home": homeStats,
        "away": awayStats,
      };
    }

    throw Exception("Failed to load match statistics: ${response.statusCode}");
  }

  static String _normalizeStatName(String name) {
    switch (name.toLowerCase()) {
      case 'possession':
      case 'ball possession':
        return 'possession';
      case 'total shots':
        return 'totalShots';
      case 'shots on target':
        return 'shotsOnTarget';
      case 'passes':
      case 'total passes':
        return 'totalPasses';
      case 'fouls':
        return 'fouls';
      case 'yellow cards':
        return 'yellowCards';
      case 'red cards':
        return 'redCards';
      default:
        return name.replaceAll(' ', '');
    }
  }

}