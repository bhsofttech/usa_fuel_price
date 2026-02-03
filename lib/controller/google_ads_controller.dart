import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:usa_gas_price/main.dart';

class GoogleAdsController extends GetxController {
  // Change this value to false when generating signed apk to upload on store.

  static const int navigationFrequency = 3;
  static const int maxFailedLoadAttempts = 3;

  InterstitialAd? _interstitialAd;
  bool _isLoading = false;
  int _failedAttempts = 0;
  int _navigationCount = 0;

  final AdRequest _request = const AdRequest();

  /// 🎯 Ad Unit ID
  String get interstitialAdUnitId {
    if (isTestMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    } else {
      return Platform.isAndroid
          ? 'ca-app-pub-4630063238239050/7049935488'
          : 'ca-app-pub-xxxxxxxx/interstitial_ios ';
    }
  }

  /// ✅ Load Interstitial Ad
  void loadInterstitialAd() {
    if (_isLoading || _interstitialAd != null) return;

    _isLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: _request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _failedAttempts = 0;
          _isLoading = false;
          debugPrint('================== InterstitialAd loaded ==========');
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isLoading = false;
          _failedAttempts++;

          debugPrint('InterstitialAd failed to load: $error');

          if (_failedAttempts < maxFailedLoadAttempts) {
            Future.delayed(const Duration(seconds: 3), () {
              loadInterstitialAd();
            });
          }
        },
      ),
    );
  }

  /// 🧠 CENTRALIZED NAVIGATION
  navigateWithAd({Widget? nextPage, VoidCallback? onAction}) {
    _navigationCount++;

    /// Load Ads
    if (_navigationCount == 2 && _interstitialAd == null) {
      loadInterstitialAd();
    }

    if (_navigationCount >= navigationFrequency && _interstitialAd != null) {
      _navigationCount = 0;
      _showInterstitial(nextPage: nextPage, onAction: onAction);
    } else {
      if (nextPage != null) {
        Get.to(nextPage);
      } else {
        onAction?.call();
      }
    }
  }

  /// 📺 SHOW INTERSTITIAL
  void _showInterstitial({Widget? nextPage, VoidCallback? onAction}) {
    final ad = _interstitialAd;
    _interstitialAd = null;

    ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitialAd();
        if (nextPage != null) {
          Get.to(nextPage);
        } else {
          onAction?.call();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadInterstitialAd();
        if (nextPage != null) {
          Get.to(nextPage);
        } else {
          onAction?.call();
        }
      },
    );

    ad.show();
  }

  void showAds() {}
}




// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// class GoogleAdsController extends GetxController {
//   final isForTest = true;
//   //! Change this value to false when generating signed apk to upload on store.
//   final bannerAndroidTest = 'ca-app-pub-3940256099942544/6300978111';
//   final interAndroidTest = 'ca-app-pub-3940256099942544/1033173712';
//   final nativeAndroidTest = 'ca-app-pub-3940256099942544/2247696110';
//   final rewardedAndroidTest = "ca-app-pub-3940256099942544/5224354917";
//   final appOpenAndroidTest = "ca-app-pub-3940256099942544/9257395921";

//   final bannerAndroid = "ca-app-pub-4630063238239050/6296336993";
//   final interAndroid = "";
//   final nativeAndroid = "";
//   final rewardedAndroid = "ca-app-pub-4630063238239050/3858959112";
//   final appOpenAndroid = "ca-app-pub-4630063238239050/3262694131";

//   final banneriOSTest = '';
//   final interiOSTest = '';
//   final nativeiOSTest = '';
//   final rewardediOSTest = "";
//   final appOpenIosTest = "";

//   final banneriOS = "";
//   final interiOS = "";
//   final nativeiOS = "";
//   final rewardediOS = "";
//   final appOpeniOS = "";

//   // Increment count variable value on every button tap action.

//   int noOfCount = 5;
//   int count = 0;
//   RxBool isShow = true.obs;

//   // Show ads
//   void showAds() {
//     count += 1;
//     if (count % noOfCount == 0) {
//       showAdmobRewarded();
//     }
//   }

//   // void showLoadads() {
//   //   if (isShow.value) {
//   //     showAdmobRewarded();
//   //   }
//   // }

