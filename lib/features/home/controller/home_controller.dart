import 'package:ads_sample_app/features/ads/remote/remote_config.dart';
import 'package:ads_sample_app/main.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var indexToShowAd = [false, false, false].obs;

  void showInterAd() {
    EasyAds.instance.showInterstitialAd(
      adId: adIdManager.interId,
      config: RemoteConfig.interConfig,
      immersiveModeEnabled: true,
      onDisabled: () => {},
      onAdShowed: (adNetwork, adUnitType, data) => {
        /// you should navigate
      },
      onAdDismissed: (adNetwork, adUnitType, data) => {},
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) => {},
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) => {},
    );
  }

  void showRewardAd() {
    EasyAds.instance.showRewardAd(
      adId: adIdManager.rewardId,
      config: RemoteConfig.rewardConfig,
      immersiveModeEnabled: true,
      onDisabled: () => {},
      onAdShowed: (adNetwork, adUnitType, data) => {
        /// you should navigate
      },
      onAdDismissed: (adNetwork, adUnitType, data) => {},
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) => {},
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) => {},
    );
  }

  void changeAdIndex(int index) {
    for (int i = 0; i < indexToShowAd.length; i++) {
      indexToShowAd[i] = false;
    }
    indexToShowAd[index] = true;
    indexToShowAd.value = List.from(indexToShowAd);
  }
}
