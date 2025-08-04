// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import '../model/body_entry_model.dart';
// import '../viewmodel/image_comparison_provider.dart';
// import '../theme.dart';
// import 'image_gallery_view.dart';

// /// A view that displays two images side by side for comparison
// class ImageComparisonViews extends ConsumerStatefulWidget {
//   const ImageComparisonViews({Key? key}) : super(key: key);

//   @override
//   ConsumerState<ImageComparisonViews> createState() =>
//       _ImageComparisonViewsState();
// }

// class _ImageComparisonViewsState extends ConsumerState<ImageComparisonViews> {
//   // Selected image type for each card
//   String _leftImageType = 'front';
//   String _rightImageType = 'front';

//   @override
//   Widget build(BuildContext context) {
//     final comparisonState = ref.watch(imageComparisonProvider);
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(0.0),
//         child: Column(
//           children: [
//             comparisonState.when(
//               loading: () => const Center(child: CircularProgressIndicator()),
//               error: (error, stackTrace) =>
//                   Center(child: Text('Error loading images')),
//               data: (entries) {
//                 final latestEntry = ref
//                     .read(imageComparisonProvider.notifier)
//                     .latestEntry;
//                 final comparisonEntry = ref
//                     .read(imageComparisonProvider.notifier)
//                     .comparisonEntry;

//                 // Check if there are any images available on the device
//                 final hasAnyImages = entries.any(
//                   (entry) =>
//                       entry.frontImagePath != null ||
//                       entry.sideImagePath != null ||
//                       entry.backImagePath != null,
//                 );

