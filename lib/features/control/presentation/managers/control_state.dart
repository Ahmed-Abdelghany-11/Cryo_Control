enum Mode { idle, auto, manual }

class ControlState {
  final Mode? mode;
  final double speed;
  final bool isSwitching;

  ControlState({
    required this.mode,
    required this.speed,
    required this.isSwitching,
  });

  factory ControlState.initial() =>
      ControlState(mode: null, speed: 0, isSwitching: false);

  ControlState copyWith({Mode? mode, double? speed, bool? isSwitching}) {
    return ControlState(
      mode: mode ?? this.mode,
      speed: speed ?? this.speed,
      isSwitching: isSwitching ?? this.isSwitching,
    );
  }
}
