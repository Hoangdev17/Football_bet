import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = "https://api.football-data.org/v4";
  static const String apiKey = "a522b31569474813ba1e8ccba3881cfe"; // API Key

  /// Hàm lấy danh sách giải đấu
  static Future<List<dynamic>> fetchLeagues() async {
    final url = Uri.parse("$baseUrl/competitions");
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
        return data["competitions"] ?? [];
      } else {
        throw Exception("Lỗi khi tải danh sách giải đấu: ${response.statusCode}");
      }
    } catch (e) {
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
}
