import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../managers/control_cubit.dart';
import '../managers/control_state.dart';

class ControlScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ControlCubit, ControlState>(
      builder: (context, state) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SwitchListTile(
                title: const Text(
                  'Mode: Auto / Manual',
                  style: TextStyle(color: Colors.white),
                ),
                value: state.isAuto,
                activeColor: Colors.blueAccent,
                inactiveThumbColor: Colors.grey,
                onChanged:
                    state.isSwitching
                        ? null
                        : (value) {
                          context.read<ControlCubit>().setMode(value);
                        },
              ),
              AnimatedVisibility(
                visible: !state.isAuto,
                child: SleekCircularSlider(
                  appearance: CircularSliderAppearance(
                    customWidths: CustomSliderWidths(progressBarWidth: 10),
                    customColors: CustomSliderColors(
                      progressBarColor: Colors.blueAccent,
                    ),
                    infoProperties: InfoProperties(
                      mainLabelStyle: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                      modifier: (double value) => '${value.toInt()}%',
                    ),
                  ),
                  min: 0,
                  max: 100,
                  initialValue: state.speed,
                  onChange: (double value) {
                    context.read<ControlCubit>().setSpeed(value);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AnimatedVisibility extends StatelessWidget {
  final bool visible;
  final Widget child;

  const AnimatedVisibility({required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: visible ? child : SizedBox.shrink(),
    );
  }
}
