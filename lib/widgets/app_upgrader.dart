// import 'dart:io';

// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:vibrator/controller/google_ads_controller.dart';
// import 'package:vibrator/widgets/custom_text.dart';

// import '../controller/vibrator_controller.dart';

// class AppUpgrader {
//   static RemoteConfigObj? remoteConfigObj;
//   static Future<void> versionCheck(context) async {
//     RemoteConfigObj remoteConfigInfo;

//     try {
//       //Get Current installed version of app
//       final PackageInfo info = await PackageInfo.fromPlatform();
//       String currentVersion = info.version;

//       //Get Latest version info from firebase config
//       final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

//       // Using default duration to force fetching from remote server.
//       await remoteConfig.setConfigSettings(
//         RemoteConfigSettings(
//           // Maximum Duration to wait for a response when fetching configuration from the Remote Config server. Defaults to one minute.
//           fetchTimeout: const Duration(minutes: 1),
//           // Maximum age of a cached config before it is considered stale. Defaults to twelve hours.
//           minimumFetchInterval: Duration.zero,
//         ),
//       );
//       await remoteConfig.fetchAndActivate();

//       Map<String, dynamic> remoteConfigJson = {};

//       remoteConfig.getAll().entries.forEach((config) {
//         remoteConfigJson.addAll({config.key: config.value.asString()});
//       });

//       // Get remoteConfigInfo from Json...
//       remoteConfigInfo = remoteConfigInfoFromJson(remoteConfigJson);
//       remoteConfigObj = remoteConfigInfo;
//       Get.find<GoogleAdsController>().remoteConfigInfo = remoteConfigInfo;

//       if (remoteConfigInfo.showUpdateAlert(currentVersion)) {
//         // ignore: use_build_context_synchronously
//         showDialog(
//           barrierDismissible: false,
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const CustomText(
//               txtTitle: "New Version Available",
//               style: TextStyle(fontSize: 16.0, fontFamily: "RiformaLL"),
//             ),
//             content: CustomText(
//               txtTitle:
//                   "A new version of ${info.appName} is available. please update your application.",
//               style: const TextStyle(
//                   fontSize: 16.0,
//                   fontFamily: "RiformaLL",
//                   fontWeight: FontWeight.w500),
//             ),
//             actions: [
//               ElevatedButton(
//                 style: ButtonStyle(
//                   shape: MaterialStateProperty.all<OutlinedBorder>(
//                       RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   )),
//                   backgroundColor:
//                       MaterialStateProperty.all<Color>(const Color(0xFF8F8FFF)),
//                 ),
//                 onPressed: () {
//                   Get.back();
//                   launchURL(remoteConfigInfo.storeURL, context);
//                 },
//                 child: CustomText(
//                   align: TextAlign.start,
//                   txtTitle: "Update now".toUpperCase(),
//                   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w500,
//                       ),
//                   maxLine: 1,
//                   textOverflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//         );
//       }
//     } on PlatformException catch (e) {
//       debugPrint(e.message ?? "");
//     } catch (exception) {
//       debugPrint(
//           'Unable to fetch remote config. Cached or default values will be used');
//     }
//   }

//   // Launch url...
//   static launchURL(String url, BuildContext context) async {
//     try {
//       Uri uri = Uri.parse(url);
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri);
//       } else {
//         throw 'Unable to update at moment, please try again later';
//       }
//     } catch (e) {
//       debugPrint("");
//     }
//   }
// }

// RemoteConfigObj remoteConfigInfoFromJson(Map<String, dynamic> info) =>
//     RemoteConfigObj.fromJson(info);

// class RemoteConfigObj {
//   RemoteConfigObj(
//       {this.forceUpdateCurrentVersionIos = "",
//       this.forceUpdateCurrentVersionAndroid = "",
//       this.storeURLiOS = "",
//       this.storeURLAndroid = "",
//       this.googlePlaceKeyIos = "",
//       this.googlePlaceKeyAndroid = "",
//       this.discordLink = "",
//       this.inviteSMSMsg = "",
//       this.companyStoreURLAndroid = "",
//       this.companyStoreURLiOS = "",
//       this.imageUrl = "",
//       this.count});

//   String forceUpdateCurrentVersionIos;
//   String forceUpdateCurrentVersionAndroid;
//   String storeURLiOS;
//   String storeURLAndroid;
//   String googlePlaceKeyIos;
//   String googlePlaceKeyAndroid;
//   String discordLink;
//   String inviteSMSMsg;
//   String companyStoreURLiOS;
//   String companyStoreURLAndroid;
//   String imageUrl;
//   int? count;

//   factory RemoteConfigObj.fromJson(Map<String, dynamic> json) =>
//       RemoteConfigObj(
//           forceUpdateCurrentVersionIos:
//               json["force_update_current_version_ios"] ?? "0.0.0",
//           forceUpdateCurrentVersionAndroid:
//               json["force_update_current_version_android"] ?? "0.0.0",
//           storeURLiOS: json["store_url_ios"] ?? "",
//           storeURLAndroid: json["store_url_android"] ?? "",
//           companyStoreURLiOS: json["company_profile_url_ios"] ?? "",
//           companyStoreURLAndroid: json["company_profile_url_android"] ?? "",
//           imageUrl: json["image_url"] ?? "",
//           count: int.parse(json["count"]??8));

//   Map<String, dynamic> toJson() => {
//         "force_update_current_version_ios": forceUpdateCurrentVersionIos,
//         "force_update_current_version_android":
//             forceUpdateCurrentVersionAndroid,
//         "store_url_android": storeURLAndroid,
//         "store_url_ios": storeURLiOS,
//         "image_url": imageUrl,
//         "count": count
//       };

//   // Get Store URL...
//   String get storeURL => Platform.isAndroid ? storeURLAndroid : storeURLiOS;

//   // Force update version number...
//   String get forceUpdateVersion => Platform.isAndroid
//       ? forceUpdateCurrentVersionAndroid
//       : forceUpdateCurrentVersionIos;

//   // Show update alert...
//   bool showUpdateAlert(String currentVersion) {
//     try {
//       debugPrint("Current version : ${_getFormatedVersion(currentVersion)}");
//       debugPrint("Update Version : ${_getFormatedVersion(forceUpdateVersion)}");

//       return _getFormatedVersion(currentVersion) <
//           _getFormatedVersion(forceUpdateVersion);
//     } catch (error) {
//       return false;
//     }
//   }

//   String get getGooglePlaceAPIKey =>
//       Platform.isIOS ? googlePlaceKeyIos : googlePlaceKeyAndroid;

//   // Get formated version(1.0.0)...
//   int _getFormatedVersion(String version) {
//     String forceVersion = version.isEmpty ? "0.0.0" : version;
//     List<String> splitVer = forceVersion.split(".");

//     // Add .0.0 if version received is e.g: 1
//     if (splitVer.length == 1) {
//       forceVersion = "$version.0.0";

//       // Add .0 if version received is e.g: 1.0
//     } else if (splitVer.length == 2) {
//       forceVersion = "$version.0";

//       // take first 3 only if version received is e.g: 1.0.0.5.6
//     } else if (splitVer.length > 3) {
//       forceVersion = splitVer.take(3).join(".");
//     }

//     return int.parse(forceVersion.trim().replaceAll(".", ""));
//   }
// }
