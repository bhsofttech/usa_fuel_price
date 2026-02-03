import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:usa_gas_price/main.dart';

class RewardAdsController extends GetxController {
  /// ================= CONFIG =================
  static const int maxFailedLoadAttempts = 3;

  /// ================= STATE ==================
  RewardedAd? _rewardedAd;
  bool _isLoading = false;
  bool _isShowingAd = false;
  int _failedAttempts = 0;

  final AdRequest _request = const AdRequest();

  /// ================= AD UNIT ID =================
  String get rewardedAdUnitId {
    if (isTestMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';
    } else {
      return Platform.isAndroid
          ? 'ca-app-pub-4630063238239050/3858959112'
          : 'YOUR_IOS_REWARDED_AD_UNIT_ID';
    }
  }

  /// ================= LOAD REWARDED AD =================
  void _loadRewardedAd({
    VoidCallback? onAdLoaded,
    VoidCallback? onAdFailedToLoad,
  }) {
    if (_isLoading || _rewardedAd != null) return;

    _isLoading = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: _request,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _failedAttempts = 0;
          _isLoading = false;

          debugPrint('✅ Rewarded Ad Loaded');

          // Call optional callback
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          _isLoading = false;
          _failedAttempts++;

          debugPrint('❌ Rewarded Ad Failed to Load: $error');

          // Call optional callback
          onAdFailedToLoad?.call();

          if (_failedAttempts < maxFailedLoadAttempts) {
            Future.delayed(const Duration(seconds: 2), _loadRewardedAd);
          }
        },
      ),
    );
  }

  /// ================= LOAD AND SHOW REWARDED AD (ON DEMAND) =================
  void loadAndShowRewardedAd({
    required VoidCallback onAdLoaded,
    required VoidCallback onRewardEarned,
    required VoidCallback onAdSkipped,
    required VoidCallback onAdFailedToLoad,
  }) {
    /// 🚫 Prevent double tap / multiple shows
    if (_isShowingAd || _isLoading) return;

    // Use existing loadRewardedAd function with callbacks
    _loadRewardedAd(
      onAdLoaded: () {
        debugPrint('✅ Rewarded Ad Loaded - Showing now');

        // Notify that ad is loaded
        onAdLoaded();

        // Show ad immediately
        _showLoadedAd(
          onRewardEarned: onRewardEarned,
          onAdSkipped: onAdSkipped,
        );
      },
      onAdFailedToLoad: () {
        debugPrint('❌ Failed to load ad for unlock');
        onAdFailedToLoad();
      },
    );
  }

  /// ================= SHOW LOADED AD (INTERNAL) =================
  void _showLoadedAd({
    required VoidCallback onRewardEarned,
    required VoidCallback onAdSkipped,
  }) {
    if (_rewardedAd == null || _isShowingAd) return;

    _isShowingAd = true;

    final RewardedAd ad = _rewardedAd!;
    _rewardedAd = null;

    bool rewardEarned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isShowingAd = false;

        debugPrint('📱 Ad Dismissed - Reward Earned: $rewardEarned');

        /// ✅ Call appropriate callback
        if (rewardEarned) {
          onRewardEarned();
        } else {
          onAdSkipped();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isShowingAd = false;

        debugPrint('❌ Ad Failed to Show: $error');
        onAdSkipped();
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        rewardEarned = true;
        debugPrint(
          '🎉 Reward Earned → ${reward.amount} ${reward.type}',
        );
      },
    );
  }

  /// ================= LIFECYCLE =================
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    _rewardedAd?.dispose();
    super.onClose();
  }
}
