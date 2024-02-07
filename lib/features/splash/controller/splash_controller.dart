import 'package:ads_sample_app/features/ads/remote/remote_config.dart';
import 'package:ads_sample_app/features/home/page/home_page.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../main.dart';
import '../../ads/manager/dev_ad_id_manager.dart';
import '../../ads/manager/prod_ad_id_manager.dart';

class SplashController extends GetxController {
  void initAdModule() {
    RemoteConfig.init().then((_) {
      /// First we need to fetch Remote config
      RemoteConfig.getRemoteConfig();

      /// Then init the ads module
      _initAdsModule().then((_) {
        /// choose one of the following cases:
        _showInterSplashAndAppOpen();
        // _showWith2InterSplash();
        // _showAppOpenSplash();
        // _showInterSplash();
      });
    });
  }

  Future<void> _initAdsModule() async {
    try {
      /// get flavor here
      adIdManager = appFlavor == "prod" ? ProdAdIdManager() : DevAdIdManager();

      await EasyAds.instance.initialize(
        adIdManager,
        navigatorKey: Get.key,
        adMobAdRequest: const AdRequest(httpTimeoutMillis: 30000),
        admobConfiguration: RequestConfiguration(testDeviceIds: ['']),
        adResumeId: adIdManager.adOpenResume,
        adResumeConfig: RemoteConfig.resumeConfig,
        initMediationCallback: (bool canRequestAds) =>
            const MethodChannel('channel').invokeMethod<bool>('init_mediation', canRequestAds),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      _handleNextScreen(true);
    }
  }

  void _showInterSplashAndAppOpen() {
    EasyAds.instance.showSplashAdWithInterstitialAndAppOpen(
      interstitialSplashAdId: adIdManager.interSplashId,
      appOpenAdId: adIdManager.appOpenSplashId,
      onDisabled: () => _handleNextScreen(true),
      onShowed: (type) => _handleNextScreen(),
      onFailedToShow: (type) => _handleNextScreen(true),
      onFailedToLoad: () => _handleNextScreen(true),
      onDismissed: (type) {
        EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
      },
      immersiveModeEnabled: true,
      orientation: AppOpenAd.orientationPortrait,
      configInterstitial: RemoteConfig.interSplashConfig,
      configAppOpen: RemoteConfig.appOpenSplashConfig,
    );
  }

  void _showWith2InterSplash() {
    EasyAds.instance.showSplashAdWith2Inter(
      interstitialSplashId: adIdManager.interSplashId,
      interstitialSplashHighId: adIdManager.interSplashId,
      config: RemoteConfig.interConfig,
      configHigh: RemoteConfig.interConfig,
      immersiveModeEnabled: true,
      onDisabled: () => _handleNextScreen(true),
      onShowed: (type) => _handleNextScreen(),
      onFailedToLoad: () => _handleNextScreen(true),
      onDismissed: (type) {
        EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
      },
      onFailedToShow: (type) => _handleNextScreen(true),
    );
  }

  void _showAppOpenSplash() {
    EasyAds.instance.showAppOpen(
      adId: adIdManager.appOpenSplashId,
      config: RemoteConfig.appOpenSplashConfig,
      onDisabled: () => _handleNextScreen(),
      onAdShowed: (adNetwork, adUnitType, data) => _handleNextScreen(),
      onAdDismissed: (adNetwork, adUnitType, data) {
        EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) => _handleNextScreen(true),
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) => _handleNextScreen(true),
    );
  }

  void _showInterSplash() {
    EasyAds.instance.showInterstitialAd(
      adId: adIdManager.interSplashId,
      config: RemoteConfig.interSplashConfig,
      immersiveModeEnabled: true,
      onDisabled: () => _handleNextScreen(true),
      onAdShowed: (adNetwork, adUnitType, data) => _handleNextScreen(),
      onAdDismissed: (adNetwork, adUnitType, data) {
        EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) => _handleNextScreen(true),
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) => _handleNextScreen(true),
    );
  }

  void _handleNextScreen([isExitSplash = false]) {
    if (isExitSplash) {
      /// important
      EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
    }

    Get.to(() => const HomePage());
  }
}
