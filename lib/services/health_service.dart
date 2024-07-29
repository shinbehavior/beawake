import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthService {
  final Health _health = Health();
  
  Future<bool> requestAuthorization() async {
    await Permission.activityRecognition.request();
    await Permission.location.request();

    final types = [
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_AWAKE,
      HealthDataType.SLEEP_IN_BED,
    ];
    final permissions = types.map((e) => HealthDataAccess.READ).toList();

    return await _health.requestAuthorization(types, permissions: permissions);
  }

  Future<List<HealthDataPoint>> fetchSleepData() async {
    final now = DateTime.now();
    final lastWeek = now.subtract(Duration(days: 7));

    final types = [
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_AWAKE,
      HealthDataType.SLEEP_IN_BED,
    ];

    return await _health.getHealthDataFromTypes(startTime: lastWeek, endTime: now, types: types);
  }
}