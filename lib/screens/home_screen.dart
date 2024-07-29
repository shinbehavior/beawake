import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/event_manager.dart';
import 'package:health/health.dart';
import '../screens/sleep_history.dart';

class HomeScreen extends ConsumerWidget {
  final String userId;

  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventManager = ref.watch(eventManagerProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      eventManager.setUserId(userId);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Data'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SleepHistoryScreen(userId: userId),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2C), Color(0xFF2C2C38)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () => eventManager.requestHealthAuthorization(),
                child: const Text('Sync Health Data'),
              ),
              const SizedBox(height: 20),
              Expanded(child: RecentSleepSummary()),
            ],
          ),
        ),
      ),
    );
  }
}

class RecentSleepSummary extends ConsumerWidget {
  String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  String formatDate(DateTime dateTime) {
    return DateFormat('MMM dd').format(dateTime);
  }

  String _formatDuration(Duration duration) {
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventManager = ref.watch(eventManagerProvider);
    
    if (eventManager.healthEvents.isEmpty) {
      return Center(child: Text('No sleep data available', style: TextStyle(color: Colors.white)));
    }

    // Get the most recent sleep session
    final sleepEvents = eventManager.healthEvents.where((e) => e.type == HealthDataType.SLEEP_ASLEEP).toList();
    final awakeEvents = eventManager.healthEvents.where((e) => e.type == HealthDataType.SLEEP_AWAKE).toList();

    if (sleepEvents.isEmpty || awakeEvents.isEmpty) {
      return Center(child: Text('Incomplete sleep data', style: TextStyle(color: Colors.white)));
    }

    final lastSleep = sleepEvents.first;
    final lastAwake = awakeEvents.first;
    final sleepDuration = lastAwake.dateFrom.difference(lastSleep.dateFrom);

    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Night\'s Sleep',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Date: ${formatDate(lastSleep.dateFrom)}',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Sleep Time: ${formatTime(lastSleep.dateFrom)}',
              style: TextStyle(color: Colors.blue, fontSize: 18),
            ),
            Text(
              'Wake Time: ${formatTime(lastAwake.dateFrom)}',
              style: TextStyle(color: Colors.orange, fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Total Sleep: ${_formatDuration(sleepDuration)}',
              style: TextStyle(color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}