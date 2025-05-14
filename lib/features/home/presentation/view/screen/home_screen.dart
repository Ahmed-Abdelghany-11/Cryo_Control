import 'package:cryo_control/features/home/presentation/view/widgets/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../../core/utils/bluetooth_service.dart';
import '../../../../control/presentation/managers/control_cubit.dart';
import '../../../../control/presentation/view/control_screen.dart';
import '../../../../graph/presentation/managers/graph_cubit.dart';
import '../../../../graph/presentation/view/graph_screen.dart';
import '../../../../settings/presentation/managers/settings_cubit.dart';
import '../../../../settings/presentation/view/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final BluetoothService bluetoothService;

  const HomeScreen({super.key, required this.bluetoothService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [ControlScreen(), GraphScreen(), SettingsScreen()];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    try {
      await widget.bluetoothService.disconnect();
      Fluttertoast.showToast(
        msg: "Disconnected",
        backgroundColor: Colors.orange,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error disconnecting: $e",
        backgroundColor: Colors.red,
      );
    } finally {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ControlCubit(widget.bluetoothService)),
        BlocProvider(create: (_) => SettingsCubit(widget.bluetoothService)),
        BlocProvider(create: (_) => GraphCubit(widget.bluetoothService)),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: MainAppBar(),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Disconnect',
              onPressed: _handleLogout,
            ),
          ],
        ),
        body: Container(child: _screens[_selectedIndex]),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.control_camera),
              label: 'Control',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'Graph',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blueAccent,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
