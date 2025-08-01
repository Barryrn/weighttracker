import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
import '../../ViewModel/fat_percentage_entry_view_model.dart';
import '../../View/fat_percentage_view.dart';

/// A widget that allows users to enter their body fat percentage or calculate it
/// using the fat percentage calculator view.
///
/// This widget follows the MVVM pattern by using the fatPercentageEntryProvider
/// to access the ViewModel that manages all business logic and state.
class FatPercentageEntry extends ConsumerWidget {
  const FatPercentageEntry({Key? key}) : super(key: key);

  /// Opens the fat percentage calculator view
  void _openCalculator(BuildContext context, WidgetRef ref) async {
    final viewModel = ref.read(fatPercentageEntryProvider.notifier);
    final result = await Navigator.push<double>(
      context,
      MaterialPageRoute(builder: (context) => const FatPercentageView()),
    );

    if (result != null) {
      viewModel.updateCalculatedFatPercentage(result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the fat percentage entry data from the ViewModel
    final entryData = ref.watch(fatPercentageEntryProvider);
    final viewModel = ref.read(fatPercentageEntryProvider.notifier);
    
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
                  controller: entryData.fatPercentageController,
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
                  onChanged: viewModel.onFatPercentageChanged,
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
                  onPressed: () => _openCalculator(context, ref),
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
