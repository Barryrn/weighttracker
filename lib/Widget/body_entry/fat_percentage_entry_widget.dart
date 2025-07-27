import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
import '../../ViewModel/entry_form_provider.dart';
import '../../View/fat_percentage_view.dart';

/// A widget that allows users to enter their body fat percentage or calculate it
/// using the fat percentage calculator view.
///
/// This widget follows the MVVM pattern by using the bodyEntryProvider to update
/// the fat percentage in the ViewModel.
class FatPercentageEntry extends ConsumerStatefulWidget {
  const FatPercentageEntry({Key? key}) : super(key: key);

  @override
  ConsumerState<FatPercentageEntry> createState() => _FatPercentageEntryState();
}

class _FatPercentageEntryState extends ConsumerState<FatPercentageEntry> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
    
    // Add listener to bodyEntryProvider
    ref.listenManual(bodyEntryProvider, (previous, next) {
      if (next.fatPercentage == null && _controller.text.isNotEmpty) {
        _controller.clear();
      }
    });
  }
  
  /// Initializes the text controller with the current fat percentage value
  void _initializeController() {
    final fatPercentage = ref.read(bodyEntryProvider).fatPercentage;
    _controller = TextEditingController(
      text: fatPercentage != null ? fatPercentage.toString() : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Updates the fat percentage in the ViewModel when the text field value changes
  void _onFatPercentageChanged(String value) {
    final notifier = ref.read(bodyEntryProvider.notifier);
    if (value.isEmpty) {
      notifier.updateFatPercentage(null);
      return;
    }

    try {
      final parsed = double.parse(value.replaceAll(',', '.'));
      notifier.updateFatPercentage(parsed);
    } catch (_) {
      // silently ignore parsing errors
    }
  }

  /// Opens the fat percentage calculator view
  void _openCalculator() async {
    final result = await Navigator.push<double>(
      context,
      MaterialPageRoute(builder: (context) => const FatPercentageView()),
    );

    if (result != null) {
      _controller.text = result.toStringAsFixed(1);
      ref.read(bodyEntryProvider.notifier).updateFatPercentage(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Body Fat Percentage (%)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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
                  onChanged: _onFatPercentageChanged,
                  decoration: InputDecoration(
                    hintText: 'Enter body fat percentage',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    suffixIcon: const Padding(
                      padding: EdgeInsets.only(right: 12.0),
                      child: Text('%', style: TextStyle(color: Colors.grey)),
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                  ),
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
              ),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.calculate, color: AppColors.primary),
                  onPressed: _openCalculator,
                  tooltip: 'Calculate body fat percentage',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
