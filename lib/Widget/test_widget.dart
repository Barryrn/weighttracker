// import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:weigthtracker/View/fat_percentage_view.dart';
// import 'package:weigthtracker/ViewModel/weight_entry_view_model.dart';
// import 'package:weigthtracker/ViewModel/profile_settings_provider.dart';
// import 'package:weigthtracker/theme.dart';
// import '../../viewmodel/weight_goal_view_model.dart';

// class TestWidget extends ConsumerStatefulWidget {
//   const TestWidget({super.key});

//   @override
//   ConsumerState<TestWidget> createState() => _TestWidgetState();
// }

// class _TestWidgetState extends ConsumerState<TestWidget> {
//   final GlobalKey<FatPercentageViewState> fatPercentageKey = GlobalKey();

//   bool toggleFatUnit = true;

//   @override
//   Widget build(BuildContext context) {
//     final goalData = ref.watch(weightGoalViewModelProvider);
//     final goalViewModel = ref.read(weightGoalViewModelProvider.notifier);

//     final entryData = ref.watch(weightEntryProvider);
//     final entryViewModel = ref.read(weightEntryProvider.notifier);

//     // Watch the height unit provider to get updates
//     final useMetricHeight = ref.watch(heightUnitProvider);
//     final heightUnitNotifier = ref.read(heightUnitProvider.notifier);

//     final useMetric = goalData.useMetricWeight && entryData.useMetricWeight;

//     // Set toggleFatUnit based on the provider state
//     toggleFatUnit = !useMetricHeight;

//     return Card(
//       child: Column(
//         children: [
//           SwitchListTile(
//             title: Text(
//               'Use ${useMetric ? "Kilograms (kg)" : "Pounds (lb)"}',
//               style: const TextStyle(
//                 color: Theme.of(context).colorScheme.textPrimary,
//                 fontSize: 14,
//               ),
//             ),
//             value: useMetric,
//             onChanged: (value) {
//               goalViewModel.toggleUnit();
//               entryViewModel.toggleUnit();
//             },
//             activeColor: Theme.of(context).colorScheme.primary,
//           ),

//           SwitchListTile(
//             title: Text(
//               'Use ${toggleFatUnit ? "Inches" : "Centimeters"}',
//               style: const TextStyle(
//                 color: Theme.of(context).colorScheme.textPrimary,
//                 fontSize: 14,
//               ),
//             ),
//             value: !toggleFatUnit, // Invert the value here
//             onChanged: (value) {
//               setState(() {
//                 toggleFatUnit = !value; // Invert again to update the actual variable
//               });
//               // Update the height unit provider with the new value
//               heightUnitNotifier.updateHeightUnit(!toggleFatUnit);
//               fatPercentageKey.currentState?.toggleMeasurementUnits();
//             },
//             activeColor: Theme.of(context).colorScheme.primary,
//           ),
//           Offstage(
//             offstage: true,
//             child: FatPercentageView(key: fatPercentageKey),
//           ),
//         ],
//       ),
//     );
//   }
// }
