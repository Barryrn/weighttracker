import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weigthtracker/Widget/image_timeline_view_widget.dart';
import '../ViewModel/image_timeline_view_model.dart';
import '../theme.dart';

/// A view that displays a timeline of progress images
class ImageTimelineView extends ConsumerWidget {
  const ImageTimelineView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Timeline'),
        backgroundColor: AppColors.primaryVeryLight,
        foregroundColor: AppColors.textPrimary,
      ),
      body: ImageTimelineViewWidget(),
    );
  }
}
