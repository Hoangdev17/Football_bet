import 'package:flutter/material.dart';
import '../../models/live_match.dart';

class LiveMatchItem extends StatelessWidget {
  final LiveMatch match;
  final VoidCallback onTap;
  final bool showAsUpcoming;

  const LiveMatchItem({
    Key? key,
    required this.match,
    required this.onTap,
    this.showAsUpcoming = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // League info
              _buildLeagueInfo(),
              const SizedBox(height: 12),

              // Match teams and score
              _buildMatchInfo(),

              // Events (only for live matches)
              if (match.events.isNotEmpty && !showAsUpcoming)
                _buildEventsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeagueInfo() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            match.leagueLogo,
            width: 24,
            height: 24,
            errorBuilder: (_, __, ___) => const Icon(Icons.sports_soccer, size: 24),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            match.leagueName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMatchInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Home team
        _buildTeamInfo(match.homeTeam, match.homeLogo),

        // Score and time
        Column(
          children: [
            Text(
              "${match.homeGoals} - ${match.awayGoals}",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(match.status),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                showAsUpcoming ? match.matchTime : _getStatusText(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        // Away team
        _buildTeamInfo(match.awayTeam, match.awayLogo),
      ],
    );
  }

  Widget _buildTeamInfo(String teamName, String logoUrl) {
    return Expanded(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network(
              logoUrl,
              width: 48,
              height: 48,
              errorBuilder: (_, __, ___) => const Icon(Icons.people, size: 48),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            teamName,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection() {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: match.events.length,
            itemBuilder: (ctx, index) {
              final event = match.events[index];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.time,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(event.eventIcon),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 80,
                          child: Text(
                            event.playerName,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "1H":
      case "2H":
        return Colors.green;
      case "HT":
        return Colors.orange;
      case "ET":
      case "P":
        return Colors.purple;
      case "NS":
        return Colors.blue;
      case "FT":
        return Colors.grey;
      case "PST":
      case "CANC":
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  String _getStatusText() {
    switch (match.status) {
      case "1H":
        return "Hiệp 1 ${match.elapsedTime ?? ''}'";
      case "2H":
        return "Hiệp 2 ${match.elapsedTime ?? ''}'";
      case "HT":
        return "Nghỉ giữa hiệp";
      case "ET":
        return "Hiệp phụ ${match.elapsedTime ?? ''}'";
      case "P":
        return "Penalty";
      case "FT":
        return "Kết thúc";
      case "NS":
        return "Sắp diễn ra";
      case "PST":
        return "Hoãn";
      case "CANC":
        return "Hủy";
      default:
        return match.status;
    }
  }
}