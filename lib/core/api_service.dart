import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = "https://api.football-data.org/v4/competitions/";

  /// Hàm lấy danh sách giải đấu
  static Future<List<dynamic>> fetchLeagues() async {
    final url = Uri.parse(baseUrl);
    try {
      final response = await http.get(
        url,
        headers: {
          "X-Auth-Token": "a522b31569474813ba1e8ccba3881cfe", // Thêm token vào header
          "Content-Type": "application/json"
        },
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Kiểm tra xem API trả về có dữ liệu không
        if (data["competitions"] != null && data["competitions"] is List) {
          return data["competitions"]; // Trả về danh sách giải đấu
        } else {
          throw Exception("API response format is incorrect!");
        }
      } else {
        throw Exception("Failed to fetch leagues: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching leagues: $e");
    }
  }
}
