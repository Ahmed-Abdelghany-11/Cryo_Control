import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/bluetooth_service.dart';
import 'control_state.dart';

class ControlCubit extends Cubit<ControlState> {
  final BluetoothService bluetoothService;

  ControlCubit(this.bluetoothService) : super(ControlState.initial());

  Future<void> setMode(bool isAuto) async {
    if (state.isSwitching) return;
    emit(state.copyWith(isSwitching: true, isAuto: isAuto));
    final modeCommand = isAuto ? 'MODE:AUTO' : 'MODE:MANUAL';
    await bluetoothService.sendCommand(modeCommand);
    if (!isAuto && state.speed > 0) {
      final speedCommand = 'SPEED:${(state.speed / 100 * 255).round()}';
      await bluetoothService.sendCommand(speedCommand);
    }
    await Future.delayed(const Duration(seconds: 3));
    emit(state.copyWith(isSwitching: false));
  }

  Future<void> setSpeed(double speed) async {
    if (state.isAuto) return;
    final speedCommand = 'SPEED:${(speed / 100 * 255).round()}';
    await bluetoothService.sendCommand(speedCommand);
    emit(state.copyWith(speed: speed));
  }
}
