import 'package:flutter/material.dart';

class TeamInfo extends StatelessWidget {
  final Map<String, dynamic> team;
  final Color textColor; // Thêm tham số này

  const TeamInfo({
    required this.team,
    this.textColor = Colors.black, // Giá trị mặc định
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(
          team["crest"] ?? "",
          width: 50,
          height: 50,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.sports_soccer, size: 50, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          team["name"] ?? "Không rõ",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor, // Sử dụng tham số màu
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}