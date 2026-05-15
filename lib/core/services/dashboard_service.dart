import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardService with WidgetsBindingObserver {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  bool _isInitialized = false;

  // Dashboard projesi Firestore REST endpoint
  static const String _projectId = 'dashboard-baf3f';
  static const String _apiKey = 'AIzaSyBPOS5L2Qdoi0kVXgyQnCoWuAdbUfh_YAo';
  static final String _baseUrl =
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents';

  // Oturum takibi
  DateTime? _sessionStartTime;
  String? _currentUserId;
  String? _currentVisitId;
  int _totalSecondsThisSession = 0;
  Timer? _heartbeatTimer;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addObserver(this);
    });

    debugPrint('✅ Dashboard Servisi hazır (REST API modu)');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _updateCurrentSessionDuration();
      _stopHeartbeat();
    } else if (state == AppLifecycleState.resumed) {
      _sessionStartTime = DateTime.now();
      _startHeartbeat();
    }
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _updateCurrentSessionDuration();
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> _updateCurrentSessionDuration() async {
    if (_sessionStartTime == null ||
        _currentUserId == null ||
        _currentVisitId == null) {
      return;
    }

    final now = DateTime.now();
    final elapsed = now.difference(_sessionStartTime!).inSeconds;
    _totalSecondsThisSession += elapsed;
    _sessionStartTime = now;

    await _patchDocument(
      'users/$_currentUserId/visits/$_currentVisitId',
      {
        'durationSeconds': {'integerValue': '$_totalSecondsThisSession'},
        'lastUpdate': {'timestampValue': now.toUtc().toIso8601String()},
      },
    );
  }

  /// Kullanıcı verilerini ve ziyaretlerini kaydeder
  Future<void> logVisit({
    required String name,
    required Map<String, dynamic> additionalData,
  }) async {
    if (!_isInitialized) return;

    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    final platform = Platform.isIOS ? 'iOS' : 'Android';
    
    _currentUserId = name.replaceAll(' ', '_').toLowerCase();
    _currentVisitId = DateTime.now().millisecondsSinceEpoch.toString();

    // 1. Kullanıcı Profili Güncelle
    await _patchDocument('users/$_currentUserId', {
      'name': {'stringValue': name},
      'platform': {'stringValue': platform},
      'appVersion': {'stringValue': appVersion},
      'lastVisit': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
      'appId': {'stringValue': 'whattoeat'},
      ..._mapToFirestoreFields(additionalData),
    });

    // 2. Ziyaret Kaydı Oluştur
    final now = DateTime.now();
    await _setDocument('users/$_currentUserId/visits/$_currentVisitId', {
      'date': {'stringValue': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}'},
      'time': {'stringValue': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}'},
      'platform': {'stringValue': platform},
      'appVersion': {'stringValue': appVersion},
      'timestamp': {'timestampValue': now.toUtc().toIso8601String()},
      'appId': {'stringValue': 'whattoeat'},
      'durationSeconds': {'integerValue': '0'},
    });

    _sessionStartTime = DateTime.now();
    _totalSecondsThisSession = 0;
    _startHeartbeat();
  }

  /// Versiyon kontrolü yapar ve gerekirse popup gösterir
  Future<void> checkForUpdate(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/settings/app_config_wte?key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fields = data['fields'];
        
        final remoteBuildNumber = int.tryParse(fields['buildNumber']?['integerValue'] ?? '0') ?? 0;
        final androidUrl = fields['androidUrl']?['stringValue'] ?? '';
        final iosUrl = fields['iosUrl']?['stringValue'] ?? '';

        final packageInfo = await PackageInfo.fromPlatform();
        final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

        if (remoteBuildNumber > currentBuildNumber) {
          if (context.mounted) {
            _showUpdateDialog(context, Platform.isIOS ? iosUrl : androidUrl);
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Update check error: $e');
    }
  }

  void _showUpdateDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Güncelleme Mevcut! 🚀'),
        content: const Text(
          'Uygulamanın yeni bir sürümü mevcut. Daha iyi bir deneyim için lütfen güncelleyin.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Daha Sonra'),
          ),
          ElevatedButton(
            onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
            ),
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  // Firestore REST Helpers
  Future<bool> _setDocument(String path, Map<String, dynamic> fields) async {
    try {
      final uri = Uri.parse('$_baseUrl/$path?key=$_apiKey');
      final res = await http.patch(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'fields': fields}));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> _patchDocument(String path, Map<String, dynamic> fields) async {
    try {
      final updateMask = fields.keys.map((k) => 'updateMask.fieldPaths=$k').join('&');
      final uri = Uri.parse('$_baseUrl/$path?key=$_apiKey&$updateMask');
      await http.patch(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'fields': fields}));
    } catch (e) {}
  }

  Map<String, dynamic> _mapToFirestoreFields(Map<String, dynamic> data) {
    final Map<String, dynamic> fields = {};
    data.forEach((key, value) {
      if (value is String) {
        fields[key] = {'stringValue': value};
      } else if (value is int) {
        fields[key] = {'integerValue': '$value'};
      } else if (value is bool) {
        fields[key] = {'booleanValue': value};
      } else if (value is List) {
        fields[key] = {
          'arrayValue': {
            'values': value.map((e) => {'stringValue': e.toString()}).toList()
          }
        };
      }
    });
    return fields;
  }
}
