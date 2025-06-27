import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoogleAdsController extends GetxController {
  final isForTest = true;
  //! Change this value to false when generating signed apk to upload on store.
  final bannerAndroidTest = 'ca-app-pub-3940256099942544/6300978111';
  final interAndroidTest = 'ca-app-pub-3940256099942544/1033173712';
  final nativeAndroidTest = 'ca-app-pub-3940256099942544/2247696110';
  final rewardedAndroidTest = "ca-app-pub-3940256099942544/5224354917";

  final bannerAndroid = "";
  final interAndroid = "";
  final nativeAndroid = "";
  final rewardedAndroid = "ca-app-pub-4630063238239050/3858959112";

  final banneriOSTest = '';
  final interiOSTest = '';
  final nativeiOSTest = '';
  final rewardediOSTest = "";

  final banneriOS = "";
  final interiOS = "";
  final nativeiOS = "";
  final rewardediOS = "";

  // Increment count variable value on every button tap action.

  int noOfCount = 6;
  int count = 0;
  RxBool isShow = true.obs;

  // Show ads
  void showAds() {
    count += 1;
    if (count % noOfCount == 0) {
      showAdmobRewarded();
    }
  }

  void showLoadads() {
    if (isShow.value) {
      showAdmobRewarded();
    }
  }

  RewardedAd? _rewardedAd;

  //----------------------------------Create Google Rewarded Ad---------------------------------//
  void loadAdMobRewardedAd() {
    RewardedAd.load(
      adUnitId: getRewrededId(),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('==================$ad loaded================');
          _rewardedAd = ad;
          _rewardedAd?.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint(
              'Rewarded: Ad load failed (code=${error.code} message=${error.message})');
          Future.delayed(
            const Duration(milliseconds: 500),
            () {
              loadAdMobRewardedAd();
            },
          );
        },
      ),
    );
  }

  //! ________________________________________ Load Rewarded Ad ________________________________________________________
  void showAdmobRewarded() {
    if (_rewardedAd == null) {
      debugPrint("Warning: attempt to show rewarded before loaded.");
      return;
    }
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          debugPrint('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        loadAdMobRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        debugPrint(
            'Rewarded: Ad load failed (code=${error.code} message=${error.message})');
        Future.delayed(const Duration(milliseconds: 500), () {
          loadAdMobRewardedAd();
        });
      },
      onAdImpression: (RewardedAd ad) => debugPrint('$ad impression occurred.'),
    );

    _rewardedAd?.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
      debugPrint("reward the user for watching an ad");
    });
    _rewardedAd = null;
  }

  // BannerAd? bannerAd;
  // -------------------------- Banner ads --------------------------//
  // Future<void> loadBannerAds() async {
  //   BannerAd(
  //     adUnitId: getBannerId(),
  //     request: const AdRequest(),
  //     size: AdSize.largeBanner,
  //     listener: BannerAdListener(
  //       onAdLoaded: (ad) {
  //         bannerAd = ad as BannerAd;
  //         update(["Banner"]);
  //       },
  //       onAdFailedToLoad: (ad, err) {
  //         print('Failed to load a banner ad: ${err.message}');
  //         ad.dispose();
  //       },
  //     ),
  //   ).load();
  // }

  //---------------------------CreateInterstitial Ad-------------------------//
  // InterstitialAd? _interstitialAd;
  // int _numInterstitialLoadAttempts = 0;

  // void createInterstitialAd() {
  //   InterstitialAd.load(
  //     adUnitId: getInterId(),
  //     request: const AdRequest(
  //       keywords: <String>['foo', 'bar'],
  //       contentUrl: 'http://foo.com/bar.html',
  //       nonPersonalizedAds: true,
  //     ),
  //     adLoadCallback: InterstitialAdLoadCallback(
  //       onAdLoaded: (InterstitialAd ad) {
  //         debugPrint('==================$ad loaded================');
  //         _interstitialAd = ad;
  //         _numInterstitialLoadAttempts = 0;
  //         _interstitialAd?.setImmersiveMode(true);
  //       },
  //       onAdFailedToLoad: (LoadAdError error) {
  //         debugPrint(
  //             '=============InterstitialAd failed to load: $error.==============');
  //         _numInterstitialLoadAttempts += 1;
  //         _interstitialAd = null;
  //         if (_numInterstitialLoadAttempts < 3) {
  //           createInterstitialAd();
  //         }
  //       },
  //     ),
  //   );
  // }

  //--------------------------- Show Interstitial Ad-------------------------//

  // void showInterstitialAd() {
  //   if (_interstitialAd == null) {
  //     debugPrint('Warning: attempt to show interstitial before loaded.');
  //     return;
  //   }
  //   _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
  //       onAdShowedFullScreenContent: (InterstitialAd ad) =>
  //           debugPrint('ad onAdShowedFullScreenContent.'),
  //       onAdDismissedFullScreenContent: (InterstitialAd ad) {
  //         debugPrint(
  //             "******************** onAdDismissedFullScreenContent *******************************");
  //         debugPrint('$ad onAdDismissedFullScreenContent.');
  //         ad.dispose();
  //         createInterstitialAd();
  //       },
  //       onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
  //         ad.dispose();
  //         createInterstitialAd();
  //       },
  //       onAdWillDismissFullScreenContent: (InterstitialAd ad) {
  //         debugPrint("onAdWillDismissFullScreenContent");
  //       });

  //   _interstitialAd?.show();
  //   _interstitialAd = null;
  // }

  // Helper methods
  String getBannerId() {
    return Platform.isAndroid
        ? isForTest
            ? bannerAndroidTest
            : bannerAndroid
        : isForTest
            ? banneriOSTest
            : banneriOS;
  }

  String getInterId() {
    return Platform.isAndroid
        ? isForTest
            ? interAndroidTest
            : interAndroid
        : isForTest
            ? interiOSTest
            : interiOS;
  }

  String getNativeId() {
    return Platform.isAndroid
        ? isForTest
            ? nativeAndroidTest
            : nativeAndroid
        : isForTest
            ? nativeiOSTest
            : nativeiOS;
  }

  String getRewrededId() {
    return Platform.isAndroid
        ? isForTest
            ? rewardedAndroidTest
            : rewardedAndroid
        : isForTest
            ? rewardediOSTest
            : rewardediOS;
  }
}
