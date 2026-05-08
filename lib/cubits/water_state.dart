import 'package:lab1_water/models/water_record.dart';

abstract class WaterState {
  const WaterState();
}

class WaterLoading extends WaterState {
  const WaterLoading();
}

class WaterLoaded extends WaterState {
  final List<WaterRecord> history;
  final int currentIntake;
  final String currentTemp;

  const WaterLoaded({
    required this.history,
    required this.currentIntake,
    required this.currentTemp,
  });

  WaterLoaded copyWith({
    List<WaterRecord>? history,
    int? currentIntake,
    String? currentTemp,
  }) {
    return WaterLoaded(
      history: history ?? this.history,
      currentIntake: currentIntake ?? this.currentIntake,
      currentTemp: currentTemp ?? this.currentTemp,
    );
  }
}

class WaterError extends WaterState {
  final String message;
  const WaterError(this.message);
}
