class WeightEntry {
  final DateTime date;
  final double? weight;

  WeightEntry({
    required this.date,
    this.weight,
  });

  @override
  String toString() {
    return 'WeightEntry(date: ${date.toIso8601String()}, weight: $weight)';
  }

  /// Creates a copy of this WeightEntry with the given fields replaced with new values
  WeightEntry copyWith({
    DateTime? date,
    double? weight,
  }) {
    return WeightEntry(
      date: date ?? this.date,
      weight: weight ?? this.weight,
    );
  }
}