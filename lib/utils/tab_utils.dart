import 'package:flutter/material.dart';

class TabUtils {
  static Widget buildTabContent({
    required Future<dynamic> future,
    required Widget Function(dynamic data) builder,
    String? emptyMessage,
    String? errorMessage,
  }) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        // Trạng thái loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        // Trạng thái lỗi
        if (snapshot.hasError) {
          return _buildErrorState(errorMessage ?? 'Lỗi: ${snapshot.error}');
        }

        // Trạng thái không có dữ liệu
        if (!snapshot.hasData) {
          return _buildEmptyState(emptyMessage ?? 'Không có dữ liệu');
        }

        // Trạng thái thành công
        return builder(snapshot.data!);
      },
    );
  }

  static Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  static Widget _buildErrorState(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  static Widget _buildEmptyState(String message) {
    return Center(
      child: Text(message),
    );
  }
}