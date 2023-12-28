import 'package:applovin_max/applovin_max.dart';
import 'package:easy_ads_flutter/src/enums/ad_network.dart';

import 'package:easy_ads_flutter/src/enums/ad_unit_type.dart';
import 'package:flutter/material.dart';

import '../easy_ad_base.dart';
import '../easy_ads.dart';
import '../utils/easy_loading_ad.dart';

class EasyAppLovinBannerAd extends EasyAdBase {
  final AdViewPosition position;
  final Map<String, String?>? extraParameters;
  final Map<String, dynamic>? localExtraParameters;
  final Size adSize;
  EasyAppLovinBannerAd({
    required super.adUnitId,
    super.onAdLoaded,
    super.onAdShowed,
    super.onAdClicked,
    super.onAdFailedToLoad,
    super.onAdFailedToShow,
    super.onAdDismissed,
    super.onEarnedReward,
    super.onPaidEvent,
    required this.position,
    this.extraParameters,
    this.localExtraParameters,
    required this.adSize,
  });

  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _isAdLoadedFailed = false;

  @override
  AdNetwork get adNetwork => AdNetwork.appLovin;

  @override
  AdUnitType get adUnitType => AdUnitType.banner;

  @override
  void dispose() {
    _isAdLoaded = false;
    _isAdLoading = false;
    _isAdLoadedFailed = false;
  }

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  bool get isAdLoadedFailed => _isAdLoadedFailed;

  @override
  bool get isAdLoading => _isAdLoading;

  final MaxBannerAdViewController bannerAdViewController =
      MaxBannerAdViewController();

  @override
  Future<void> load() async {
    if (_isAdLoading) return;
    _isAdLoading = true;
    bannerAdViewController.loadAd();
  }

  @override
  show(
      {double? height,
      Color? color,
      BorderRadiusGeometry? borderRadius,
      BoxBorder? border,
      EdgeInsetsGeometry? padding}) {
    return Stack(
      children: [
        Center(
          child: Container(
            height: adSize.height,
            width: adSize.width,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.black, width: 2),
                bottom: BorderSide(color: Colors.black, width: 2),
              ),
            ),
            child: MaxAdView(
              adUnitId: adUnitId,
              adFormat: AdFormat.banner,
              customData: 'EasyAppLovinBannerAd',
              controller: bannerAdViewController,
              listener: AdViewAdListener(
                onAdLoadedCallback: (ad) {
                  _isAdLoaded = true;
                  _isAdLoadedFailed = false;
                  _isAdLoading = false;

                  EasyAds.instance.onAdLoadedMethod(adNetwork, adUnitType, ad);
                  onAdLoaded?.call(adNetwork, adUnitType, ad);
                },
                onAdLoadFailedCallback: (adUnitId, error) {
                  _isAdLoaded = false;
                  _isAdLoading = false;
                  _isAdLoadedFailed = true;
                  EasyAds.instance.onAdFailedToLoadMethod(
                      adNetwork,
                      adUnitType,
                      null,
                      'Error occurred while loading $adNetwork ad with ${error.code.toString()} and message:  ${error.message}');
                  onAdFailedToLoad?.call(adNetwork, adUnitType, null,
                      'Error occurred while loading $adNetwork ad with ${error.code.toString()} and message:  ${error.message}');
                },
                onAdClickedCallback: (_) {
                  EasyAds.instance.appLifecycleReactor
                      ?.setIsExcludeScreen(true);
                  EasyAds.instance
                      .onAdClickedMethod(adNetwork, adUnitType, null);
                  onAdClicked?.call(adNetwork, adUnitType, null);
                },
                onAdExpandedCallback: (ad) {
                  Future.delayed(
                    const Duration(milliseconds: 500),
                    () {
                      EasyAds.instance
                          .onAdShowedMethod(adNetwork, adUnitType, ad);
                      onAdShowed?.call(adNetwork, adUnitType, ad);
                    },
                  );
                },
                onAdCollapsedCallback: (ad) {
                  EasyAds.instance
                      .onAdDismissedMethod(adNetwork, adUnitType, ad);
                  onAdDismissed?.call(adNetwork, adUnitType, ad);
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
              adaptiveBannerWidth: adSize.width,
              extraParameters: extraParameters,
              localExtraParameters: localExtraParameters,
              isAutoRefreshEnabled: true,
            ),
          ),
        ),
        if (isAdLoading)
          Center(
            child: Container(
              height: adSize.height,
              width: adSize.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.black, width: 2),
                  bottom: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              child: const EasyLoadingAd(),
            ),
          ),
      ],
    );
  }
}