//   RewardedAd? _rewardedAd;
//   int _numRewardedLoadAttempts = 0;


//   //----------------------------------Create Google Rewarded Ad---------------------------------//
//   void loadAdMobRewardedAd() {
//     RewardedAd.load(
//       adUnitId: getRewrededId(),
//       request: const AdRequest(),
//       rewardedAdLoadCallback: RewardedAdLoadCallback(
//         onAdLoaded: (RewardedAd ad) {
//           debugPrint('==================$ad loaded================');
//           _rewardedAd = ad;
//           _numRewardedLoadAttempts = 0;
//           _rewardedAd?.setImmersiveMode(true);
//         },
//         onAdFailedToLoad: (LoadAdError error) {
//           debugPrint(
//               'Rewarded: Ad load failed (code=${error.code} message=${error.message})');
//           _numRewardedLoadAttempts += 1;
//           _rewardedAd = null;
//           if (_numRewardedLoadAttempts < 3) {
//             Future.delayed(
//               const Duration(seconds: 3),
//               () {
//                 loadAdMobRewardedAd();
//               },
//             );
//           }
//         },
//       ),
//     );
//   }

//   //! ________________________________________ Load Rewarded Ad ________________________________________________________
//   void showAdmobRewarded() {
//     if (_rewardedAd == null) {
//       debugPrint("Warning: attempt to show rewarded before loaded.");
//       return;
//     }
//     _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
//       onAdShowedFullScreenContent: (RewardedAd ad) =>
//           debugPrint('$ad onAdShowedFullScreenContent.'),
//       onAdDismissedFullScreenContent: (RewardedAd ad) {
//         debugPrint('$ad onAdDismissedFullScreenContent.');
//         ad.dispose();
//         loadAdMobRewardedAd();
//       },
//       onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
//         ad.dispose();
//         debugPrint(
//             'Rewarded: Ad load failed (code=${error.code} message=${error.message})');
//         _numRewardedLoadAttempts += 1;
//         if (_numRewardedLoadAttempts < 3) {
//           Future.delayed(const Duration(seconds: 3), () {
//             loadAdMobRewardedAd();  
//           });
//         }
//       },
//       onAdImpression: (RewardedAd ad) => debugPrint('$ad impression occurred.'),
//     );

//     _rewardedAd?.show(
//         onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
//       debugPrint("reward the user for watching an ad");
//     });
//     _rewardedAd = null;
//   }

//   //----------------------------- App opne Ads -------------------------------//

//   AppOpenAd? _appOpenAd;

//   // Future<void> loadAppOpenAd() async {
//   //   AppOpenAd.load(
//   //     adUnitId: getAppOpneId(), // test id
//   //     request: const AdRequest(),
//   //     adLoadCallback: AppOpenAdLoadCallback(
//   //       onAdLoaded: (ad) {
//   //         _appOpenAd = ad;
//   //       },
//   //       onAdFailedToLoad: (error) {
//   //         debugPrint('AppOpenAd failed to load: $error');
//   //       },
//   //     ),
//   //   );
//   // }

//   bool _isShowingAd = false;

//   // Future<void> showAppOpenAd() async {
//   //   if (_appOpenAd == null || _isShowingAd) return;

//   //   _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
//   //     onAdShowedFullScreenContent: (ad) {
//   //       _isShowingAd = true;
//   //       debugPrint('Ad showed.');
//   //     },
//   //     onAdDismissedFullScreenContent: (ad) {
//   //       _isShowingAd = false;
//   //       ad.dispose();
//   //       loadAppOpenAd(); // Preload next ad
//   //     },
//   //     onAdFailedToShowFullScreenContent: (ad, error) {
//   //       _isShowingAd = false;
//   //       ad.dispose();
//   //       loadAppOpenAd();
//   //     },
//   //   );
//   //   _appOpenAd!.show();
//   // }

// //----------------------------------------------------------------------------//

