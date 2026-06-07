import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/filter_provider.dart';
import '../../core/theme/colors.dart';
import '../../data/models/filter_model.dart';
import '../../features/nearby/nearby_notifier.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  final bool isMapMode;
  const FilterBottomSheet({super.key, this.isMapMode = false});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late FilterModel tempFilter;

  @override
  @override
  void initState() {
    super.initState();
    if (widget.isMapMode) {
      final nearbyFilter = ref.read(nearbyNotifierProvider).nearbyFilter;
      tempFilter = FilterModel(
        minRating: nearbyFilter.minRating,
        onlyOpenNow: nearbyFilter.onlyOpen,
        mealType: nearbyFilter.mealType,
        cuisine: nearbyFilter.cuisine,
        budget: nearbyFilter.budget,
      );
    } else {
      tempFilter = ref.read(filterProvider);
    }
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
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.isMapMode ? 'Harita Filtreleri' : 'Gelişmiş Filtreler', 
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (!widget.isMapMode) ...[
                      _buildSection('Öğün', ['Kahvaltı', 'Öğle', 'Akşam', 'Atıştırmalık', 'Tatlı'], 
                        tempFilter.mealType, (val) => setState(() => tempFilter = tempFilter.setMealType(val))),
                      
                      _buildSection('Yer', ['Evde', 'Dışarıda', 'Ofiste', 'Öğrenci Evi'], 
                        tempFilter.place, (val) => setState(() => tempFilter = tempFilter.setPlace(val))),
                      
                      _buildTimeSection(),
                      
                      _buildSection('Bütçe', ['Ucuz', 'Orta', 'Pahalı'], 
                        tempFilter.budget, (val) => setState(() => tempFilter = tempFilter.setBudget(val))),
                      
                      _buildSection('Beslenme Tipi', ['Sağlıklı', 'Proteinli', 'Hafif', 'Doyurucu', 'Kaçamak', 'Vejetaryen'], 
                        tempFilter.dietTag, (val) => setState(() => tempFilter = tempFilter.setDietTag(val))),
                      
                      _buildSection('Mutfak Tipi', ['Türk', 'İtalyan', 'Fast Food', 'Asya', 'Fit Yemek'], 
                        tempFilter.cuisine, (val) => setState(() => tempFilter = tempFilter.setCuisine(val))),
                    ],

                    if (widget.isMapMode) ...[
                      _buildRatingSection(),
                      
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Sadece Açık Olanlar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        subtitle: const Text('Şu an hizmet veren mekanları göster', style: TextStyle(fontSize: 12)),
                        value: tempFilter.onlyOpenNow ?? false,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => tempFilter = tempFilter.setOnlyOpenNow(val)),
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),

                      _buildSection('Öğün', ['Kahvaltı', 'Öğle', 'Akşam', 'Atıştırmalık', 'Tatlı'], 
                        tempFilter.mealType, (val) => setState(() => tempFilter = tempFilter.setMealType(val))),
                      
                      _buildSection('Bütçe', ['Ucuz', 'Orta', 'Pahalı'], 
                        tempFilter.budget, (val) => setState(() => tempFilter = tempFilter.setBudget(val))),
                      
                      _buildSection('Mutfak Tipi', ['Türk', 'İtalyan', 'Fast Food', 'Asya', 'Fit Yemek'], 
                        tempFilter.cuisine, (val) => setState(() => tempFilter = tempFilter.setCuisine(val))),
                    ],
                    
                    const SizedBox(height: 80),
                  ],
                ),
              ),
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
                          if (widget.isMapMode) {
                            final newNearbyFilter = ref.read(nearbyNotifierProvider).nearbyFilter.copyWith(
                              minRating: tempFilter.minRating,
                              onlyOpen: tempFilter.onlyOpenNow ?? false,
                              mealType: tempFilter.mealType,
                              cuisine: tempFilter.cuisine,
                              budget: tempFilter.budget,
                              clearMinRating: tempFilter.minRating == null,
                              clearMealType: tempFilter.mealType == null,
                              clearCuisine: tempFilter.cuisine == null,
                              clearBudget: tempFilter.budget == null,
                            );
                            ref.read(nearbyNotifierProvider.notifier).updateNearbyFilter(newNearbyFilter);
                          } else {
                            ref.read(filterProvider.notifier).updateFilter(tempFilter);
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('Uygula', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom),
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
              showCheckmark: false,
              label: Text(opt),
              selected: isSelected,
              onSelected: (selected) => onSelect(selected ? opt : null),
              selectedColor: AppColors.primary,
              elevation: isSelected ? 4 : 0,
              pressElevation: 2,
              shadowColor: AppColors.primary.withOpacity(0.3),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected ? AppColors.primary.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                ),
              ),
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
              showCheckmark: false,
              label: Text(t >= 45 ? '$t+ dk' : '$t dk'),
              selected: isSelected,
              onSelected: (selected) => setState(() => tempFilter = tempFilter.setMaxTime(selected ? t : null)),
              selectedColor: AppColors.primary,
              elevation: isSelected ? 4 : 0,
              pressElevation: 2,
              shadowColor: AppColors.primary.withOpacity(0.3),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected ? AppColors.primary.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRatingSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ratings = [4.0, 4.5];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Minimum Puan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ratings.map((r) {
            final isSelected = tempFilter.minRating == r;
            return ChoiceChip(
              showCheckmark: false,
              avatar: Icon(
                Icons.star_rounded, 
                size: 18, 
                color: isSelected ? Colors.white : Colors.amber.shade700
              ),
              label: Text('$r Üzeri'),
              selected: isSelected,
              onSelected: (selected) => setState(() => tempFilter = tempFilter.setMinRating(selected ? r : null)),
              selectedColor: AppColors.primary,
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
