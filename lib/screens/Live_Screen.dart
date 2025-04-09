import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/api_football.dart';
import '../models/live_match.dart';
import '../widgets/match/live_match_items.dart';

class LiveMatchesScreen extends StatefulWidget {
  const LiveMatchesScreen({Key? key}) : super(key: key);

  @override
  _LiveMatchesScreenState createState() => _LiveMatchesScreenState();
}

class _LiveMatchesScreenState extends State<LiveMatchesScreen> {
  late Future<List<LiveMatch>> _matchesFuture;
  Timer? _refreshTimer;
  bool _isLoading = false;
  bool _showUpcoming = false;
  DateTime _lastUpdated = DateTime.now();

  @override
  void initState() {
    super.initState();
    _matchesFuture = _loadMatches();
    _setupAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _setupAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isLoading && !_showUpcoming) {
        _loadMatches();
      }
    });
  }

  Future<List<LiveMatch>> _loadMatches() async {
    if (_isLoading) return [];

    setState(() {
      _isLoading = true;
      _lastUpdated = DateTime.now();
    });

    try {
      final matches = _showUpcoming
          ? await ApiFootball.getUpcomingMatches()
          : await ApiFootball.getLiveMatches();

      // Sort matches: live first, then by time
      matches.sort((a, b) {
        if (a.isLive && !b.isLive) return -1;
        if (!a.isLive && b.isLive) return 1;
        return a.matchDate.compareTo(b.matchDate);
      });

      // Only load events for live matches
      final matchesWithEvents = await Future.wait(
        matches.map((match) async {
          try {
            if (match.isLive) {
              final events = await ApiFootball.getMatchEvents(match.fixtureId);
              return match.copyWith(events: events);
            }
            return match;
          } catch (e) {
            return match;
          }
        }),
      );

      return matchesWithEvents;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_showUpcoming
                ? "Lỗi tải trận sắp diễn ra: ${e.toString()}"
                : "Lỗi tải trận trực tiếp: ${e.toString()}"),
            action: SnackBarAction(
              label: 'Thử lại',
              onPressed: () => _loadMatches(),
            ),
          ),
        );
      }
      rethrow;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleMatchType() {
    setState(() {
      _showUpcoming = !_showUpcoming;
      _matchesFuture = _loadMatches();
    });
  }

  void _refreshData() {
    setState(() {
      _matchesFuture = _loadMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_showUpcoming ? 'Trận Sắp Diễn Ra' : 'Trận Đấu Trực Tiếp'),
            Text(
              'Cập nhật: ${DateFormat('HH:mm').format(_lastUpdated)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_showUpcoming ? Icons.live_tv : Icons.event),
            onPressed: _isLoading ? null : _toggleMatchType,
            tooltip: _showUpcoming ? 'Xem trực tiếp' : 'Xem sắp diễn ra',
          ),
          IconButton(
            icon: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.black),
              ),
            )
                : const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshData,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: FutureBuilder<List<LiveMatch>>(
        future: _matchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorView();
          }

          final matches = snapshot.data ?? [];

          if (matches.isEmpty) {
            return _buildEmptyView();
          }

          return _buildMatchList(matches);
        },
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: _refreshData,
        tooltip: 'Làm mới',
        child: _isLoading
            ? const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.black),
        )
            : const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            _showUpcoming
                ? 'Lỗi khi tải trận sắp diễn ra'
                : 'Lỗi khi tải trận trực tiếp',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            onPressed: _refreshData,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showUpcoming ? Icons.event_available : Icons.live_tv,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _showUpcoming
                ? 'Không có trận đấu sắp diễn ra'
                : 'Không có trận đấu trực tiếp',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Tải lại'),
            onPressed: _refreshData,
          ),
        ],
      ),
    );
  }

  Widget _buildMatchList(List<LiveMatch> matches) {
    return RefreshIndicator(
      onRefresh: () async => _refreshData(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng số: ${matches.length} trận',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  _showUpcoming
                      ? 'Trong 2 ngày tới'
                      : 'Đang diễn ra',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: matches.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final match = matches[index];
                return LiveMatchItem(
                  match: match,
                  showAsUpcoming: _showUpcoming,
                  onTap: () {
                    // TODO: Handle match tap
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}