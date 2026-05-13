import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/filter_model.dart';

final filterProvider = StateNotifierProvider<FilterNotifier, FilterModel>((ref) {
  return FilterNotifier();
});

class FilterNotifier extends StateNotifier<FilterModel> {
  FilterNotifier() : super(FilterModel());

  void updateFilter(FilterModel newFilter) {
    state = newFilter;
  }

  void clearFilters() {
    state = FilterModel();
  }
}