// //  BannerAd? bannerAd;
//   // ------------------------------- Banner ads ------------------------------//
//   // Future<void> loadBannerAds() async {
//   //   BannerAd(
//   //     adUnitId: getBannerId(),
//   //     request: const AdRequest(),
//   //     size: AdSize.banner,
//   //     listener: BannerAdListener(
//   //       onAdLoaded: (ad) {
//   //         bannerAd = ad as BannerAd;
//   //         update(["Banner"]);
//   //       },
//   //       onAdFailedToLoad: (ad, err) {
//   //         print('Failed to load a banner ad: ${err.message}');
//   //         ad.dispose();
//   //       },
//   //     ),
//   //   ).load();
//   // }

//   //---------------------------CreateInterstitial Ad-------------------------//
//   // InterstitialAd? _interstitialAd;
//   // int _numInterstitialLoadAttempts = 0;

//   // void createInterstitialAd() {
//   //   InterstitialAd.load(
//   //     adUnitId: getInterId(),
//   //     request: const AdRequest(
//   //       keywords: <String>['foo', 'bar'],
//   //       contentUrl: 'http://foo.com/bar.html',
//   //       nonPersonalizedAds: true,
//   //     ),
//   //     adLoadCallback: InterstitialAdLoadCallback(
//   //       onAdLoaded: (InterstitialAd ad) {
//   //         debugPrint('==================$ad loaded================');
//   //         _interstitialAd = ad;
//   //         _numInterstitialLoadAttempts = 0;
//   //         _interstitialAd?.setImmersiveMode(true);
//   //       },
//   //       onAdFailedToLoad: (LoadAdError error) {
//   //         debugPrint(
//   //             '=============InterstitialAd failed to load: $error.==============');
//   //         _numInterstitialLoadAttempts += 1;
//   //         _interstitialAd = null;
//   //         if (_numInterstitialLoadAttempts < 3) {
//   //           createInterstitialAd();
//   //         }
//   //       },
//   //     ),
//   //   );
//   // }

//   //--------------------------- Show Interstitial Ad-------------------------//

//   // void showInterstitialAd() {
//   //   if (_interstitialAd == null) {
//   //     debugPrint('Warning: attempt to show interstitial before loaded.');
//   //     return;
//   //   }
//   //   _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
//   //       onAdShowedFullScreenContent: (InterstitialAd ad) =>
//   //           debugPrint('ad onAdShowedFullScreenContent.'),
//   //       onAdDismissedFullScreenContent: (InterstitialAd ad) {
//   //         debugPrint(
//   //             "******************** onAdDismissedFullScreenContent *******************************");
//   //         debugPrint('$ad onAdDismissedFullScreenContent.');
//   //         ad.dispose();
//   //         createInterstitialAd();
//   //       },
//   //       onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
//   //         ad.dispose();
//   //         createInterstitialAd();
//   //       },
//   //       onAdWillDismissFullScreenContent: (InterstitialAd ad) {
//   //         debugPrint("onAdWillDismissFullScreenContent");
//   //       });

//   //   _interstitialAd?.show();
//   //   _interstitialAd = null;
//   // }

//   // Helper methods
//   // String getBannerId() {
//   //   return Platform.isAndroid
//   //       ? isForTest
//   //           ? bannerAndroidTest
//   //           : bannerAndroid
//   //       : isForTest
//   //           ? banneriOSTest
//   //           : banneriOS;
//   // }

//   // String getInterId() {
//   //   return Platform.isAndroid
//   //       ? isForTest
//   //           ? interAndroidTest
//   //           : interAndroid
//   //       : isForTest
//   //           ? interiOSTest
//   //           : interiOS;
//   // }

//   // String getNativeId() {
//   //   return Platform.isAndroid
//   //       ? isForTest
//   //           ? nativeAndroidTest
//   //           : nativeAndroid
//   //       : isForTest
//   //           ? nativeiOSTest
//   //           : nativeiOS;
//   // }

//   String getRewrededId() {
//     return Platform.isAndroid
//         ? isForTest
//             ? rewardedAndroidTest
//             : rewardedAndroid
//         : isForTest
//             ? rewardediOSTest
//             : rewardediOS;
//   }

//   String getAppOpneId() {
//     return Platform.isAndroid
//         ? isForTest
//             ? appOpenAndroidTest
//             : appOpenAndroid
//         : isForTest
//             ? appOpenIosTest
//             : appOpeniOS;
//   }
// }
