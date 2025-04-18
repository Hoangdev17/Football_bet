import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:5000/api/auth';
  static const String matchesUrl = 'http://localhost:5000/api/matches';

  // Đăng ký người dùng
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Email': email,
        'Password': password,
        'Username': username,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Đăng ký thất bại: ${response.body}');
    }
  }

  // Đăng nhập
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Email': email,
        'Password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Lưu token vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['token']);
      return data;
    } else {
      throw Exception('Đăng nhập thất bại: ${response.body}');
    }
  }

  // Lấy token từ SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Đăng xuất
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Thêm trận đấu yêu thích
  static Future<void> addFavoriteMatch({
    required String matchId,
    required String homeTeam,
    required String awayTeam,
    required String matchDate,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Chưa đăng nhập');

    final response = await http.post(
      Uri.parse('$matchesUrl/favorite'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'matchIdFromAPI': matchId,
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        'matchDate': matchDate,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Thêm trận đấu yêu thích thất bại: ${response.body}');
    }
  }

  // Xóa trận đấu yêu thích
  static Future<void> removeFavoriteMatch(String matchId) async {
    final token = await getToken();
    if (token == null) throw Exception('Chưa đăng nhập');
    final response = await http.delete(
      Uri.parse('$matchesUrl/favorite/$matchId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Xóa trận đấu yêu thích thất bại: ${response.body}');
    }
  }

  // Lấy danh sách trận đấu yêu thích
  static Future<List<dynamic>> getFavoriteMatches() async {
    final token = await getToken();
    if (token == null) throw Exception('Chưa đăng nhập');

    final response = await http.get(
      Uri.parse('$matchesUrl/favorites'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Lấy danh sách yêu thích thất bại: ${response.body}');
    }
  }
}