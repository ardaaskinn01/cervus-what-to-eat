import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/shared_prefs_provider.dart';
import '../models/history_model.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(ref.read(sharedPreferencesProvider));
});

class HistoryRepository {
  final SharedPreferences _prefs;
  static const _historyKey = 'history_entries';

  HistoryRepository(this._prefs);

  List<HistoryEntry> getAll() {
    final str = _prefs.getString(_historyKey);
    if (str == null) return [];
    final decoded = jsonDecode(str) as List;
    return decoded.map((e) => HistoryEntry.fromJson(e)).toList().cast<HistoryEntry>();
  }

  void addEntry(HistoryEntry entry) {
    final entries = getAll();
    entries.insert(0, entry); // Add to beginning (latest first)
    _prefs.setString(_historyKey, jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  List<HistoryEntry> getToday() {
    final now = DateTime.now();
    return getAll().where((e) {
      return e.date.year == now.year && e.date.month == now.month && e.date.day == now.day;
    }).toList();
  }

  List<HistoryEntry> getLast7Days() {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return getAll().where((e) => e.date.isAfter(sevenDaysAgo)).toList();
  }
}
