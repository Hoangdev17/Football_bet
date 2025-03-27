import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://api.football-data.org/v4";
  static const String apiKey = "fb803ef6ff50477e8ab94e0cfa3351a6"; // API Key

  /// In logs (Có thể bật/tắt dễ dàng)
  static const bool enableLogging = true;

  /// Gửi request HTTP GET với quản lý lỗi chung
  static Future<Map<String, dynamic>> _getRequest(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");

    try {
      final response = await http.get(
        url,
        headers: {
          "X-Auth-Token": apiKey,
          "Content-Type": "application/json",
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception("⏳ Hết thời gian chờ phản hồi từ server");
      });

      if (enableLogging) {
        print("📥 GET $url");
        print("📡 Response status: ${response.statusCode}");
        print("📄 Response body: ${response.body}");
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 403) {
        throw Exception("🚫 Lỗi 403: API Key không hợp lệ.");
      } else if (response.statusCode == 429) {
        throw Exception("⚠️ Lỗi 429: Vượt quá giới hạn API.");
      } else {
        throw Exception("❌ Lỗi API: ${response.statusCode}");
      }
    } catch (e) {
      print("💥 Lỗi khi gọi API: $e");
      throw Exception("Lỗi kết nối: $e");
    }
  }

  /// 📌 Lấy danh sách giải đấu
  static Future<List<dynamic>> fetchLeagues() async {
    final data = await _getRequest("/competitions");
    return data["competitions"] ?? [];
  }

  /// 📌 Lấy danh sách trận đấu theo giải đấu
  static Future<List<dynamic>> fetchMatches(int leagueId) async {
    final data = await _getRequest("/competitions/$leagueId/matches");
    List<dynamic> matches = data["matches"] ?? [];

    // 🎯 Lọc các trận đấu từ năm 2025 trở đi
    return matches.where((match) {
      final matchDate = DateTime.parse(match["utcDate"]);
      return matchDate.year >= 2025;
    }).toList();
  }

  /// 📌 Lấy bảng xếp hạng
  static Future<Map<String, dynamic>> fetchStandings(int competitionId) async {
    return await _getRequest("/competitions/$competitionId/standings");
  }

  /// 📌 Lấy thông tin trận đấu
  static Future<Map<String, dynamic>> fetchMatchDetail(int matchId) async {
    return await _getRequest("/matches/$matchId");
  }

  /// 📌 Lấy thống kê trận đấu
  static Future<Map<String, dynamic>> fetchMatchStats(int matchId) async {
    final data = await _getRequest("/matches/$matchId");
    return data["match"]?["statistics"] ?? {};
  }

  /// 📌 Lấy thông tin chi tiết về một đội bóng dựa trên teamId
  static Future<Map<String, dynamic>> fetchTeamDetail(int teamId) async {
    final data = await _getRequest("/teams/$teamId");
    if (enableLogging) {
      print("📋 Team data for team $teamId: ${json.encode(data)}");
    }
    return data ?? {};
  }

  /// 📌 Lấy lịch sử đối đầu (H2H)
  static Future<Map<String, dynamic>> fetchHeadToHead(int matchId) async {
    return await _getRequest("/matches/$matchId/head2head");
  }
}
