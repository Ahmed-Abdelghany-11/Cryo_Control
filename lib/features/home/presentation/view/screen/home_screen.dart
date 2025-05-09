import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

import 'main_app_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _platform = MethodChannel('com.example.cryo_control/bluetooth');
  bool isLoading = false;
  bool isBluetoothEnabled = false;
  final String arduinobtAddress = "00:22:06:01:97:D3"; // Replace with your MAC

  @override
  void initState() {
    super.initState();
    _checkBluetooth();
  }

  Future<void> _checkBluetooth() async {
    setState(() => isLoading = true);
    try {
      bool isEnabled = await _platform.invokeMethod('isBluetoothEnabled');
      if (!isEnabled) {
        Fluttertoast.showToast(
          msg: "Please enable Bluetooth",
          backgroundColor: Colors.red,
        );
        return;
      }
      await _requestPermissions();
      setState(() => isBluetoothEnabled = true);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Initialization failed: $e",
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses =
        await [
          Permission.bluetooth,
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.location,
        ].request();

    if (statuses.values.any((s) => !s.isGranted)) {
      Fluttertoast.showToast(
        msg: "Please grant all required permissions",
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _connectToDevice() async {
    if (!isBluetoothEnabled) {
      Fluttertoast.showToast(
        msg: "Bluetooth is disabled",
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      Fluttertoast.showToast(
        msg: "Connecting to ARDUINOBT...",
        backgroundColor: Colors.orange,
      );
      final connected = await _platform.invokeMethod<bool>('connectToDevice', {
        'address': arduinobtAddress,
      });
      if (connected == true) {
        Fluttertoast.showToast(
          msg: "Connected to ARDUINOBT",
          backgroundColor: Colors.green,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainAppScreen(onDisconnect: _disconnect),
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: "Failed to connect",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Connection failed: $e",
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _disconnect() async {
    try {
      await _platform.invokeMethod('disconnect');
    } catch (e) {
      // Optionally show a toast
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CoolFan Connection"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[900]!, Colors.blueAccent.withOpacity(0.3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child:
              isLoading
                  ? const CircularProgressIndicator(color: Colors.blueAccent)
                  : ElevatedButton(
                    onPressed: _connectToDevice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Connect to ARDUINOBT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}
