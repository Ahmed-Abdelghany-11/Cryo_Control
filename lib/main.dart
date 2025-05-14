import 'package:cryo_control/features/home/presentation/view/screen/connect_screen.dart';
import 'package:cryo_control/features/home/presentation/view/screen/home_screen.dart';
import 'package:flutter/material.dart';

import 'core/utils/bluetooth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cryo Control',
      debugShowCheckedModeBanner: false,
      home: const ConnectScreen(),
    );
  }
}
