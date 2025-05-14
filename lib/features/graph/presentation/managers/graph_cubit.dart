import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/bluetooth_service.dart';

class GraphCubit extends Cubit<List<double>> {
  final BluetoothService bluetoothService;
  late StreamSubscription _subscription;

  GraphCubit(this.bluetoothService) : super([]) {
    _subscription = bluetoothService.dataStream.listen((data) {
      if (data.startsWith('TEMP:')) {
        final tempStr = data.substring(5);
        final temp = double.tryParse(tempStr);
        if (temp != null) {
          emit([...state, temp]);
        }
      }
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
