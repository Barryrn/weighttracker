import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
import '../../ViewModel/entry_form_provider.dart';

class NotesEntry extends ConsumerStatefulWidget {
  const NotesEntry({Key? key}) : super(key: key);

  @override
  ConsumerState<NotesEntry> createState() => _NotesEntryState();
}

class _NotesEntryState extends ConsumerState<NotesEntry> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final weight = ref.read(bodyEntryProvider).notes;
    _controller = TextEditingController(
      text: weight != null ? weight.toString() : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNotesChanged(String value) {
    final notifier = ref.read(bodyEntryProvider.notifier);
    if (value.isEmpty) {
      notifier.updateNotes(null);
      return;
    }

    try {
      notifier.updateNotes(value);
    } catch (_) {
      // silently ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Notes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: TextFormField(
            controller: _controller,
            onChanged: _onNotesChanged,
            decoration: InputDecoration(
              hintText: 'Enter your Note',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,

              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
            ),
            style: const TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
