import 'package:flutter/material.dart';

class MatchOdds extends StatelessWidget {
  final Future<Map<String, dynamic>?> oddsFuture;

  const MatchOdds({Key? key, required this.oddsFuture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: oddsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text("Không có dữ liệu tỷ lệ cược"));
        }

        final odds = snapshot.data!;
        final bets = odds["bets"];

        // Tìm market 1X2 (Kết quả chính)
        final mainMarket = bets?.firstWhere(
              (bet) => bet["name"] == "Match Winner",
          orElse: () => null,
        );

        if (mainMarket == null) {
          return const Center(child: Text("Không có tỷ lệ cược chính"));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tỷ lệ cược chính",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildOddRow("Thắng (1)", mainMarket["values"][0]["odd"]),
              _buildOddRow("Hòa (X)", mainMarket["values"][1]["odd"]),
              _buildOddRow("Thua (2)", mainMarket["values"][2]["odd"]),
              const SizedBox(height: 24),
              const Text(
                "Tỷ lệ cược khác",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._buildOtherOdds(bets),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOddRow(String label, String odd) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(odd, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  List<Widget> _buildOtherOdds(List<dynamic>? bets) {
    if (bets == null) return [];

    final otherMarkets = bets.where((bet) => bet["name"] != "Match Winner").toList();

    return otherMarkets.map((market) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            market["name"],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ...market["values"].map<Widget>((value) {
            return _buildOddRow(value["value"], value["odd"]);
          }).toList(),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }
}