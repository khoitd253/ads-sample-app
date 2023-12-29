import 'package:easy_ads_flutter/easy_ads_flutter.dart';

abstract class AppAdIdManager extends IAdIdManager {
  String get admobAppId;

  String get appOpenSplashId;

  String get interSplashId;

  String get resumeId;

  String get interId;

  String get nativeId;

  String get largeNativeFactory => "large_ad_factory";
  String get mediumNativeFactory => "medium_ad_factory";
  String get smallNativeFactory => "small_ad_factory";

  String get bannerId;
  String get bannerCollapseId;

  String get rewardId;

  String get adOpenResume;

  /////////////////////////////////////////

  double get smallNativeAdHeight => 80;

  double get mediumNativeAdHeight => 140;

  double get largeNativeAdHeight => 270;

  @override
  AppAdIds? get admobAdIds => AppAdIds(appId: admobAppId);
}
