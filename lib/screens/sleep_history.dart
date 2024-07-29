import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_manager.dart';
import '../models/awake_sleep_event.dart';
import 'package:intl/intl.dart';

class SleepHistoryScreen extends ConsumerWidget {
  final String userId;
  const SleepHistoryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventManager = ref.watch(eventManagerProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: Text('Sleep History', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildSleepHistory(eventManager.healthEvents),
    );
  }

  Widget _buildSleepHistory(List<Event> events) {
    if (events.isEmpty) {
      return Center(child: Text('No sleep history available', style: TextStyle(color: Colors.white)));
    }
    // Group events by date
    Map<String, List<Event>> groupedEvents = {};
    for (var event in events) {
      String date = DateFormat('yyyy-MM-dd').format(DateTime.parse(event.timestamp));
      if (!groupedEvents.containsKey(date)) {
        groupedEvents[date] = [];
      }
      groupedEvents[date]!.add(event);
    }
    return ListView.builder(
      itemCount: groupedEvents.length,
      itemBuilder: (context, index) {
        String date = groupedEvents.keys.elementAt(index);
        List<Event> dayEvents = groupedEvents[date]!;
        return _buildDayCard(date, dayEvents);
      },
    );
  }

  Widget _buildDayCard(String date, List<Event> events) {
    Event? sleepEvent = events.cast<Event?>().firstWhere(
      (e) => e?.type == 'sleep',
      orElse: () => null
    );
    Event? awakeEvent = events.cast<Event?>().firstWhere(
      (e) => e?.type == 'awake',
      orElse: () => null
    );

    return Card(
      color: Color(0xFF2C2C38),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, MMMM d').format(DateTime.parse(date)),
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            if (sleepEvent != null)
              _buildEventRow('Sleep', sleepEvent, Icons.nightlight_round),
            if (awakeEvent != null)
              _buildEventRow('Wake', awakeEvent, Icons.wb_sunny),
            if (sleepEvent != null && awakeEvent != null)
              _buildSleepDuration(sleepEvent, awakeEvent),
          ],
        ),
      ),
    );
  }

  Widget _buildEventRow(String label, Event event, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            '$label: ${DateFormat('HH:mm').format(DateTime.parse(event.timestamp))}',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepDuration(Event sleep, Event awake) {
    Duration difference = DateTime.parse(awake.timestamp).difference(DateTime.parse(sleep.timestamp));
    String duration = '${difference.inHours}h ${difference.inMinutes % 60}m';
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Text(
        'Sleep Duration: $duration',
        style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}