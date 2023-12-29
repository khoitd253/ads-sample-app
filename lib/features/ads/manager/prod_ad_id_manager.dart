import 'package:easy_ads_flutter/easy_ads_flutter.dart';

import 'ad_id_manager.dart';

class ProdAdIdManager extends AppAdIdManager {
  @override
  AppAdIds? get appLovinAdIds => const AppAdIds(appId: "");

  @override
  String get admobAppId => "real-app-id-here";

  @override
  String get adOpenResume => throw UnimplementedError();

  @override
  String get appOpenSplashId => throw UnimplementedError();

  @override
  String get bannerId => throw UnimplementedError();

  @override
  String get bannerCollapseId => throw UnimplementedError();

  @override
  String get interId => throw UnimplementedError();

  @override
  String get interSplashId => throw UnimplementedError();

  @override
  String get nativeId => throw UnimplementedError();

  @override
  String get resumeId => throw UnimplementedError();

  @override
  String get rewardId => throw UnimplementedError();
}
