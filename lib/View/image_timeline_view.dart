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
        title: Text(
          'Image Timeline',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.textTertiary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.textTertiary,
      ),
      backgroundColor: Theme.of(context).colorScheme.background2,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ImageTimelineViewWidget(),
      ),
    );
  }
}
