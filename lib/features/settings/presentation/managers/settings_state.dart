import 'dart:ui';

import 'package:flutter/material.dart';

class SettingsState {
  final bool receiveTemp;
  final bool isSwitching;
  final bool showWaitToast;
  final String toastMessage;
  final Color toastColor;

  SettingsState({
    required this.receiveTemp,
    required this.isSwitching,
    this.showWaitToast = false,
    this.toastMessage = '',
    this.toastColor = Colors.green,
  });

  factory SettingsState.initial() =>
      SettingsState(receiveTemp: false, isSwitching: false);

  SettingsState copyWith({
    bool? receiveTemp,
    bool? isSwitching,
    bool? showWaitToast,
    String? toastMessage,
    Color? toastColor,
  }) {
    return SettingsState(
      receiveTemp: receiveTemp ?? this.receiveTemp,
      isSwitching: isSwitching ?? this.isSwitching,
      showWaitToast: showWaitToast ?? false,
      toastMessage: toastMessage ?? '',
      toastColor: toastColor ?? this.toastColor,
    );
  }
}
