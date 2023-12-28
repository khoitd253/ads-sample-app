// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';

import '../../easy_ads_flutter.dart';
import 'easy_app_open_ad.dart';

/// Listens for app foreground events and shows app open ads.
class AppLifecycleReactor {
  final GlobalKey<NavigatorState> navigatorKey;
  final String? adId;
  final AdNetwork adNetwork;

  bool _onSplashScreen = true;
  bool _isExcludeScreen = false;
  bool config = true;
  int orientation = AppOpenAd.orientationPortrait;

  AppLifecycleReactor({
    required this.navigatorKey,
    required this.adId,
    required this.adNetwork,
  });

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream
        .forEach((state) => _onAppStateChanged(state));
  }

  void setOnSplashScreen(bool value) {
    _onSplashScreen = value;
  }

  void setIsExcludeScreen(bool value) {
    _isExcludeScreen = value;
  }

  void _onAppStateChanged(AppState appState) async {
    if (_onSplashScreen) return;
    if (!config) return;
    if (adId?.isNotEmpty != true) return;
    if (navigatorKey.currentContext == null) return;

    // Show AppOpenAd when back to foreground but do not show on excluded screens
    if (appState == AppState.foreground) {
      if (!_isExcludeScreen) {
        if (EasyAds.instance.isFullscreenAdShowing) {
          return;
        }
        if (!EasyAds.instance.isEnabled) {
          return;
        }
        if (await EasyAds.instance.isDeviceOffline()) {
          return;
        }
        showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => EasyAppOpenAd(
            adId: adId!,
            adNetwork: adNetwork,
            orientation: orientation,
          ),
        );
      } else {
        _isExcludeScreen = false;
      }
    }
  }
}
