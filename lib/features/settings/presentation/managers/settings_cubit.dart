import 'package:cryo_control/features/settings/presentation/managers/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/bluetooth_service.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final BluetoothService bluetoothService;

  SettingsCubit(this.bluetoothService) : super(SettingsState.initial());

  void toggleReceiveTemperature() {
    if (state.isSwitching) {
      emit(state.copyWith(showWaitToast: true));
      return;
    }
    _setReceive(!state.receiveTemp);
  }

  Future<void> _setReceive(bool value) async {
    emit(state.copyWith(isSwitching: true));
    final command = value ? 'TEMP:ON' : 'TEMP:OFF';
    await bluetoothService.sendCommand(command);
    emit(state.copyWith(receiveTemp: value));

    // lock out for 5 seconds
    await Future.delayed(const Duration(seconds: 5));
    emit(state.copyWith(isSwitching: false));
  }

  void clearWaitToast() {
    emit(state.copyWith());
  }

  void clearToast() {
    emit(state.copyWith());
  }

  Future<void> disconnectAndNotify() async {
    try {
      await bluetoothService.disconnect();
      emit(
        state.copyWith(toastMessage: 'Disconnected', toastColor: Colors.green),
      );
    } catch (e) {
      emit(
        state.copyWith(
          toastMessage: 'Error disconnecting: \$e',
          toastColor: Colors.red,
        ),
      );
    }
  }
}
