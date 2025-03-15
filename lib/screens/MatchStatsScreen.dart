import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_service.dart';

class MatchStatsScreen extends StatefulWidget {
  final int matchId;

  const MatchStatsScreen({super.key, required this.matchId});

  @override
  _MatchStatsScreenState createState() => _MatchStatsScreenState();
}

class _MatchStatsScreenState extends State<MatchStatsScreen> {
  late Future<Map<String, dynamic>> _matchStats;

  @override
  void initState() {
    super.initState();
    _matchStats = fetchMatchStats(widget.matchId);
  }

  Future<Map<String, dynamic>> fetchMatchStats(int matchId) async {
    return await ApiService.fetchMatchStats(matchId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match Stats')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _matchStats,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final stats = snapshot.data?['matchStatistics'];

          if (stats == null || stats.isEmpty) {
            return const Center(child: Text('No statistics available', style: TextStyle(fontSize: 18)));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatRow('Possession', stats['possession']),
              _buildStatRow('Total Shots', stats['totalShots']),
              _buildStatRow('Shots on Target', stats['shotsOnTarget']),
              _buildStatRow('Passes', stats['totalPasses']),
              _buildStatRow('Fouls', stats['fouls']),
              _buildStatRow('Yellow Cards', stats['yellowCards']),
              _buildStatRow('Red Cards', stats['redCards']),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value?.toString() ?? 'N/A', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
