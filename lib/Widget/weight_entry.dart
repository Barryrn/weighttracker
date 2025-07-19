import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ViewModel/entry_form_provider.dart';

class WeightEntry extends ConsumerStatefulWidget {
  const WeightEntry({Key? key}) : super(key: key);

  @override
  ConsumerState<WeightEntry> createState() => _WeightEntryState();
}

class _WeightEntryState extends ConsumerState<WeightEntry> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final weight = ref.read(bodyEntryProvider).weight;
    _controller = TextEditingController(
      text: weight != null ? weight.toString() : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onWeightChanged(String value) {
    final notifier = ref.read(bodyEntryProvider.notifier);
    if (value.isEmpty) {
      notifier.updateWeight(null);
      return;
    }

    try {
      final parsed = double.parse(value.replaceAll(',', '.'));
      notifier.updateWeight(parsed);
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
          'Weight (kg)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: TextFormField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              TextInputFormatter.withFunction((oldValue, newValue) {
                final text = newValue.text.replaceAll(',', '.');
                try {
                  if (text.isEmpty) return newValue;
                  if (text.split('.').length > 2) return oldValue;
                  if (text.contains('.')) {
                    final decimals = text.split('.')[1];
                    if (decimals.length > 1) return oldValue;
                  }
                  double.parse(text);
                  return newValue.copyWith(text: text);
                } catch (_) {
                  return oldValue;
                }
              }),
            ],
            onChanged: _onWeightChanged,
            decoration: InputDecoration(
              hintText: 'Enter your weight',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
              suffixIcon: const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Text('kg', style: TextStyle(color: Colors.grey)),
              ),
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