//                 if (!hasAnyImages) {
//                   return Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(
//                             Icons.photo_library_outlined,
//                             size: 64,
//                             color: AppColors.primary,
//                           ),
//                           const SizedBox(height: 16),
//                           const Text(
//                             'No images available',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 8),
//                           const Text(
//                             'Please upload images to track your progress',
//                             style: TextStyle(fontSize: 14),
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 16),
//                           ElevatedButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       const ImageGalleryView(),
//                                 ),
//                               ).then((_) {
//                                 // Refresh the view when returning from gallery
//                                 setState(() {});
//                               });
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.primary,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(
//                                 vertical: 12,
//                                 horizontal: 24,
//                               ),
//                             ),
//                             child: const Text('Upload Images'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }

//                 if (latestEntry == null) {
//                   return const Center(
//                     child: Text('No images available for comparison'),
//                   );
//                 }

//                 return SingleChildScrollView(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       // Comparison header
//                       const Text(
//                         'Compare your progress',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 16),

//                       // Image comparison section
//                       Row(
//                         children: [
//                           // Latest image (left side)
//                           Expanded(
//                             child: _buildImageCard(
//                               context: context,
//                               entry: latestEntry,
//                               title: 'Pic 1',
//                               subtitle: _formatDate(latestEntry.date),
//                               weight: latestEntry.weight,
//                               imageType: _leftImageType,
//                               onImageTypeChanged: (type) {
//                                 setState(() {
//                                   _leftImageType = type;
//                                 });
//                               },
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           // Comparison image (right side)
//                           Expanded(
//                             child: comparisonEntry != null
//                                 ? _buildImageCard(
//                                     context: context,
//                                     entry: comparisonEntry,
//                                     title: 'Pic 2',
//                                     subtitle: _formatDate(comparisonEntry.date),
//                                     weight: comparisonEntry.weight,
//                                     imageType: _rightImageType,
//                                     onImageTypeChanged: (type) {
//                                       setState(() {
//                                         _rightImageType = type;
//                                       });
//                                     },
//                                   )
//                                 : _buildNoComparisonCard(),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 24),

//                       // View all images button
//                       ElevatedButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const ImageGalleryView(),
//                             ),
//                           ).then((_) {
//                             // Refresh the view when returning from gallery
//                             setState(() {});
//                           });
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.primary,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         child: const Text('View All Images'),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Builds a card displaying an image with metadata
//   Widget _buildImageCard({
//     required BuildContext context,
//     required BodyEntry entry,
//     required String title,
//     required String subtitle,
//     double? weight,
//     required String imageType,
//     required Function(String) onImageTypeChanged,
//   }) {
//     // Determine which image to show based on selected type
//     String? imagePath;
//     if (imageType == 'front' && entry.frontImagePath != null) {
//       imagePath = entry.frontImagePath;
//     } else if (imageType == 'side' && entry.sideImagePath != null) {
//       imagePath = entry.sideImagePath;
//     } else if (imageType == 'back' && entry.backImagePath != null) {
//       imagePath = entry.backImagePath;
//     } else {
//       // Fallback to any available image if the selected type is not available
//       if (entry.frontImagePath != null) {
//         imagePath = entry.frontImagePath;
//         imageType = 'front';
//       } else if (entry.sideImagePath != null) {
//         imagePath = entry.sideImagePath;
//         imageType = 'side';
//       } else if (entry.backImagePath != null) {
//         imagePath = entry.backImagePath;
//         imageType = 'back';
//       }
//     }

//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const ImageGalleryView()),
//         ).then((_) {
//           // Refresh the view when returning from gallery
//           setState(() {});
//         });
//       },
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Image header
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(12),
//                   topRight: Radius.circular(12),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   Text(subtitle, style: const TextStyle(fontSize: 12)),
//                 ],
//               ),
//             ),
//             // Image type selector
//             Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 8.0,
//                 vertical: 4.0,
//               ),
//               child: Wrap(
//                 spacing: 4, // Horizontal space between buttons
//                 runSpacing: 4, // Vertical space between lines
//                 alignment: WrapAlignment.spaceEvenly,
//                 children: [
//                   _buildImageTypeButton(
//                     'Front',
//                     'front',
//                     imageType,
//                     entry.frontImagePath != null,
//                     onImageTypeChanged,
//                   ),
//                   _buildImageTypeButton(
//                     'Side',
//                     'side',
//                     imageType,
//                     entry.sideImagePath != null,
//                     onImageTypeChanged,
//                   ),
//                   _buildImageTypeButton(
//                     'Back',
//                     'back',
//                     imageType,
//                     entry.backImagePath != null,
//                     onImageTypeChanged,
//                   ),
//                 ],
//               ),
//             ),
//             // Image
//             if (imagePath != null)
//               AspectRatio(
//                 aspectRatio: 3 / 4,
//                 child: FutureBuilder<bool>(
//                   future: File(imagePath).exists(),
//                   builder: (context, snapshot) {
//                     final exists = snapshot.data ?? false;
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     } else if (exists) {
//                       return ClipRRect(
//                         borderRadius: BorderRadius.circular(4),
//                         child: Image.file(File(imagePath!), fit: BoxFit.cover),
//                       );
//                     } else {
//                       return const Center(
//                         child: Icon(Icons.broken_image, size: 64),
//                       );
//                     }
//                   },
//                 ),
//               )
//             else
//               AspectRatio(
//                 aspectRatio: 3 / 4,
//                 child: Container(child: Icon(Icons.no_photography, size: 64)),
//               ),
//             // Weight info
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(12),
//                   bottomRight: Radius.circular(12),
//                 ),
//               ),
//               child: Text(
//                 weight != null
//                     ? '${weight.toStringAsFixed(1)} kg'
//                     : 'No weight data',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Builds a button for selecting image type
//   Widget _buildImageTypeButton(
//     String label,
//     String type,
//     String currentType,
//     bool isAvailable,
//     Function(String) onChanged,
//   ) {
//     return Opacity(
//       opacity: isAvailable ? 1.0 : 0.5,
//       child: TextButton(
//         onPressed: isAvailable ? () => onChanged(type) : null,
//         style: TextButton.styleFrom(
//           backgroundColor: currentType == type
//               ? AppColors.primary.withOpacity(0.2)
//               : Colors.transparent,
//           padding: const EdgeInsets.symmetric(
//             horizontal: 6,
//             vertical: 4,
//           ), // Reduced from 8 to 6
//           minimumSize: Size.zero,
//           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: currentType == type
//                 ? FontWeight.bold
//                 : FontWeight.normal,
//             color: isAvailable ? AppColors.textPrimary : Colors.grey,
//           ),
//         ),
//       ),
//     );
//   }

//   /// Builds a card for when no comparison image is available
//   Widget _buildNoComparisonCard() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Header
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//               ),
//             ),
//             child: const Column(
//               children: [
//                 Text(
//                   'No Comparison',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Text('Add more entries', style: TextStyle(fontSize: 12)),
//               ],
//             ),
//           ),
//           // Placeholder
//           AspectRatio(
//             aspectRatio: 3 / 4,
//             child: Container(
//               color: Colors.grey[200],
//               child: const Center(
//                 child: Icon(Icons.add_photo_alternate, size: 64),
//               ),
//             ),
//           ),
//           // Footer
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(12),
//                 bottomRight: Radius.circular(12),
//               ),
//             ),
//             child: const Text(
//               'No similar weight entry',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Formats a date as a string
//   String _formatDate(DateTime date) {
//     return DateFormat('MMM d, yyyy').format(date);
//   }

//   @override
//   void initState() {
//     super.initState();
//     // Ensure data is loaded when widget initializes
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _preloadImages();
//     });
//   }

//   /// Preload images to ensure they're available when needed
//   Future<void> _preloadImages() async {
//     final comparisonNotifier = ref.read(imageComparisonProvider.notifier);
//     await comparisonNotifier.loadEntries();

//     // Access the entries
//     final state = ref.read(imageComparisonProvider);
//     state.whenData((entries) {
//       // Preload images by accessing them
//       for (final entry in entries) {
//         if (entry.frontImagePath != null) {
//           precacheImage(FileImage(File(entry.frontImagePath!)), context);
//         }
//         if (entry.sideImagePath != null) {
//           precacheImage(FileImage(File(entry.sideImagePath!)), context);
//         }
//         if (entry.backImagePath != null) {
//           precacheImage(FileImage(File(entry.backImagePath!)), context);
//         }
//       }
//     });
//   }
// }
