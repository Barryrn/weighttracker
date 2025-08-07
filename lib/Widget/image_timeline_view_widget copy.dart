// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import '../ViewModel/image_timeline_view_model.dart';
// import '../ViewModel/image_export_view_model.dart';
// import '../theme.dart';

// /// A widget that displays the timeline content of progress images.
// /// Does NOT include a Scaffold, so you can use it inside any Scaffold.
// class ImageTimelineViewWidget extends ConsumerWidget {
//   const ImageTimelineViewWidget({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(imageTimelineProvider);
//     final viewModel = ref.read(imageTimelineProvider.notifier);
//     final currentEntry = viewModel.getCurrentEntry();

//     if (state.isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     } else if (state.errorMessage != null) {
//       return Center(child: Text(state.errorMessage!));
//     } else if (state.entries.isEmpty) {
//       return const Center(child: Text('No images available'));
//     }

//     return Column(
//       children: [
//         // View selector - Updated with rounded pill-shaped buttons
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             borderRadius: BorderRadius.circular(25),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
//           child: Row(
//             mainAxisSize: MainAxisSize.max,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildViewButton(
//                 context,
//                 'Front',
//                 'front',
//                 state.selectedView,
//                 viewModel,
//               ),
//               const SizedBox(width: 8),
//               _buildViewButton(
//                 context,
//                 'Side',
//                 'side',
//                 state.selectedView,
//                 viewModel,
//               ),
//               const SizedBox(width: 8),
//               _buildViewButton(
//                 context,
//                 'Back',
//                 'back',
//                 state.selectedView,
//                 viewModel,
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//         // Image display - Updated with card-like appearance
//         Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   spreadRadius: 1,
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: _buildImageDisplay(context, ref, viewModel),
//             ),
//           ),
//         ),

//         // Date and weight display - Updated with modern styling
//         if (currentEntry != null)
//           Container(
//             margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(
//               horizontal: 16.0,
//               vertical: 8.0,
//             ),
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.primaryExtraLight,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   DateFormat('MM/dd/yyyy').format(currentEntry.date),
//                   //                 ),
//                 if (currentEntry.weight != null)
//                   Container(
//                     margin: const EdgeInsets.only(top: 4.0),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12.0,
//                       vertical: 4.0,
//                     ),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Text(
//                       'Weight: ${currentEntry.weight!.toStringAsFixed(1)} kg',
//                       //                     ),
//                   ),
//               ],
//             ),
//           ),

//         // Timeline slider - Updated with modern styling
//         Container(
//           margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
//           child: _buildTimelineSlider(context, state, viewModel),
//         ),
//       ],
//     );
//   }

//   Widget _buildViewButton(
//     BuildContext context,
//     String label,
//     String viewType,
//     String selectedView,
//     ImageTimelineViewModel viewModel,
//   ) {
//     final isSelected = viewType == selectedView;

//     return ElevatedButton(
//       onPressed: () => viewModel.updateSelectedView(viewType),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: isSelected
//             ? Theme.of(context).colorScheme.primary
//             : Colors.transparent,
//         foregroundColor: isSelected ? Colors.white : Colors.black87,
//         elevation: 0,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       ),
//       child: Text(
//         label,
//         //       ),
//     );
//   }

//   Widget _buildImageDisplay(
//     BuildContext context,
//     WidgetRef ref,
//     ImageTimelineViewModel viewModel,
//   ) {
//     final imagePath = viewModel.getCurrentImagePath();

//     if (imagePath == null) {
//       return const Center(child: Text('No image available for this view'));
//     }

//     return GestureDetector(
//       onTap: () {
//         // Show export options when image is tapped
//         ref
//             .read(imageExportProvider.notifier)
//             .showExportOptions(context, imagePath);
//       },
//       child: Image.file(File(imagePath), fit: BoxFit.contain),
//     );
//   }

//   Widget _buildTimelineSlider(
//     BuildContext context,
//     ImageTimelineState state,
//     ImageTimelineViewModel viewModel,
//   ) {
//     final availableDates = viewModel.getAvailableDates();

//     if (availableDates.isEmpty) {
//       return const Text('No images available for this view');
//     }

//     if (availableDates.length == 1) {
//       return Column(
//         children: [
//           Text(
//             'Only one image available for this view',
//             //           ),
//           const SizedBox(height: 8),
//           Text(
//             DateFormat('MM/dd/yyyy').format(availableDates.first),
//             //           ),
//         ],
//       );
//     }

//     final currentEntry = viewModel.getCurrentEntry();
//     int currentDateIndex = 0;

//     if (currentEntry != null) {
//       for (int i = 0; i < availableDates.length; i++) {
//         if (availableDates[i].day == currentEntry.date.day &&
//             availableDates[i].month == currentEntry.date.month &&
//             availableDates[i].year == currentEntry.date.year) {
//           currentDateIndex = i;
//           break;
//         }
//       }
//     }

//     return Column(
//       children: [
//         SliderTheme(
//           data: SliderThemeData(
//             trackHeight: 4,
//             activeTrackColor: Theme.of(context).colorScheme.primary,
//             inactiveTrackColor: Theme.of(
//               context,
//             ).colorScheme.primary.withOpacity(0.2),
//             thumbColor: Theme.of(context).colorScheme.primary,
//             thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
//             overlayColor: Theme.of(
//               context,
//             ).colorScheme.primary.withOpacity(0.2),
//             overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
//           ),
//           child: Slider(
//             min: 0,
//             max: availableDates.length - 1.0,
//             divisions: availableDates.length - 1,
//             value: currentDateIndex.toDouble(),
//             onChanged: (value) {
//               final date = availableDates[value.round()];
//               for (int i = 0; i < state.entries.length; i++) {
//                 final entry = state.entries[i];
//                 if (entry.date.day == date.day &&
//                     entry.date.month == date.month &&
//                     entry.date.year == date.year) {
//                   viewModel.updateSelectedIndex(i);
//                   break;
//                 }
//               }
//             },
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 DateFormat('MM/dd/yyyy').format(availableDates.first),
//                 //               ),
//               Text(
//                 DateFormat('MM/dd/yyyy').format(availableDates.last),
//                 //               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
