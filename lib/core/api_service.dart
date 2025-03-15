import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = "https://api.football-data.org/v4";
  static const String apiKey = "fb803ef6ff50477e8ab94e0cfa3351a6"; // API Key

  /// Hàm lấy danh sách giải đấu
  static Future<List<dynamic>> fetchLeagues() async {
    final url = Uri.parse("$baseUrl/competitions");
    try {
      final response = await http.get(
        url,
        headers: {
          "X-Auth-Token": apiKey,
        },
      ).timeout(Duration(seconds: 10), onTimeout: () {
        throw Exception("Hết thời gian chờ phản hồi từ server");
      });

      // In chi tiết phản hồi
      print("Response status: ${response.statusCode}");
      print("Response headers: ${response.headers}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["competitions"] ?? [];
      } else if (response.statusCode == 403) {
        throw Exception("Lỗi 403: API Key không hợp lệ hoặc không có quyền truy cập. Body: ${response.body}");
      } else if (response.statusCode == 429) {
        throw Exception("Lỗi 429: Vượt quá giới hạn yêu cầu (rate limit). Body: ${response.body}");
      } else {
        throw Exception("Lỗi khi tải danh sách giải đấu: ${response.statusCode}. Body: ${response.body}");
      }
    } on http.ClientException catch (e) {
      print("ClientException chi tiết: $e"); // In lỗi chi tiết
      throw Exception("Lỗi kết nối: $e");
    } catch (e) {
      print("Lỗi khác: $e");
      throw Exception("Lỗi khi gọi API: $e");
    }
  }

  /// Hàm lấy danh sách trận đấu theo giải đấu
  static Future<List<dynamic>> fetchMatches(int leagueId) async {
    final url = Uri.parse("$baseUrl/competitions/$leagueId/matches");
    try {
      final response = await http.get(
        url,
        headers: {
          "X-Auth-Token": apiKey,
          "Content-Type": "application/json"
        },
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["matches"] ?? [];
      } else {
        throw Exception("Lỗi khi tải danh sách trận đấu: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi khi gọi API trận đấu: $e");
    }
  }
  /// Hàm lấy thông tin trận đấu
  static Future<Map<String, dynamic>> fetchMatchDetail(int matchId) async {
    final url = Uri.parse("$baseUrl/matches/$matchId");

    final response = await http.get(
      url,
      headers: {
        "X-Auth-Token": apiKey,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Lỗi khi tải dữ liệu trận đấu!");
    }
  }
  /// Hàm lấy thống kê trận đấu
  static Future<Map<String, dynamic>> fetchMatchStats(int matchId) async {
    final url = Uri.parse("$baseUrl/matches/$matchId");

    try {
      final response = await http.get(
        url,
        headers: {
          "X-Auth-Token": apiKey,
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["match"]?["statistics"] ?? {};
      } else {
        throw Exception("Lỗi khi tải thống kê trận đấu: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi khi gọi API thống kê trận đấu: $e");
    }
  }
}
