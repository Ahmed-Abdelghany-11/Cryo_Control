import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../../core/utils/bluetooth_service.dart';
import '../widgets/main_app_bar.dart';
import 'home_screen.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  bool isLoading = false;
  bool isBluetoothEnabled = false;
  final String arduinobtAddress = "00:22:06:01:97:D3";
  late BluetoothService bluetoothService;

  @override
  void initState() {
    super.initState();
    bluetoothService = BluetoothService();
    _checkBluetooth();
  }

  Future<void> _checkBluetooth() async {
    setState(() => isLoading = true);
    try {
      bool isEnabled = await bluetoothService.isBluetoothEnabled();
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
      await bluetoothService.connect(arduinobtAddress);
      Fluttertoast.showToast(
        msg: "Connected to ARDUINOBT",
        backgroundColor: Colors.green,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(bluetoothService: bluetoothService),
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Connection failed: $e",
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: const MainAppBar(),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child:
            isLoading
                ? const CircularProgressIndicator(color: Colors.blueAccent)
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Welcome to Cryo Control",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Connect Now To Yor ARDUINO",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 200),
                      ElevatedButton(
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
                          "Connect",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
