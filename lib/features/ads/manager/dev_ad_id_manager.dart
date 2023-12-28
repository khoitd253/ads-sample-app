import 'package:easy_ads_flutter/easy_ads_flutter.dart';

import 'ad_id_manager.dart';
import 'admob_test_id.dart';

class DevAdIdManager extends AppAdIdManager {
  @override
  double get mediumNativeAdHeight => 140;

  @override
  double get smallNativeAdHeight => 140;

  @override
  double get largeNativeAdHeight => 265;

  @override
  AppAdIds? get appLovinAdIds => const AppAdIds(appId: "");

  @override
  String get admobAppId => AdmobTestId.admobAppId;

  @override
  String get adOpenResume => AdmobTestId.admobResumeId;

  @override
  String get appOpenSplashId => AdmobTestId.admobResumeId;

  @override
  String get bannerId => AdmobTestId.admobBannerId;

  @override
  String get bannerCollapseId => AdmobTestId.admobBannerCollapseId;

  @override
  String get interId => AdmobTestId.admobInterstitialId;

  @override
  String get interSplashId => AdmobTestId.admobInterstitialId;

  @override
  String get nativeId => AdmobTestId.admobNativeId;

  @override
  String get resumeId => AdmobTestId.admobResumeId;

  @override
  String get rewardId => AdmobTestId.admobRewardId;
}
