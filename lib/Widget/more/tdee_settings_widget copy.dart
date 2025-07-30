// import 'package:flutter/material.dart';
// import 'package:weigthtracker/View/tdee_view.dart';
// import '../../../View/tag_settings_view.dart';
// import 'package:heroicons/heroicons.dart';

// /// A widget that displays a card for navigating to the TDEE calculator page.
// ///
// /// This widget follows the MVVM pattern by acting as part of the View layer
// /// that provides navigation to the TDEE calculator page.
// class TDEESettingsWidget extends StatelessWidget {
//   /// Creates a TDEESettingsWidget.
//   const TDEESettingsWidget({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade300,

//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: const HeroIcon(
//           HeroIcons.fire,
//           style: HeroIconStyle.outline,
//           size: 30,
//         ),
//       ),
//       title: const Text(
//         'TDEE Calculator (Calories)',
//         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//       ),

//       trailing: const Icon(Icons.chevron_right),
//       onTap: () {
//         // Navigate to the tag settings page when tapped
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const TDEEPage()),
//         );
//       },
//     );
//   }
// }
