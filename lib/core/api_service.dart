import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // URL gốc của API
  static const String baseUrl = "https://api.football-data.org/v4";
  // API Key cần thiết
  static const String apiKey = "fb803ef6ff50477e8ab94e0cfa3351a6";
  // Thời gian cache: 5 phút
  static const Duration cacheDuration = Duration(minutes: 5);
  // Thời gian chờ tối đa cho request
  static const Duration requestTimeout = Duration(seconds: 10);
  // Số lần thử lại khi request thất bại
  static const int maxRetries = 3;
  // Bật tắt in log để kiểm tra
  static const bool enableLogging = true;

  // Tạo một persistent HTTP client để tăng hiệu năng kết nối
  static final http.Client _client = http.Client();

  // Hàm nội bộ gửi HTTP GET với retry và cache
  static Future<Map<String, dynamic>> _getRequest(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final cacheKey = "cache_$endpoint";

    // Lấy instance của SharedPreferences để xử lý cache
    final prefs = await SharedPreferences.getInstance();

    // Kiểm tra cache có dữ liệu và dữ liệu đó chưa hết hạn
    final cachedData = prefs.getString(cacheKey);
    final cachedTime = prefs.getInt("${cacheKey}_time") ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    if (cachedData != null && (currentTime - cachedTime) < cacheDuration.inMilliseconds) {
      if (enableLogging) {
        print("Lấy dữ liệu từ cache: $endpoint");
      }
      return json.decode(cachedData);
    }

    int retryCount = 0;
    int delayMillis = 500; // Thời gian delay ban đầu cho retry
    while (retryCount < maxRetries) {
      try {
        // Gửi request với header hỗ trợ gzip để giảm kích thước response
        final response = await _client.get(
          url,
          headers: {
            "X-Auth-Token": apiKey,
            "Content-Type": "application/json",
            "Accept-Encoding": "gzip", // Yêu cầu nén gzip
          },
        ).timeout(requestTimeout, onTimeout: () {
          throw Exception("Hết thời gian chờ phản hồi từ server");
        });

        if (enableLogging) {
          print("GET $url");
          print("Response status: ${response.statusCode}");
          print("Response body: ${response.body}");
        }

        // Kiểm tra mã trạng thái của response
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          // Lưu dữ liệu vào cache với timestamp hiện tại
          await prefs.setString(cacheKey, json.encode(responseData));
          await prefs.setInt("${cacheKey}_time", currentTime);
          return responseData;
        } else if (response.statusCode == 403) {
          throw Exception("Lỗi 403: API Key không hợp lệ.");
        } else if (response.statusCode == 429) {
          throw Exception("Lỗi 429: Vượt quá giới hạn API.");
        } else {
          throw Exception("Lỗi API: ${response.statusCode}");
        }
      } catch (e) {
        // Nếu xảy ra lỗi, tăng retryCount và delay theo exponential backoff
        retryCount++;
        if (enableLogging) {
          print("Lỗi khi gọi API: $e. Thử lại $retryCount/$maxRetries sau ${delayMillis}ms.");
        }
        // Nếu đã đạt số lần retry tối đa, ném lỗi
        if (retryCount >= maxRetries) {
          throw Exception("Lỗi kết nối: $e");
        }
        // Delay theo exponential backoff
        await Future.delayed(Duration(milliseconds: delayMillis));
        delayMillis *= 2;
      }
    }
    // Nếu ra khỏi vòng lặp mà vẫn không thành công, ném lỗi chung
    throw Exception("Không thể lấy dữ liệu từ API sau $maxRetries lần thử.");
  }

  /// Lấy danh sách giải đấu
  static Future<List<dynamic>> fetchLeagues() async {
    final data = await _getRequest("/competitions");
    return data["competitions"] ?? [];
  }

  /// Lấy danh sách trận đấu theo giải đấu, chỉ lấy trận đấu từ năm 2025 trở đi
  static Future<List<dynamic>> fetchMatches(int leagueId) async {
    final data = await _getRequest("/competitions/$leagueId/matches");
    List<dynamic> matches = data["matches"] ?? [];
    return matches.where((match) {
      final matchDate = DateTime.parse(match["utcDate"]);
      return matchDate.year >= 2025;
    }).toList();
  }

  /// Lấy bảng xếp hạng của giải đấu
  static Future<Map<String, dynamic>> fetchStandings(int competitionId) async {
    return await _getRequest("/competitions/$competitionId/standings");
  }

  /// Lấy thông tin chi tiết của một trận đấu
  static Future<Map<String, dynamic>> fetchMatchDetail(int matchId) async {
    final data = await _getRequest("/matches/$matchId");
    // printLongString("data detail match: ${jsonEncode(data)}");
    return data;
  }

  /// Lấy thống kê trận đấu từ kết quả chi tiết
  static Future<Map<String, dynamic>> fetchMatchStats(int matchId) async {
    final data = await _getRequest("/matches/$matchId");

    printLongString("Match detail: ${jsonEncode(data)}");

    return data["match"]?["statistics"] ?? {};
  }


  static void printLongString(String text) {
    final pattern = RegExp('.{1,800}');
    for (final match in pattern.allMatches(text)) {
      print(match.group(0));
    }
  }

  static Future<Map<String, dynamic>> fetchTeamDetail(int teamId) async {
    final data = await _getRequest("/teams/$teamId");
    if (enableLogging) {
      // printLongString("Team data for team $teamId: ${json.encode(data)}");
    }
    return data ?? {};
  }

  /// Lấy lịch sử đối đầu (Head-to-Head) cho một trận đấu
  static Future<Map<String, dynamic>> fetchHeadToHead(int matchId) async {
    return await _getRequest("/matches/$matchId/head2head");
  }
}