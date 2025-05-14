import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/bluetooth_service.dart';

class GraphCubit extends Cubit<List<double>> {
  static const _storageKey = 'saved_temperatures';

  final BluetoothService bluetoothService;
  late final StreamSubscription _subscription;

  GraphCubit(this.bluetoothService) : super([]) {
    _loadSavedData();
    _subscription = bluetoothService.dataStream.listen(_onData);
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedJson = prefs.getString(_storageKey);
    if (savedJson != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(savedJson);
        final temps = jsonList
            .map((e) => (e as num).toDouble())
            .toList(growable: false);
        emit(temps);
      } catch (_) {
        // if parsing fails, just start empty
        emit([]);
      }
    }
  }

  void _onData(String data) {
    if (data.startsWith('TEMP:')) {
      final tempStr = data.substring(5).trim();
      final temp = double.tryParse(tempStr);
      if (temp != null) {
        final updated = List<double>.from(state)..add(temp);
        emit(updated);
        _saveData(updated);
      }
    }
  }

  Future<void> _saveData(List<double> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(list);
    await prefs.setString(_storageKey, jsonString);
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
