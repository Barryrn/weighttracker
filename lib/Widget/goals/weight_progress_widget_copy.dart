// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:path/path.dart';
// import 'package:weigthtracker/ViewModel/weight_change_tdee_goal_provider.dart';
// import 'package:weigthtracker/theme.dart';
// import 'package:weigthtracker/viewmodel/weight_change_tdee_provider.dart';
// import '../../viewmodel/weight_progress_view_model.dart';

// /// A widget that displays the current weight and goal weight with a progress indicator.
// ///
// /// This widget follows the MVVM pattern by using the weightProgressProvider
// /// to access the calculated progress data from the ViewModel.
// class WeightProgressWidgetCopy extends ConsumerWidget {
//   const WeightProgressWidgetCopy({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Get the weight progress data from the ViewModel
//     final progressData = ref.watch(weightProgressProvider);
//     final tdee = ref.watch(weightChangeTDEEProvider);

//     final notifier = ref.read(weightChangeGoalTDEEProvider.notifier);
//     final goalState = ref.watch(weightChangeGoalTDEEProvider);

//     final double? baseTDEE = goalState.baseTDEE;
//     final double weightChangePerWeek = goalState.weightChangePerWeek;
//     final bool isGainingWeight = goalState.isGainingWeight;
//     final int days = 7;

//     final double calorieAdjustment =
//         (weightChangePerWeek * 7700) / days * (isGainingWeight ? 1 : -1);

//     final double? goalTDEE = baseTDEE != null
//         ? baseTDEE + calorieAdjustment
//         : null;

//     return Card(
//       shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
//       color: Theme.of(context).colorScheme.card,
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)
// ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Current weight
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Current',
//                       //                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       progressData.displayCurrentWeight != null
//                           ? '${progressData.displayCurrentWeight!.toStringAsFixed(1)} ${progressData.unitSuffix}'
//                           : '-- ${progressData.unitSuffix}',
//                       //                     ),
//                   ],
//                 ),

//                 // Goal weight
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Goal',
//                       //                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       progressData.displayGoalWeight != null
//                           ? '${progressData.displayGoalWeight!.toStringAsFixed(1)} ${progressData.unitSuffix}'
//                           : '-- ${progressData.unitSuffix}',
//                       //                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),

//             // Progress circle
//             Center(
//               child: SizedBox(
//                 width: 150,
//                 height: 150,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     // Progress circle
//                     SizedBox(
//                       width: 150,
//                       height: 150,
//                       child: CircularProgressIndicator(
//                         value: progressData.progressPercentage,
//                         strokeWidth: 12,
//                         backgroundColor: Theme.of(
//                           context,
//                         ).colorScheme.primaryDark,
//                         valueColor: const AlwaysStoppedAnimation<Color>(
//                           Theme.of(context).colorScheme.primary,
//                         ),
//                       ),
//                     ),

//                     // Percentage text
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           '${(progressData.progressPercentage * 100).toStringAsFixed(0)}%',
//                           //                         ),
//                         const Text(
//                           'complete',
//                           //                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Remaining weight
//                 Center(
//                   child: Column(
//                     children: [
//                       const Text(
//                         'TDEE Calories',
//                         //                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         tdee?.toStringAsFixed(0) ?? 'N/A',
//                         //                       ),
//                     ],
//                   ),
//                 ),

//                 Center(
//                   child: Column(
//                     children: [
//                       const Text(
//                         'Remaining',
//                         //                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         progressData.currentWeight != null &&
//                                 progressData.goalWeight != null
//                             ? '${progressData.displayRemainingWeight.abs().toStringAsFixed(1)} ${progressData.unitSuffix}'
//                             : '-- ${progressData.unitSuffix}',
//                         //                       ),
//                     ],
//                   ),
//                 ),
//                 Center(
//                   child: Column(
//                     children: [
//                       const Text(
//                         'Goal Weight TDEE',
//                         //                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         goalTDEE?.toStringAsFixed(0) ?? 'N/A',

//                         //                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//   // Helper method to calculate goal TDEE
