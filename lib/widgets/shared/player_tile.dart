import 'package:flutter/material.dart';

class PlayerTile extends StatelessWidget {
  final Map<String, dynamic> player;

  const PlayerTile({required this.player, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green,
        child: Text(player["shirtNumber"]?.toString() ?? "-"),
      ),
      title: Text(player["name"] ?? "Không rõ"),
      subtitle: Text(_translatePosition(player["position"] ?? "Không rõ")),
    );
  }

  String _translatePosition(String position) {
    switch (position) {
      case "Goalkeeper":
        return "Thủ môn";
      case "Defender":
        return "Hậu vệ";
      case "Midfielder":
        return "Tiền vệ";
      case "Attacker":
        return "Tiền đạo";
      default:
        return position;
    }
  }
}