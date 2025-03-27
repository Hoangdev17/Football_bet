import 'package:flutter/material.dart';

class FutureHandler extends StatelessWidget {
  final AsyncSnapshot snapshot;
  final Widget successWidget;
  final String? errorMessage;
  final String? emptyMessage;

  const FutureHandler({
    required this.snapshot,
    required this.successWidget,
    this.errorMessage,
    this.emptyMessage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(child: Text(errorMessage ?? 'Lỗi: ${snapshot.error}'));
    }
    if (!snapshot.hasData || snapshot.data == null) {
      return Center(child: Text(emptyMessage ?? 'Không có dữ liệu'));
    }
    return successWidget;
  }
}