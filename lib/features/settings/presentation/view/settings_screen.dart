import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../managers/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, bool>(
      builder: (context, receiveTemperature) {
        return Center(
          child: SwitchListTile(
            title: const Text(
              'Receive Temperature Data',
              style: TextStyle(color: Colors.white),
            ),
            value: receiveTemperature,
            activeColor: Colors.blueAccent,
            inactiveThumbColor: Colors.grey,
            onChanged: (value) {
              context.read<SettingsCubit>().setReceiveTemperature(value);
            },
          ),
        );
      },
    );
  }
}
