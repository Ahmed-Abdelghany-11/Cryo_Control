import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../managers/control_cubit.dart';
import '../managers/control_state.dart';

class ControlScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ControlCubit, ControlState>(
      builder:
          (context, state) => Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header text
                    Text(
                      'Stay Cool! Control Your Fan',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Radio buttons for Idle, Auto, Manual
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          Mode.values.map((modeOption) {
                            final selected = state.mode == modeOption;
                            return GestureDetector(
                              onTap: () {
                                if (state.isSwitching) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Please wait...'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                } else {
                                  context.read<ControlCubit>().setMode(
                                    modeOption,
                                  );
                                }
                              },
                              child: Column(
                                children: [
                                  // custom radio circle
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            selected
                                                ? Colors.blueAccent
                                                : Colors.grey,
                                        width: 2,
                                      ),
                                      color:
                                          selected
                                              ? Colors.blueAccent
                                              : Colors.transparent,
                                    ),
                                    child:
                                        selected
                                            ? Icon(
                                              Icons.check,
                                              size: 20,
                                              color: Colors.white,
                                            )
                                            : null,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    modeOption.label,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          selected
                                              ? Colors.blueAccent
                                              : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),

                    const SizedBox(height: 32),

                    // Manual slider appears only in Manual mode
                    if (state.mode == Mode.manual)
                      Center(
                        child: SleekCircularSlider(
                          appearance: CircularSliderAppearance(
                            animationEnabled: false,
                            customWidths: CustomSliderWidths(
                              progressBarWidth: 10,
                            ),
                            customColors: CustomSliderColors(
                              progressBarColor: Colors.blueAccent,
                            ),
                            infoProperties: InfoProperties(
                              mainLabelStyle: TextStyle(
                                fontSize: 25,
                                color: Colors.black,
                              ),
                              modifier: (value) => '${value.toInt()}%',
                            ),
                          ),
                          min: 0,
                          max: 100,
                          initialValue: state.speed,
                          onChange:
                              (value) => context
                                  .read<ControlCubit>()
                                  .updateLocalSpeed(value),
                          onChangeEnd:
                              (value) =>
                                  context.read<ControlCubit>().setSpeed(value),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}

// Helper extension for labels
extension ModeLabel on Mode {
  String get label {
    switch (this) {
      case Mode.idle:
        return 'Idle';
      case Mode.auto:
        return 'Auto';
      case Mode.manual:
        return 'Manual';
    }
  }
}
