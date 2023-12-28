import 'package:applovin_max/applovin_max.dart';
import 'package:easy_ads_flutter/src/enums/ad_network.dart';

import 'package:easy_ads_flutter/src/enums/ad_unit_type.dart';
import 'package:flutter/material.dart';

import '../easy_ad_base.dart';
import '../easy_ads.dart';
import '../utils/easy_loading_ad.dart';

class EasyAppLovinNativeAd extends EasyAdBase {
  EasyAppLovinNativeAd({
    required super.adUnitId,
    super.onAdLoaded,
    super.onAdShowed,
    super.onAdClicked,
    super.onAdFailedToLoad,
    super.onAdFailedToShow,
    super.onAdDismissed,
    super.onEarnedReward,
    super.onPaidEvent,
    required this.child,
  });

  final Widget child;

  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _isAdLoadedFailed = false;

  @override
  AdNetwork get adNetwork => AdNetwork.appLovin;

  @override
  AdUnitType get adUnitType => AdUnitType.native;

  @override
  void dispose() {
    _isAdLoaded = false;
    _isAdLoading = false;
    _isAdLoadedFailed = false;
    nativeAdViewController.dispose();
  }

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  bool get isAdLoadedFailed => _isAdLoadedFailed;

  @override
  bool get isAdLoading => _isAdLoading;

  final MaxNativeAdViewController nativeAdViewController =
      MaxNativeAdViewController();

  @override
  Future<void> load() async {
    if (_isAdLoading) return;
    _isAdLoading = true;
    nativeAdViewController.loadAd();
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
        MaxNativeAdView(
          adUnitId: adUnitId,
          height: padding != null && height != null
              ? height + padding.vertical
              : height,
          controller: nativeAdViewController,
          listener: NativeAdListener(
            onAdLoadedCallback: (ad) {
              _isAdLoaded = true;
              _isAdLoading = false;
              _isAdLoadedFailed = false;
              EasyAds.instance.onAdLoadedMethod(adNetwork, adUnitType, ad);
              onAdLoaded?.call(adNetwork, adUnitType, ad);
            },
            onAdLoadFailedCallback: (adUnitId, error) {
              _isAdLoaded = false;
              _isAdLoading = false;
              _isAdLoadedFailed = true;
              EasyAds.instance.onAdFailedToLoadMethod(
                  adNetwork, adUnitType, null, error.toString());
              onAdFailedToLoad?.call(
                  adNetwork, adUnitType, null, error.toString());
            },
            onAdClickedCallback: (ad) {
              EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(true);
              EasyAds.instance.onAdClickedMethod(adNetwork, adUnitType, ad);
              onAdClicked?.call(adNetwork, adUnitType, ad);
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
          child: isAdLoaded || isAdLoading
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius ?? BorderRadius.zero,
                    border: border,
                    color: color,
                  ),
                  padding: padding,
                  child: ClipRRect(
                    borderRadius: borderRadius ?? BorderRadius.zero,
                    child: Container(
                      color: color,
                      height: height,
                      child: child,
                    ),
                  ),
                )
              : const SizedBox(),
        ),
        if (isAdLoading)
          Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.zero,
              border: border,
              color: color,
            ),
            padding: padding,
            child: ClipRRect(
              borderRadius: borderRadius ?? BorderRadius.zero,
              child: Container(
                color: color,
                height: height,
                child: const EasyLoadingAd(),
              ),
            ),
          ),
      ],
    );
  }
}
