import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab1_water/cubits/water_state.dart';
import 'package:lab1_water/models/water_record.dart';
import 'package:lab1_water/repositories/water_repository.dart';
import 'package:lab1_water/services/mqtt_service.dart';

class WaterCubit extends Cubit<WaterState> {
  final WaterRepository _repository;
  final MqttService _mqttService = MqttService();
  StreamSubscription<String>? _mqttSubscription;

  WaterCubit(this._repository) : super(const WaterLoading()) {
    _initMqtt();
  }

Future<void> _initMqtt() async {
    await _mqttService.connect();
    _mqttSubscription = _mqttService.tempStream.listen((String temp) {
      if (state is WaterLoaded) {
        final WaterLoaded currentState = state as WaterLoaded;
        emit(currentState.copyWith(currentTemp: temp));
      }
    });
  }

  Future<void> loadData() async {
    emit(const WaterLoading());
    try {
      final List<WaterRecord> history = await _repository.getWaterHistory();

      int total = 0;
      for (final WaterRecord record in history) {
        total += record.amount;
      }

      emit(
        WaterLoaded(
          history: history,
          currentIntake: total,
          currentTemp: '21', 
        ),
      );
    } catch (e) {
      emit(WaterError(e.toString()));
    }
  }

  void addWater(int amount) {
    if (state is WaterLoaded) {
      final WaterLoaded currentState = state as WaterLoaded;
      
      final DateTime now = DateTime.now();
      final String timeStr = 
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}';

      final WaterRecord newRecord = WaterRecord(
        id: now.millisecondsSinceEpoch.toString(),
        amount: amount,
        time: timeStr,
      );

      final List<WaterRecord> updatedHistory = <WaterRecord>[
        newRecord,
        ...currentState.history,
      ];

      final int newTotal = currentState.currentIntake + amount;

      emit(
        currentState.copyWith(
          history: updatedHistory,
          currentIntake: newTotal,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _mqttSubscription?.cancel();
    _mqttService.disconnect();
    return super.close();
  }
}
