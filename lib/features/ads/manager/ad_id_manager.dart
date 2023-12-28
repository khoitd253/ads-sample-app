import 'package:easy_ads_flutter/easy_ads_flutter.dart';

abstract class AppAdIdManager extends IAdIdManager {
  String get admobAppId;

  String get appOpenSplashId;

  String get interSplashId;

  String get resumeId;

  String get interId;

  String get nativeId;

  String get nativeFactory => "native_factory";

  String get bannerId;
  String get bannerCollapseId;

  String get rewardId;

  String get adOpenResume;

  /////////////////////////////////////////

  double get smallNativeAdHeight;

  double get mediumNativeAdHeight;

  double get largeNativeAdHeight;

  @override
  AppAdIds? get admobAdIds => AppAdIds(appId: admobAppId);
}
