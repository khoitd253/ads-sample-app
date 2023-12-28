import 'package:applovin_max/applovin_max.dart';
import 'package:easy_ads_flutter/src/enums/ad_network.dart';

import 'package:easy_ads_flutter/src/enums/ad_unit_type.dart';
import 'package:flutter/material.dart';

import '../easy_ad_base.dart';
import '../easy_ads.dart';

class EasyApplovinInterstitialAd extends EasyAdBase {
  EasyApplovinInterstitialAd({
    required super.adUnitId,
    super.onAdLoaded,
    super.onAdShowed,
    super.onAdClicked,
    super.onAdFailedToLoad,
    super.onAdFailedToShow,
    super.onAdDismissed,
    super.onEarnedReward,
    super.onPaidEvent,
  });

  @override
  AdNetwork get adNetwork => AdNetwork.appLovin;

  @override
  AdUnitType get adUnitType => AdUnitType.interstitial;

  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _isAdLoadedFailed = false;

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  bool get isAdLoadedFailed => _isAdLoadedFailed;

  @override
  bool get isAdLoading => _isAdLoading;

  @override
  Future<void> load() async {
    if (_isAdLoaded) return;

    AppLovinMAX.setInterstitialListener(
      InterstitialListener(
        onAdClickedCallback: (ad) {
          EasyAds.instance.onAdClickedMethod(adNetwork, adUnitType, ad);
          onAdClicked?.call(adNetwork, adUnitType, ad);
        },
        onAdDisplayFailedCallback: (ad, error) {
          EasyAds.instance.onAdFailedToShowMethod(
              adNetwork, adUnitType, ad, error.toString());
          onAdFailedToShow?.call(adNetwork, adUnitType, ad, error.toString());
        },
        onAdDisplayedCallback: (ad) {
          EasyAds.instance.onAdShowedMethod(adNetwork, adUnitType, ad);
          onAdShowed?.call(adNetwork, adUnitType, ad);
        },
        onAdHiddenCallback: (ad) {
          EasyAds.instance.onAdDismissedMethod(adNetwork, adUnitType, ad);
          onAdDismissed?.call(adNetwork, adUnitType, ad);
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          _isAdLoaded = false;
          _isAdLoading = false;
          _isAdLoadedFailed = true;
          EasyAds.instance.onAdFailedToLoadMethod(
              adNetwork, adUnitType, error, error.toString());
          onAdFailedToLoad?.call(
              adNetwork, adUnitType, error, error.toString());
        },
        onAdLoadedCallback: (ad) {
          _isAdLoaded = true;
          _isAdLoading = false;
          _isAdLoadedFailed = false;
          EasyAds.instance.onAdLoadedMethod(adNetwork, adUnitType, ad);
          onAdLoaded?.call(adNetwork, adUnitType, ad);
        },
        onAdRevenuePaidCallback: (ad) {
          EasyAds.instance.onPaidEventMethod(
            adNetwork: adNetwork,
            adUnitType: adUnitType,
            revenue: ad.revenue,
            currencyCode: 'USD',
            network: ad.networkName,
            unit: ad.adUnitId,
            placement: ad.placement,
          );
          onPaidEvent?.call(
            adNetwork: adNetwork,
            adUnitType: adUnitType,
            revenue: ad.revenue,
            currencyCode: 'USD',
            network: ad.networkName,
            unit: ad.adUnitId,
            placement: ad.placement,
          );
        },
      ),
    );
    _isAdLoading = true;
    AppLovinMAX.loadInterstitial(adUnitId);
  }

  @override
  void dispose() {
    _isAdLoaded = false;
    _isAdLoading = false;
    _isAdLoadedFailed = false;
  }

  @override
  show(
      {double? height,
      Color? color,
      BorderRadiusGeometry? borderRadius,
      BoxBorder? border,
      EdgeInsetsGeometry? padding}) {
    if (!_isAdLoaded) return;
    AppLovinMAX.showInterstitial(adUnitId);

    _isAdLoaded = false;
  }
}
