import 'dart:async';
import 'package:flutter/services.dart';

class BluetoothService {
  static const MethodChannel _methodChannel = MethodChannel(
    'com.example.cryo_control/bluetooth',
  );
  static const EventChannel _eventChannel = EventChannel(
    'com.example.cryo_control/bluetooth_data',
  );
  final StreamController<String> _dataStreamController =
      StreamController.broadcast();
  Stream<String> get dataStream => _dataStreamController.stream;
  late StreamSubscription _subscription;

  Future<bool> isBluetoothEnabled() async {
    return await _methodChannel.invokeMethod<bool>('isBluetoothEnabled') ??
        false;
  }

  Future<void> connect(String address) async {
    try {
      final connected = await _methodChannel.invokeMethod<bool>(
        'connectToDevice',
        {'address': address},
      );
      if (connected == true) {
        _subscription = _eventChannel.receiveBroadcastStream().listen(
          (data) => _dataStreamController.add(data.toString()),
          onError: (error) => _dataStreamController.addError(error),
        );
      } else {
        throw Exception('Connection failed');
      }
    } catch (e) {
      throw Exception('Failed to connect: $e');
    }
  }

  Future<void> disconnect() async {
    try {
      await _methodChannel.invokeMethod('disconnect');
      _subscription.cancel();
      _dataStreamController.close();
    } catch (e) {
      throw Exception('Failed to disconnect: $e');
    }
  }

  Future<void> sendCommand(String command) async {
    try {
      for (int i = 0; i < 5; i++) {
        await _methodChannel.invokeMethod('sendCommand', {
          'command': '$command\\n',
        });
        await Future.delayed(const Duration(milliseconds: 400));
      }
    } catch (e) {
      throw Exception('Failed to send command: $e');
    }
  }
}
