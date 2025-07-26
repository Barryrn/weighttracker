import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'weight_repository.dart';

/// Provider for the weight repository
final weightRepositoryProvider = Provider<WeightRepository>((ref) {
  return WeightRepository();
});