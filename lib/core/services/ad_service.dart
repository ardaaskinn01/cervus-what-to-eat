import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IMPORTANT SETUP NOTES FOR ADMOB:
/// AndroidManifest.xml:
/// <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="ca-app-pub-xxxxxxxxxx~yyyyyyyyyy"/>
///
/// Info.plist:
/// <key>GADApplicationIdentifier</key>
/// <string>ca-app-pub-xxxxxxxxxx~yyyyyyyyyy</string>

class AdService {
  static final AdService instance = AdService._();
  AdService._();

  late SharedPreferences _prefs;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  int _suggestionCount = 0;

  bool get isPremium => _prefs.getBool('is_premium') ?? false;

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    if (isPremium) return;
    await MobileAds.instance.initialize();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  void setPremium(bool val) {
    _prefs.setBool('is_premium', val);
    if (val) {
      _interstitialAd?.dispose();
      _rewardedAd?.dispose();
    } else {
      _loadInterstitialAd();
      _loadRewardedAd();
    }
  }

  void _loadInterstitialAd() {
    if (isPremium) return;
    InterstitialAd.load(
      adUnitId: Platform.isAndroid ? 'ca-app-pub-2073707860224174/4670414927' : 'ca-app-pub-2073707860224174/3197551152',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  void _loadRewardedAd() {
    if (isPremium) return;
    RewardedAd.load(
      adUnitId: Platform.isAndroid ? 'ca-app-pub-3940256099942544/5224354917' : 'ca-app-pub-3940256099942544/1712485313',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) => _rewardedAd = null,
      ),
    );
  }

  void onSuggestionRequested(VoidCallback onContinue) {
    if (isPremium) {
      onContinue();
      return;
    }
    
    _suggestionCount++;
    // 5 tıklamada öneri verilir, 6. tıklamada (yani sayaç 6 olduğunda) reklam gösterilir.
    if (_suggestionCount >= 6 && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
          _suggestionCount = 0; // Sayaç temizlenir
          onContinue();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadInterstitialAd();
          _suggestionCount = 0; // Başarısız olsa da devam etsin ve sıfırlansın
          onContinue();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      onContinue();
    }
  }

  void showRewardedAd({required VoidCallback onEarnedReward, required VoidCallback onFailed}) {
    if (isPremium) {
      onEarnedReward();
      return;
    }

    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewardedAd();
        },
      );
      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        onEarnedReward();
      });
      _rewardedAd = null;
    } else {
      onFailed();
    }
  }

  static String? getBannerAdUnitId(String? routeName) {
    if (Platform.isAndroid) {
      switch (routeName) {
        case '/home':
          return 'ca-app-pub-2073707860224174/9860684934';
        case '/suggestion':
          return 'ca-app-pub-2073707860224174/8573950588';
        case '/favorites':
          return 'ca-app-pub-2073707860224174/5797108380';
        case '/weekly_plan':
          return 'ca-app-pub-2073707860224174/5204561537';
        case '/settings':
          return 'ca-app-pub-2073707860224174/3891479868';
        default:
          return 'ca-app-pub-2073707860224174/9860684934'; // Default to Home
      }
    } else {
      // iOS
      switch (routeName) {
        case '/home':
          return 'ca-app-pub-2073707860224174/8920349800';
        case '/suggestion':
          return 'ca-app-pub-2073707860224174/4826277266';
        case '/favorites':
          return 'ca-app-pub-2073707860224174/3457355278';
        case '/weekly_plan':
          return 'ca-app-pub-2073707860224174/9927925086';
        case '/settings':
          return 'ca-app-pub-2073707860224174/8074267459';
        default:
          return 'ca-app-pub-2073707860224174/8920349800'; // Default to Home
      }
    }
  }
}
