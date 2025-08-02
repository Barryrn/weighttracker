class WeightChangeGoalTDEEState {
  final double? baseTDEE;
  final double? goalTDEE;
  final bool isGainingWeight;
  final double weightChangePerWeek;

  WeightChangeGoalTDEEState({
    required this.baseTDEE,
    required this.goalTDEE,
    required this.isGainingWeight,
    required this.weightChangePerWeek,
  });

  WeightChangeGoalTDEEState copyWith({
    double? baseTDEE,
    double? goalTDEE,
    bool? isGainingWeight,
    double? weightChangePerWeek,
  }) {
    return WeightChangeGoalTDEEState(
      baseTDEE: baseTDEE ?? this.baseTDEE,
      goalTDEE: goalTDEE ?? this.goalTDEE,
      isGainingWeight: isGainingWeight ?? this.isGainingWeight,
      weightChangePerWeek: weightChangePerWeek ?? this.weightChangePerWeek,
    );
  }

  static WeightChangeGoalTDEEState initial() => WeightChangeGoalTDEEState(
    baseTDEE: null,
    goalTDEE: null,
    isGainingWeight: false,
    weightChangePerWeek: 0,
  );
}
