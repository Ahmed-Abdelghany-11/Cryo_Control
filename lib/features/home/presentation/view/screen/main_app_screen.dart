import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MainAppScreen extends StatelessWidget {
  final Future<void> Function() onDisconnect;
  static const _platform = MethodChannel('com.example.cryo_control/bluetooth');

  const MainAppScreen({super.key, required this.onDisconnect});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // first call your Dart-side cleanup
      await onDisconnect();

      // then invoke native disconnect (just in case)
      await _platform.invokeMethod('disconnect');

      Fluttertoast.showToast(
        msg: "Disconnected",
        backgroundColor: Colors.orange,
      );
    } on PlatformException catch (e) {
      Fluttertoast.showToast(
        msg: "Error disconnecting: ${e.message}",
        backgroundColor: Colors.red,
      );
    } finally {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CoolFan Main App"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Disconnect',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[900]!, Colors.blueAccent.withOpacity(0.3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: Text(
            "Welcome to CoolFan App!\nConnected to ARDUINOBT.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
