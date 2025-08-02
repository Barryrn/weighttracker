import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weigthtracker/Model/body_entry_model.dart';
import 'package:weigthtracker/Model/database_helper.dart';
import 'package:weigthtracker/provider/database_change_provider.dart';
import '../model/weight_change_goal_tdee_state.dart';
import 'dart:developer' as developer;

class WeightChangeGoalTDEENotifier
    extends StateNotifier<WeightChangeGoalTDEEState> {
  WeightChangeGoalTDEENotifier(this.ref)
    : super(WeightChangeGoalTDEEState.initial()) {
    _initialize();
    ref.listen(databaseChangeProvider, (previous, current) {
      calculateTDEE();
    });
  }

  final Ref ref;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  static const int _minRequiredDays = 7;
  static const int _maxDaysToUse = 14;
  static const int _caloriesPerKg = 7700;

  // SharedPreferences keys
  static const String _gainPrefKey = 'isGainingWeight';
  static const String _weightChangeKey = 'weightChangePerWeek';

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isGainingWeight = prefs.getBool(_gainPrefKey) ?? true;
    final double weightChangePerWeek = prefs.getDouble(_weightChangeKey) ?? 0.0;

    state = state.copyWith(
      isGainingWeight: isGainingWeight,
      weightChangePerWeek: weightChangePerWeek,
    );

    await calculateTDEE();
  }

  Future<void> calculateTDEE() async {
    try {
      final List<BodyEntry> allEntries = await _databaseHelper
          .queryAllBodyEntries();
      allEntries.sort((a, b) => a.date.compareTo(b.date));
      final List<BodyEntry> continuousEntries = _findContinuousEntries(
        allEntries,
      );

      if (continuousEntries.length < _minRequiredDays) {
        state = state.copyWith(baseTDEE: null, goalTDEE: null);
        return;
      }

      final entriesToUse = continuousEntries.length > _maxDaysToUse
          ? continuousEntries.sublist(continuousEntries.length - _maxDaysToUse)
          : continuousEntries;

      final double tdee = _calculateTDEEFromEntries(entriesToUse);
      final double? goalTDEE = _calculateGoalTDEE(
        baseTDEE: tdee,
        isGainingWeight: state.isGainingWeight,
        weightChangePerWeek: state.weightChangePerWeek,
      );

      state = state.copyWith(baseTDEE: tdee, goalTDEE: goalTDEE);
    } catch (e) {
      state = state.copyWith(baseTDEE: null, goalTDEE: null);
    }
  }

  Future<void> updateGoalSettings({
    required bool isGainingWeight,
    required double weightChangePerWeek,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save values
    await prefs.setBool(_gainPrefKey, isGainingWeight);
    await prefs.setDouble(_weightChangeKey, weightChangePerWeek);

    final newGoalTDEE = _calculateGoalTDEE(
      baseTDEE: state.baseTDEE,
      isGainingWeight: isGainingWeight,
      weightChangePerWeek: weightChangePerWeek,
    );

    state = state.copyWith(
      isGainingWeight: isGainingWeight,
      weightChangePerWeek: weightChangePerWeek,
      goalTDEE: newGoalTDEE,
    );
  }

  double? _calculateGoalTDEE({
    required double? baseTDEE,
    required bool isGainingWeight,
    required double weightChangePerWeek,
  }) {
    if (baseTDEE == null) return null;
    final adjustment = (weightChangePerWeek.abs() * _caloriesPerKg) / 7;
    return isGainingWeight ? baseTDEE + adjustment : baseTDEE - adjustment;
  }

  List<BodyEntry> _findContinuousEntries(List<BodyEntry> entries) {
    final List<BodyEntry> result = [];

    for (int i = entries.length - 1; i > 0; i--) {
      final diff = entries[i].date.difference(entries[i - 1].date).inDays;
      if (diff <= 2) {
        if (result.isEmpty) result.add(entries[i]);
        result.add(entries[i - 1]);
      } else {
        break;
      }
    }

    return result.reversed.toList();
  }

  double _calculateTDEEFromEntries(List<BodyEntry> entries) {
    final double firstWeight = entries.first.weight!;
    final double lastWeight = entries.last.weight!;
    final double weightChange = lastWeight - firstWeight;

    double totalCalories = 0;
    for (var entry in entries) {
      totalCalories += entry.calorie ?? 0;
    }

    final int days = entries.length;
    final double caloriesFromWeightChange = weightChange * _caloriesPerKg;
    final double tdee = (totalCalories + caloriesFromWeightChange) / days;

    developer.log(
      'TDEE: ($totalCalories + $caloriesFromWeightChange) / $days = $tdee',
    );

    return tdee;
  }
}

final weightChangeGoalTDEEProvider =
    StateNotifierProvider<
      WeightChangeGoalTDEENotifier,
      WeightChangeGoalTDEEState
    >((ref) => WeightChangeGoalTDEENotifier(ref));
