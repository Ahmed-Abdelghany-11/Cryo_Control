class ControlState {
  final bool isAuto;
  final double speed;
  final bool isSwitching;

  ControlState({
    required this.isAuto,
    required this.speed,
    required this.isSwitching,
  });

  factory ControlState.initial() =>
      ControlState(isAuto: true, speed: 0, isSwitching: false);

  ControlState copyWith({bool? isAuto, double? speed, bool? isSwitching}) {
    return ControlState(
      isAuto: isAuto ?? this.isAuto,
      speed: speed ?? this.speed,
      isSwitching: isSwitching ?? this.isSwitching,
    );
  }
}
