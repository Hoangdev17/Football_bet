import 'package:flutter/material.dart';

class MatchScoreboard extends StatelessWidget {
  final Map<String, dynamic> homeTeam;
  final Map<String, dynamic> awayTeam;
  final String homeScore;
  final String awayScore;

  const MatchScoreboard({
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.green[800],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTeamColumn(homeTeam["crest"], homeTeam["name"], teamColor: Colors.green),
          _buildScoreDisplay(homeScore, awayScore),
          _buildTeamColumn(awayTeam["crest"], awayTeam["name"], teamColor: Colors.blue),
        ],
      ),
    );
  }

  Widget _buildTeamColumn(String logoUrl, String teamName, {Color teamColor = Colors.white}) {
    return Column(
      children: [
        _buildTeamLogo(logoUrl),
        const SizedBox(height: 4),
        _buildTeamName(teamName, teamColor: teamColor),
      ],
    );
  }

  Widget _buildScoreDisplay(String homeScore, String awayScore) {
    return Text(
      "$homeScore - $awayScore",
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTeamLogo(String logoUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        logoUrl,
        width: 50,
        height: 50,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.image_not_supported,
          size: 50,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTeamName(String teamName, {Color teamColor = Colors.white}) {
    return SizedBox(
      width: 80,
      child: Text(
        teamName,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: teamColor,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}