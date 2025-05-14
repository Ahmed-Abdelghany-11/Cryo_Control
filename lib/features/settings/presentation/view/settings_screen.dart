import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../core/utils/bluetooth_service.dart';
import '../managers/settings_cubit.dart';
import '../managers/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  final BluetoothService bluetoothService = BluetoothService();

  SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(bluetoothService),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocConsumer<SettingsCubit, SettingsState>(
            listenWhen:
                (prev, curr) =>
                    curr.showWaitToast || curr.toastMessage.isNotEmpty,
            listener: (context, state) {
              if (state.showWaitToast) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please wait...'),
                    duration: Duration(seconds: 1),
                  ),
                );
                context.read<SettingsCubit>().clearWaitToast();
              }
              if (state.toastMessage.isNotEmpty) {
                Fluttertoast.showToast(
                  msg: state.toastMessage,
                  backgroundColor: state.toastColor,
                );
                context.read<SettingsCubit>().clearToast();
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      title: const Text(
                        'Receive Temperature Data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      value: state.receiveTemp,
                      activeColor: Colors.white,
                      activeTrackColor: Colors.blueAccent,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.shade300,
                      onChanged:
                          (_) =>
                              context
                                  .read<SettingsCubit>()
                                  .toggleReceiveTemperature(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Disconnect',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        () =>
                            context.read<SettingsCubit>().disconnectAndNotify(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
