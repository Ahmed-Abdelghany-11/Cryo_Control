import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/bluetooth_service.dart';

class SettingsCubit extends Cubit<bool> {
  final BluetoothService bluetoothService;

  SettingsCubit(this.bluetoothService) : super(false);

  Future<void> setReceiveTemperature(bool value) async {
    final command = value ? 'TEMP:ON' : 'TEMP:OFF';
    for (int i = 0; i < 5; i++) {
      await bluetoothService.sendCommand(command);
    }
    emit(value);
  }
}
