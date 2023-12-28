import 'package:easy_ads_flutter/src/enums/ad_network.dart';
import 'package:easy_ads_flutter/src/enums/ad_unit_type.dart';
import 'package:flutter/material.dart';

abstract class EasyAdBase {
  final String adUnitId;
  final EasyAdCallback? onAdLoaded;
  final EasyAdCallback? onAdShowed;
  final EasyAdCallback? onAdClicked;
  final EasyAdFailedCallback? onAdFailedToLoad;
  final EasyAdFailedCallback? onAdFailedToShow;
  final EasyAdCallback? onAdDismissed;
  final EasyAdEarnedReward? onEarnedReward;
  final EasyAdOnPaidEvent? onPaidEvent;
  final EasyAdCallback? onBannerAdReadyForSetState;

  /// This will be called for initialization when we don't have to wait for the initialization
  EasyAdBase({
    required this.adUnitId,
    this.onAdLoaded,
    this.onAdShowed,
    this.onAdClicked,
    this.onAdFailedToLoad,
    this.onAdFailedToShow,
    this.onAdDismissed,
    this.onEarnedReward,
    this.onPaidEvent,
    this.onBannerAdReadyForSetState,
  });

  AdNetwork get adNetwork;
  AdUnitType get adUnitType;
  bool get isAdLoaded;
  bool get isAdLoading;
  bool get isAdLoadedFailed;

  void dispose();

  /// This will load ad, It will only load the ad if isAdLoaded is false
  Future<void> load();

  dynamic show({
    double? height,
    Color? color,
    BorderRadiusGeometry? borderRadius,
    BoxBorder? border,
    EdgeInsetsGeometry? padding,
  });
}

typedef EasyAdNetworkInitialized = void Function(
  AdNetwork adNetwork,
  bool isInitialized,
  Object? data,
);
typedef EasyAdFailedCallback = void Function(
  AdNetwork adNetwork,
  AdUnitType adUnitType,
  Object? data,
  String errorMessage,
);
typedef EasyAdCallback = void Function(
  AdNetwork adNetwork,
  AdUnitType adUnitType,
  Object? data,
);
typedef EasyAdEarnedReward = void Function(
  AdNetwork adNetwork,
  AdUnitType adUnitType,
  String? rewardType,
  num? rewardAmount,
);

typedef EasyAdOnPaidEvent = void Function({
  required AdNetwork adNetwork,
  required AdUnitType adUnitType,
  required double revenue,
  required String currencyCode,
  String? network,
  String? unit,
  String? placement,
});
