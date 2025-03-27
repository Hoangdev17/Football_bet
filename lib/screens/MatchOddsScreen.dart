import 'package:flutter/material.dart';
import '../core/odd_service.dart';

class OddsTab extends StatefulWidget {
  final Map<String, dynamic> matchData;

  const OddsTab({super.key, required this.matchData});

  @override
  _OddsTabState createState() => _OddsTabState();
}

class _OddsTabState extends State<OddsTab> {
  late Future<Map<String, dynamic>?> _oddsData;
  String oddsFormat = 'decimal';

  @override
  void initState() {
    super.initState();
    _oddsData = fetchOdds();
  }

  Future<Map<String, dynamic>?> fetchOdds() async {
    final homeTeam = widget.matchData["homeTeam"]?["name"] as String? ?? "Unknown";
    final awayTeam = widget.matchData["awayTeam"]?["name"] as String? ?? "Unknown";
    final matchStartTime = DateTime.tryParse(widget.matchData["utcDate"] as String? ?? "") ?? DateTime.now();
    final competitionTitle = widget.matchData["competition"]?["name"] as String? ?? "Unknown";
    final areaCode = widget.matchData["competition"]?["areaCode"] as String? ?? "ENG"; // Sửa lỗi lấy areaCode

    print('Fetching odds for: $homeTeam vs $awayTeam, Competition: $competitionTitle, Area: $areaCode');

    try {
      return await OddsService().fetchOddsForMatch(
        sportKey: competitionTitle,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        matchStartTime: matchStartTime,
        areaCode: areaCode,
        oddsFormat: oddsFormat,
      );
    } catch (e) {
      print("Error fetching odds: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  oddsFormat = 'decimal';
                  _oddsData = fetchOdds();
                });
              },
              child: const Text('Decimal'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  oddsFormat = 'american';
                  _oddsData = fetchOdds();
                });
              },
              child: const Text('American'),
            ),
          ],
        ),
        Expanded(
          child: FutureBuilder<Map<String, dynamic>?>( // Xử lý dữ liệu có thể null
            future: _oddsData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Lỗi: ${snapshot.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _oddsData = fetchOdds();
                          });
                        },
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('Không có dữ liệu tỉ lệ cược'));
              }

              final matchOdds = snapshot.data!;
              final bookmakers = matchOdds['bookmakers'] as List<dynamic>? ?? [];

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    '${widget.matchData["homeTeam"]["name"]} vs ${widget.matchData["awayTeam"]["name"]}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (bookmakers.isNotEmpty)
                    ...bookmakers.map((bookmaker) {
                      final markets = bookmaker['markets'] as List<dynamic>? ?? [];
                      if (markets.isEmpty) return const SizedBox(); // Tránh lỗi index out of range

                      final outcomes = markets[0]['outcomes'] as List<dynamic>? ?? [];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bookmaker['title'] ?? 'Unknown Bookmaker',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Home: ${outcomes.isNotEmpty ? outcomes[0]['price'] : '-'}'),
                                  Text('Draw: ${outcomes.length > 2 ? outcomes[2]['price'] : '-'}'),
                                  Text('Away: ${outcomes.length > 1 ? outcomes[1]['price'] : '-'}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList()
                  else
                    const Center(child: Text('Không có nhà cái nào có tỷ lệ cược')),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
