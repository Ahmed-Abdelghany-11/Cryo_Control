import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/bluetooth_service.dart';
import 'control_state.dart';

class ControlCubit extends Cubit<ControlState> {
  final BluetoothService bluetoothService;
  double _localSpeed = 0;

  ControlCubit(this.bluetoothService) : super(ControlState.initial()) {
    // Listen to data from Arduino
    bluetoothService.dataStream.listen((data) {
      if (data.startsWith('MODE:')) {
        final newModeStr = data.substring(5).trim().toUpperCase();
        final Mode? newMode =
            {
              'IDLE': Mode.idle,
              'AUTO': Mode.auto,
              'MANUAL': Mode.manual,
            }[newModeStr];

        if (newMode != null && newMode != state.mode && !state.isSwitching) {
          emit(state.copyWith(mode: newMode));
        }
      } else if (data.startsWith('SPEED:')) {
        final value = int.tryParse(data.substring(6).trim());
        if (value != null) {
          final speed = (value / 255 * 100).clamp(0, 100).toDouble();
          _localSpeed = speed;
          emit(state.copyWith(speed: speed));
        }
      }
    });
  }

  /// User tapped a radio; send the mode command 5×, then unlock after 5s.
  Future<void> setMode(Mode newMode) async {
    if (state.isSwitching || state.mode == newMode) return;
    emit(state.copyWith(isSwitching: true, mode: newMode));

    final modeStr =
        newMode == Mode.auto
            ? 'AUTO'
            : newMode == Mode.manual
            ? 'MANUAL'
            : 'IDLE';
    final cmd = 'MODE:$modeStr';

    await bluetoothService.sendCommand(cmd);

    // if switching into Manual & we already have a speed > 0, re-send speed
    if (newMode == Mode.manual && _localSpeed > 0) {
      final val = (_localSpeed / 100 * 255).round();
      final speedCmd = 'SPEED:$val';
      await bluetoothService.sendCommand(speedCmd);
    }

    // lock out for 5 seconds before allowing next toggle
    await Future.delayed(const Duration(seconds: 5));
    emit(state.copyWith(isSwitching: false));
  }

  /// Internal UI update while sliding
  void updateLocalSpeed(double uiValue) {
    _localSpeed = uiValue;
    emit(state.copyWith(speed: uiValue));
  }

  /// Called on slider release: send SPEED once (but 5× for reliability)
  Future<void> setSpeed(double uiValue) async {
    if (state.mode != Mode.manual) return;
    _localSpeed = uiValue;
    emit(state.copyWith(speed: uiValue));

    final val = (uiValue / 100 * 255).round();
    final cmd = 'SPEED:$val';

    await bluetoothService.sendCommand(cmd);
  }
}
