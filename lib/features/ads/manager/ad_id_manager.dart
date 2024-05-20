import 'package:easy_ads_flutter/easy_ads_flutter.dart';

class AppAdIdManager extends IAdIdManager {
  String get admobAppId => "real-app-id-here";

  String get largeNativeFactory => "large_ad_factory";

  String get mediumNativeFactory => "medium_ad_factory";

  String get smallNativeFactory => "small_ad_factory";

  String get appOpenSplashId => "ca-pub-xxxx";

  String get interSplashId => "ca-pub-xxxx";

  String get resumeId => "ca-pub-xxxx";

  String get interId => "ca-pub-xxxx";

  String get nativeId => "ca-pub-xxxx";

  String get bannerId => "ca-pub-xxxx";

  String get bannerCollapseId => "ca-pub-xxxx";

  String get rewardId => "ca-pub-xxxx";

  String get adOpenResume => "ca-pub-xxxx";

  /////////////////////////////////////////

  double get smallNativeAdHeight => 80;

  double get mediumNativeAdHeight => 150;

  double get largeNativeAdHeight => 290;

  @override
  AppAdIds? get admobAdIds => AppAdIds(appId: admobAppId);
}
