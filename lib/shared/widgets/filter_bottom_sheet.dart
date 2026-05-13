import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/filter_provider.dart';
import '../../core/theme/colors.dart';
import '../../data/models/filter_model.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late FilterModel tempFilter;

  @override
  void initState() {
    super.initState();
    // Copy the current global filter to temporary state for UI editing
    tempFilter = ref.read(filterProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              )
            ]
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Gelişmiş Filtreler', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),
              const Divider(),

              // Filter Lists
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildSection('Öğün', ['Kahvaltı', 'Öğle', 'Akşam', 'Atıştırmalık', 'Tatlı'], 
                      tempFilter.mealType, (val) => setState(() => tempFilter = tempFilter.copyWith(mealType: val))),
                    
                    _buildSection('Yer', ['Evde', 'Dışarıda', 'Ofiste', 'Öğrenci Evi'], 
                      tempFilter.place, (val) => setState(() => tempFilter = tempFilter.copyWith(place: val))),
                    
                    _buildTimeSection(),
                    
                    _buildSection('Bütçe', ['Ucuz', 'Orta', 'Pahalı'], 
                      tempFilter.budget, (val) => setState(() => tempFilter = tempFilter.copyWith(budget: val))),
                    
                    _buildSection('Beslenme Tipi', ['Sağlıklı', 'Proteinli', 'Hafif', 'Doyurucu', 'Kaçamak', 'Vejetaryen'], 
                      tempFilter.dietTag, (val) => setState(() => tempFilter = tempFilter.copyWith(dietTag: val))),
                    
                    _buildSection('Mutfak Tipi', ['Türk', 'İtalyan', 'Fast Food', 'Asya', 'Fit Yemek'], 
                      tempFilter.cuisine, (val) => setState(() => tempFilter = tempFilter.copyWith(cuisine: val))),
                    
                    const SizedBox(height: 80), // Padding for bottom actions
                  ],
                ),
              ),

              // Bottom Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() => tempFilter = FilterModel());
                        },
                        child: const Text('Temizle', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () {
                          ref.read(filterProvider.notifier).updateFilter(tempFilter);
                          Navigator.pop(context);
                        },
                        child: const Text('Uygula', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<String> options, String? selectedValue, Function(String?) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = selectedValue == opt;
            return ChoiceChip(
              label: Text(opt),
              selected: isSelected,
              onSelected: (selected) => onSelect(selected ? opt : null),
              selectedColor: AppColors.secondary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTimeSection() {
    final times = [5, 10, 20, 30, 45, 60];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Maksimum Süre', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: times.map((t) {
            final isSelected = tempFilter.maxTime == t;
            return ChoiceChip(
              label: Text(t >= 45 ? '$t+ dk' : '$t dk'),
              selected: isSelected,
              onSelected: (selected) => setState(() => tempFilter = tempFilter.copyWith(maxTime: selected ? t : null)),
              selectedColor: AppColors.secondary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
