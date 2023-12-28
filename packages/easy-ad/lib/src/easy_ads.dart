// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:ui' as ui;

import 'package:applovin_max/applovin_max.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:easy_ads_flutter/src/easy_admob/easy_admob_interstitial_ad.dart';
import 'package:easy_ads_flutter/src/ump/ump_handler.dart';
import 'package:easy_ads_flutter/src/utils/easy_logger.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'easy_admob/easy_admob_native_ad.dart';
import 'easy_admob/easy_admob_rewarded_ad.dart';
import 'easy_applovin/easy_applovin_app_open_ad.dart';
import 'easy_applovin/easy_applovin_banner_ad.dart';
import 'easy_applovin/easy_applovin_interstitial_ad.dart';
import 'easy_applovin/easy_applovin_native_ad.dart';
import 'easy_applovin/easy_applovin_reward_ad.dart';
import 'utils/easy_app_open_ad.dart';
import 'utils/easy_interstitial_ad.dart';
import 'utils/easy_reward_ad.dart';
import 'utils/easy_splash_ad_with_2_inter.dart';
import 'utils/easy_splash_ad_with_3_inter.dart';
import 'utils/easy_splash_ad_with_interstitial_and_app_open.dart';

part 'easy_ads_extension.dart';

enum EasyAdsPlacementType { normal, high, med }

enum EasyAdsBannerType {
  standard,
  adaptive,
  collapsible_bottom,
  collapsible_top,
}

const double _bannerWidth = 320;
const double _bannerHeight = 50;
const double _leaderWidth = 728;
const double _leaderHeight = 90;

class EasyAds {
  EasyAds._easyAds();

  static final EasyAds instance = EasyAds._easyAds();
  AppLifecycleReactor? appLifecycleReactor;
  GlobalKey<NavigatorState>? navigatorKey;

  /// Google admob's ad request
  AdRequest _adRequest = const AdRequest();
  late final IAdIdManager adIdManager;

  /// True value when there is exist an Ad and false otherwise.
  bool _isFullscreenAdShowing = false;

  void setFullscreenAdShowing(bool value) => _isFullscreenAdShowing = value;

  bool get isFullscreenAdShowing => _isFullscreenAdShowing;

  /// Enable or disable all ads
  bool _isEnabled = true;

  /// where UMP Form is showed or not
  bool umpShowed = false;

  void enableAd(bool value) => _isEnabled = value;

  bool get isEnabled => _isEnabled;

  // final _eventController = EasyEventController();
  // Stream<AdEvent> get onEvent => _eventController.onEvent;

  Stream<AdEvent> get onEvent => _onEventController.stream;
  final _onEventController = StreamController<AdEvent>.broadcast();

  /// Preload interstitial normal
  EasyAdBase? interNormal;
  int loadTimesFailedInterNormal = 0;

  /// Preload interstitial priority
  EasyAdBase? interPriority;
  int loadTimesFailedInterPriority = 0;

  EasyAdBase? nativeNormal;
  String? nativeNormalId;
  int loadTimesFailedNativeNormal = 0;

  EasyAdBase? nativeMedium;
  String? nativeMediumId;
  int loadTimesFailedNativeMedium = 0;

  EasyAdBase? nativeHigh;
  String? nativeHighId;
  int loadTimesFailedNativeHigh = 0;

  int limitLoad = 3;

  /// [_logger] is used to show Ad logs in the console
  final EasyLogger _logger = EasyLogger();
  AdSize? admobAdSize;
  Size? appLovinAdSize;

  /// Initializes the Google Mobile Ads SDK.
  ///
  /// Call this method as early as possible after the app launches
  /// [adMobAdRequest] will be used in all the admob requests. By default empty request will be used if nothing passed here.
  Future<void> initialize(
    IAdIdManager manager, {
    AdRequest? adMobAdRequest,
    RequestConfiguration? admobConfiguration,
    bool enableLogger = true,
    GlobalKey<NavigatorState>? navigatorKey,
    String? adResumeId,
    required bool adResumeConfig,
    int adResumeOrientation = AppOpenAd.orientationPortrait,
    AdNetwork adResumeNetwork = AdNetwork.admob,
    bool isAgeRestrictedUserForApplovin = false,
    List<String>? keywordForApplovin,

    /// Preload interstitial ad
    String? interstitialAdNormalId,
    String? interstitialAdPriorityId,
    bool immersiveModeEnabled = true,

    /// Preload native ad
    String? nativeAdNormalId,
    String? nativeAdMediumId,
    String? nativeAdHighId,

    /// UMP
    bool umpConfig = true,
  }) async {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    if (enableLogger) _logger.enable(enableLogger);
    adIdManager = manager;
    if (adMobAdRequest != null) {
      _adRequest = adMobAdRequest;
    }
    UmpHandler.umpConfig = umpConfig;

    if (manager.admobAdIds?.appId != null) {
      if (navigatorKey?.currentContext != null) {
        admobAdSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.sizeOf(navigatorKey!.currentContext!).width.toInt());
      }

      final appLovinSdkId = manager.appLovinAdIds?.appId;
      if (appLovinSdkId?.isNotEmpty == true) {
        final response = await AppLovinMAX.initialize(appLovinSdkId!);

        AppLovinMAX.targetingData.maximumAdContentRating = isAgeRestrictedUserForApplovin == true
            ? AdContentRating.allAudiences
            : AdContentRating.none;

        if (keywordForApplovin != null) {
          AppLovinMAX.targetingData.keywords = keywordForApplovin;
        }

        if (response != null) {
          fireNetworkInitializedEvent(AdNetwork.appLovin, true);
        } else {
          fireNetworkInitializedEvent(AdNetwork.appLovin, false);
        }
        AppLovinMAX.setTestDeviceAdvertisingIds(['6280250c-a718-42a5-8e3a-a9ff2656a8a1']);

        if (navigatorKey?.currentContext != null) {
          final width = MediaQuery.sizeOf(navigatorKey!.currentContext!).width;
          double? height = await AppLovinMAX.getAdaptiveBannerHeightForWidth(width);
          height ??= isTablet() ? _leaderHeight : _bannerHeight;
          appLovinAdSize = Size(width, height);
        }
      }

      if (navigatorKey != null) {
        this.navigatorKey = navigatorKey;
        appLifecycleReactor = AppLifecycleReactor(
          navigatorKey: navigatorKey,
          adId: adResumeId,
          adNetwork: adResumeNetwork,
        );
        appLifecycleReactor!.listenToAppStateChanges();
      }
    }
  }

  /// Returns [EasyAdBase] if ad is created successfully. It assumes that you have already assigned banner id in Ad Id Manager
  ///
  /// if [adNetwork] is provided, only that network's ad would be created. For now, only unity and admob banner is supported
  /// [admobAdSize] is used to provide ad banner size
  EasyAdBase? createBanner({
    required AdNetwork adNetwork,
    required String adId,
    required EasyAdsBannerType type,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdEarnedReward? onEarnedReward,
    EasyAdOnPaidEvent? onPaidEvent,
  }) {
    EasyAdBase? ad;
    if (adNetwork == AdNetwork.admob) {
      /// Get ad request
      AdRequest adRequest = _adRequest;
      if (type == EasyAdsBannerType.collapsible_bottom) {
        adRequest = AdRequest(
          httpTimeoutMillis: _adRequest.httpTimeoutMillis,
          contentUrl: _adRequest.contentUrl,
          keywords: _adRequest.keywords,
          mediationExtrasIdentifier: _adRequest.mediationExtrasIdentifier,
          neighboringContentUrls: _adRequest.neighboringContentUrls,
          nonPersonalizedAds: _adRequest.nonPersonalizedAds,
          extras: {'collapsible': 'bottom'},
        );
      } else if (type == EasyAdsBannerType.collapsible_top) {
        adRequest = AdRequest(
          httpTimeoutMillis: _adRequest.httpTimeoutMillis,
          contentUrl: _adRequest.contentUrl,
          keywords: _adRequest.keywords,
          mediationExtrasIdentifier: _adRequest.mediationExtrasIdentifier,
          neighboringContentUrls: _adRequest.neighboringContentUrls,
          nonPersonalizedAds: _adRequest.nonPersonalizedAds,
          extras: {'collapsible': 'top'},
        );
      }

      AdSize adSize = getAdmobAdSize(
        type: type,
      );
      ad = EasyAdmobBannerAd(
        adUnitId: adId,
        adSize: adSize,
        adRequest: adRequest,
        onAdLoaded: onAdLoaded,
        onAdShowed: onAdShowed,
        onAdClicked: onAdClicked,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdFailedToShow: onAdFailedToShow,
        onAdDismissed: onAdDismissed,
        onEarnedReward: onEarnedReward,
        onPaidEvent: onPaidEvent,
      );
    } else if (adNetwork == AdNetwork.appLovin) {
      // Bottom Center support only
      AdViewPosition position = AdViewPosition.bottomCenter;

      Size adSize = getAppLovinAdSize(type: type);
      Map<String, String?> extraParameters = {};
      Map<String, dynamic>? localParameters = {};
      if (type == EasyAdsBannerType.standard) {
        extraParameters['adaptive_banner'] = 'false';
      } else {
        extraParameters['adaptive_banner'] = 'true';
        localParameters['adaptive_banner_width'] = adSize.width.toInt();
      }
      ad = EasyAppLovinBannerAd(
        adUnitId: adId,
        position: position,
        extraParameters: extraParameters,
        localExtraParameters: localParameters,
        adSize: adSize,
        onAdLoaded: onAdLoaded,
        onAdShowed: onAdShowed,
        onAdClicked: onAdClicked,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdFailedToShow: onAdFailedToShow,
        onAdDismissed: onAdDismissed,
        onEarnedReward: onEarnedReward,
        onPaidEvent: onPaidEvent,
      );
    }
    return ad;
  }

  EasyAdBase? createNative({
    required AdNetwork adNetwork,
    required String factoryId,
    required String adId,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdEarnedReward? onEarnedReward,
    EasyAdOnPaidEvent? onPaidEvent,
    Widget? appLovinLayout,
  }) {
    EasyAdBase? ad;
    switch (adNetwork) {
      case AdNetwork.appLovin:
        assert(appLovinLayout != null);
        ad = EasyAppLovinNativeAd(
          adUnitId: adId,
          onAdLoaded: onAdLoaded,
          onAdShowed: onAdShowed,
          onAdClicked: onAdClicked,
          onAdFailedToLoad: onAdFailedToLoad,
          onAdFailedToShow: onAdFailedToShow,
          onAdDismissed: onAdDismissed,
          onEarnedReward: onEarnedReward,
          onPaidEvent: onPaidEvent,
          child: appLovinLayout!,
        );
        break;
      default:
        ad = EasyAdmobNativeAd(
          adUnitId: adId,
          factoryId: factoryId,
          adRequest: _adRequest,
          onAdLoaded: onAdLoaded,
          onAdShowed: onAdShowed,
          onAdClicked: onAdClicked,
          onAdFailedToLoad: onAdFailedToLoad,
          onAdFailedToShow: onAdFailedToShow,
          onAdDismissed: onAdDismissed,
          onEarnedReward: onEarnedReward,
          onPaidEvent: onPaidEvent,
        );
        break;
    }

    return ad;
  }

  EasyAdBase? createInterstitial({
    required AdNetwork adNetwork,
    required String adId,
    required bool immersiveModeEnabled,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdEarnedReward? onEarnedReward,
    EasyAdOnPaidEvent? onPaidEvent,
  }) {
    EasyAdBase? ad;
    switch (adNetwork) {
      case AdNetwork.appLovin:
        ad = EasyApplovinInterstitialAd(
          adUnitId: adId,
          onAdLoaded: onAdLoaded,
          onAdShowed: onAdShowed,
          onAdClicked: onAdClicked,
          onAdFailedToLoad: onAdFailedToLoad,
          onAdFailedToShow: onAdFailedToShow,
          onAdDismissed: onAdDismissed,
          onEarnedReward: onEarnedReward,
          onPaidEvent: onPaidEvent,
        );
        break;
      default:
        ad = EasyAdmobInterstitialAd(
          adUnitId: adId,
          adRequest: _adRequest,
          immersiveModeEnabled: immersiveModeEnabled,
          onAdLoaded: onAdLoaded,
          onAdShowed: onAdShowed,
          onAdClicked: onAdClicked,
          onAdFailedToLoad: onAdFailedToLoad,
          onAdFailedToShow: onAdFailedToShow,
          onAdDismissed: onAdDismissed,
          onEarnedReward: onEarnedReward,
          onPaidEvent: onPaidEvent,
        );
        break;
    }
    return ad;
  }

  EasyAdBase? createReward({
    required AdNetwork adNetwork,
    required String adId,
    bool immersiveModeEnabled = true,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdEarnedReward? onEarnedReward,
    EasyAdOnPaidEvent? onPaidEvent,
  }) {
    EasyAdBase? ad;
    switch (adNetwork) {
      case AdNetwork.appLovin:
        ad = EasyAppLovinRewardAd(
          adUnitId: adId,
          onAdLoaded: onAdLoaded,
          onAdShowed: onAdShowed,
          onAdClicked: onAdClicked,
          onAdFailedToLoad: onAdFailedToLoad,
          onAdFailedToShow: onAdFailedToShow,
          onAdDismissed: onAdDismissed,
          onEarnedReward: onEarnedReward,
          onPaidEvent: onPaidEvent,
        );
        break;
      default:
        ad = EasyAdmobRewardedAd(
          adUnitId: adId,
          adRequest: _adRequest,
          immersiveModeEnabled: immersiveModeEnabled,
          onAdLoaded: onAdLoaded,
          onAdShowed: onAdShowed,
          onAdClicked: onAdClicked,
          onAdFailedToLoad: onAdFailedToLoad,
          onAdFailedToShow: onAdFailedToShow,
          onAdDismissed: onAdDismissed,
          onEarnedReward: onEarnedReward,
          onPaidEvent: onPaidEvent,
        );
        break;
    }

    return ad;
  }

  EasyAdBase? createAppOpenAd({
    required AdNetwork adNetwork,
    required String adId,
    int orientation = AppOpenAd.orientationPortrait,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdEarnedReward? onEarnedReward,
    EasyAdOnPaidEvent? onPaidEvent,
  }) {
    EasyAdBase? ad;
    switch (adNetwork) {
      case AdNetwork.appLovin:
        ad = EasyAppLovinAppOpenAd(
          adUnitId: adId,
          onAdLoaded: onAdLoaded,
          onAdShowed: onAdShowed,
          onAdClicked: onAdClicked,
          onAdFailedToLoad: onAdFailedToLoad,
          onAdFailedToShow: onAdFailedToShow,
          onAdDismissed: onAdDismissed,
          onEarnedReward: onEarnedReward,
          onPaidEvent: onPaidEvent,
        );
        break;
      default:
        ad = EasyAdmobAppOpenAd(
          adUnitId: adId,
          adRequest: _adRequest,
          orientation: orientation,
          onAdLoaded: onAdLoaded,
          onAdShowed: onAdShowed,
          onAdClicked: onAdClicked,
          onAdFailedToLoad: onAdFailedToLoad,
          onAdFailedToShow: onAdFailedToShow,
          onAdDismissed: onAdDismissed,
          onEarnedReward: onEarnedReward,
          onPaidEvent: onPaidEvent,
        );
        break;
    }

    return ad;
  }

  Future<void> showAppOpen({
    AdNetwork adNetwork = AdNetwork.admob,
    required String adId,
    Function()? onDisabled,
    required bool config,
    int orientation = AppOpenAd.orientationPortrait,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdOnPaidEvent? onPaidEvent,
  }) async {
    if (!isEnabled || !config) {
      onDisabled?.call();
      return;
    }
    if (_isFullscreenAdShowing) {
      onDisabled?.call();
      return;
    }
    if (await isDeviceOffline()) {
      onDisabled?.call();
      return;
    }
    // ignore: use_build_context_synchronously
    navigatorKey?.currentState?.push(
      MaterialPageRoute(
        builder: (context) => EasyAppOpenAd(
          adNetwork: adNetwork,
          adId: adId,
          onAdLoaded: onAdLoaded,
          onAdShowed: onAdShowed,
          onAdClicked: onAdClicked,
          onAdFailedToLoad: onAdFailedToLoad,
          onAdFailedToShow: onAdFailedToShow,
          onAdDismissed: onAdDismissed,
          onPaidEvent: onPaidEvent,
          orientation: orientation,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> showInterstitialAd({
    AdNetwork adNetwork = AdNetwork.admob,
    required String adId,
    Function()? onDisabled,
    required bool config,
    required bool immersiveModeEnabled,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdOnPaidEvent? onPaidEvent,
  }) async {
    if (!isEnabled || !config) {
      onDisabled?.call();
      return;
    }
    if (_isFullscreenAdShowing) {
      onDisabled?.call();
      return;
    }
    if (await isDeviceOffline()) {
      onDisabled?.call();
      return;
    }
    // ignore: use_build_context_synchronously
    navigatorKey?.currentState?.push(MaterialPageRoute(
      builder: (context) => EasyInterstitialAd(
        adNetwork: adNetwork,
        adId: adId,
        immersiveModeEnabled: immersiveModeEnabled,
        onAdLoaded: onAdLoaded,
        onAdShowed: onAdShowed,
        onAdClicked: onAdClicked,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdFailedToShow: onAdFailedToShow,
        onAdDismissed: onAdDismissed,
        onPaidEvent: onPaidEvent,
      ),
      fullscreenDialog: true,
    ));
  }

  Future<void> showRewardAd({
    AdNetwork adNetwork = AdNetwork.admob,
    required String adId,
    Function()? onDisabled,
    required bool config,
    required bool immersiveModeEnabled,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdEarnedReward? onEarnedReward,
    EasyAdOnPaidEvent? onPaidEvent,
  }) async {
    if (!isEnabled || !config) {
      onDisabled?.call();
      return;
    }
    if (_isFullscreenAdShowing) {
      onDisabled?.call();
      return;
    }
    if (await isDeviceOffline()) {
      onDisabled?.call();
      return;
    }
    // ignore: use_build_context_synchronously
    navigatorKey?.currentState?.push(
      MaterialPageRoute(
        builder: (context) => EasyRewardAd(
          adNetwork: adNetwork,
          adId: adId,
          immersiveModeEnabled: immersiveModeEnabled,
          onAdLoaded: onAdLoaded,
          onAdShowed: onAdShowed,
          onAdClicked: onAdClicked,
          onAdFailedToLoad: onAdFailedToLoad,
          onAdFailedToShow: onAdFailedToShow,
          onAdDismissed: onAdDismissed,
          onEarnedReward: onEarnedReward,
          onPaidEvent: onPaidEvent,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> showSplashAdWith2Inter({
    AdNetwork adNetwork = AdNetwork.admob,
    required String interstitialSplashId,
    required String interstitialSplashHighId,
    required Function()? onDisabled,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdOnPaidEvent? onPaidEvent,
    required bool config,
    EasyAdCallback? onAdHighLoaded,
    EasyAdCallback? onAdHighShowed,
    EasyAdCallback? onAdHighClicked,
    EasyAdFailedCallback? onAdHighFailedToLoad,
    EasyAdFailedCallback? onAdHighFailedToShow,
    EasyAdCallback? onAdHighDismissed,
    EasyAdOnPaidEvent? onHighPaidEvent,
    required bool configHigh,
    required bool immersiveModeEnabled,
    Function(EasyAdsPlacementType type)? onShowed,
    Function(EasyAdsPlacementType type)? onDismissed,
    Function()? onFailedToLoad,
    Function(EasyAdsPlacementType type)? onFailedToShow,
    Function(EasyAdsPlacementType type)? onClicked,
  }) async {
    if (!isEnabled) {
      onDisabled?.call();
      return;
    }

    if (!config && !configHigh) {
      onDisabled?.call();
      return;
    }

    if (_isFullscreenAdShowing) {
      onDisabled?.call();
      return;
    }
    if (await isDeviceOffline()) {
      onDisabled?.call();
      return;
    }
    // ignore: use_build_context_synchronously
    navigatorKey?.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => EasySplashAdWith2Inter(
          adNetwork: adNetwork,
          interstitialSplashId: interstitialSplashId,
          interstitialSplashHighId: interstitialSplashHighId,
          onAdLoaded: onAdLoaded,
          onAdShowed: onAdShowed,
          onAdClicked: onAdClicked,
          onAdFailedToLoad: onAdFailedToLoad,
          onAdFailedToShow: onAdFailedToShow,
          onAdDismissed: onAdDismissed,
          onPaidEvent: onPaidEvent,
          config: config,
          onAdHighLoaded: onAdHighLoaded,
          onAdHighShowed: onAdHighShowed,
          onAdHighClicked: onAdHighClicked,
          onAdHighFailedToLoad: onAdHighFailedToLoad,
          onAdHighFailedToShow: onAdHighFailedToShow,
          onAdHighDismissed: onAdHighDismissed,
          onHighPaidEvent: onHighPaidEvent,
          configHigh: configHigh,
          immersiveModeEnabled: immersiveModeEnabled,
          onShowed: onShowed,
          onDismissed: onDismissed,
          onFailedToLoad: onFailedToLoad,
          onFailedToShow: onFailedToShow,
          onClicked: onClicked,
        ),
        fullscreenDialog: true,
      ),
      (route) => true,
    );
  }

  Future<void> showSplashAdWith3Inter({
    AdNetwork adNetwork = AdNetwork.admob,
    required String interstitialSplashId,
    required String interstitialSplashMediumId,
    required String interstitialSplashHighId,
    required Function()? onDisabled,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdOnPaidEvent? onPaidEvent,
    required bool config,
    EasyAdCallback? onAdMediumLoaded,
    EasyAdCallback? onAdMediumShowed,
    EasyAdCallback? onAdMediumClicked,
    EasyAdFailedCallback? onAdMediumFailedToLoad,
    EasyAdFailedCallback? onAdMediumFailedToShow,
    EasyAdCallback? onAdMediumDismissed,
    EasyAdOnPaidEvent? onMediumPaidEvent,
    required bool configMedium,
    EasyAdCallback? onAdHighLoaded,
    EasyAdCallback? onAdHighShowed,
    EasyAdCallback? onAdHighClicked,
    EasyAdFailedCallback? onAdHighFailedToLoad,
    EasyAdFailedCallback? onAdHighFailedToShow,
    EasyAdCallback? onAdHighDismissed,
    EasyAdOnPaidEvent? onHighPaidEvent,
    required bool configHigh,
    Function(EasyAdsPlacementType type)? onShowed,
    Function(EasyAdsPlacementType type)? onDismissed,
    Function()? onFailedToLoad,
    Function(EasyAdsPlacementType type)? onFailedToShow,
    Function(EasyAdsPlacementType type)? onClicked,
    required bool immersiveModeEnabled,
  }) async {
    if (!isEnabled) {
      onDisabled?.call();
      return;
    }
    if (!config && !configMedium && !configHigh) {
      onDisabled?.call();
      return;
    }
    if (_isFullscreenAdShowing) {
      onDisabled?.call();
      return;
    }
    if (await isDeviceOffline()) {
      onDisabled?.call();
      return;
    }
    // ignore: use_build_context_synchronously
    navigatorKey?.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => EasySplashAdWith3Inter(
          adNetwork: adNetwork,
          interstitialSplashId: interstitialSplashId,
          interstitialSplashMediumId: interstitialSplashMediumId,
          interstitialSplashHighId: interstitialSplashHighId,
          immersiveModeEnabled: immersiveModeEnabled,
          onShowed: onShowed,
          onDismissed: onDismissed,
          onFailedToLoad: onFailedToLoad,
          onFailedToShow: onFailedToShow,
          onClicked: onClicked,
          onAdLoaded: onAdLoaded,
          onAdShowed: onAdShowed,
          onAdClicked: onAdClicked,
          onAdFailedToLoad: onAdFailedToLoad,
          onAdFailedToShow: onAdFailedToShow,
          onAdDismissed: onAdDismissed,
          onPaidEvent: onPaidEvent,
          config: config,
          onAdMediumLoaded: onAdMediumLoaded,
          onAdMediumShowed: onAdMediumShowed,
          onAdMediumClicked: onAdMediumClicked,
          onAdMediumFailedToLoad: onAdMediumFailedToLoad,
          onAdMediumFailedToShow: onAdMediumFailedToShow,
          onAdMediumDismissed: onAdMediumDismissed,
          onMediumPaidEvent: onMediumPaidEvent,
          configMedium: configMedium,
          onAdHighLoaded: onAdHighLoaded,
          onAdHighShowed: onAdHighShowed,
          onAdHighClicked: onAdHighClicked,
          onAdHighFailedToLoad: onAdHighFailedToLoad,
          onAdHighFailedToShow: onAdHighFailedToShow,
          onAdHighDismissed: onAdHighDismissed,
          onHighPaidEvent: onHighPaidEvent,
          configHigh: configHigh,
        ),
        fullscreenDialog: true,
      ),
      (route) => true,
    );
  }

  Future<void> showSplashAdWithInterstitialAndAppOpen({
    AdNetwork adNetwork = AdNetwork.admob,
    required String interstitialSplashAdId,
    required String appOpenAdId,
    required Function()? onDisabled,
    required bool immersiveModeEnabled,
    required int orientation,
    void Function(AdUnitType type)? onShowed,
    void Function(AdUnitType type)? onDismissed,
    void Function()? onFailedToLoad,
    void Function(AdUnitType type)? onFailedToShow,
    Function(AdUnitType type)? onClicked,
    EasyAdCallback? onAdInterstitialLoaded,
    EasyAdCallback? onAdInterstitialShowed,
    EasyAdCallback? onAdInterstitialClicked,
    EasyAdFailedCallback? onAdInterstitialFailedToLoad,
    EasyAdFailedCallback? onAdInterstitialFailedToShow,
    EasyAdCallback? onAdInterstitialDismissed,
    EasyAdOnPaidEvent? onInterstitialPaidEvent,
    required bool configInterstitial,
    EasyAdCallback? onAdAppOpenLoaded,
    EasyAdCallback? onAdAppOpenShowed,
    EasyAdCallback? onAdAppOpenClicked,
    EasyAdFailedCallback? onAdAppOpenFailedToLoad,
    EasyAdFailedCallback? onAdAppOpenFailedToShow,
    EasyAdCallback? onAdAppOpenDismissed,
    EasyAdOnPaidEvent? onAppOpenPaidEvent,
    required bool configAppOpen,
  }) async {
    if (!isEnabled) {
      onDisabled?.call();
      return;
    }
    if (!configAppOpen && !configInterstitial) {
      onDisabled?.call();
      return;
    }

    if (_isFullscreenAdShowing) {
      onDisabled?.call();
      return;
    }
    if (await isDeviceOffline()) {
      onDisabled?.call();
      return;
    }
    // ignore: use_build_context_synchronously
    navigatorKey?.currentState?.push(
      MaterialPageRoute(
        builder: (context) => EasySplashAdWithInterstitialAndAppOpen(
          adNetwork: adNetwork,
          interstitialSplashAdId: interstitialSplashAdId,
          appOpenAdId: appOpenAdId,
          onShowed: onShowed,
          onDismissed: onDismissed,
          onFailedToLoad: onFailedToLoad,
          onFailedToShow: onFailedToShow,
          onClicked: onClicked,
          immersiveModeEnabled: immersiveModeEnabled,
          orientation: orientation,
          onAdInterstitialLoaded: onAdInterstitialLoaded,
          onAdInterstitialShowed: onAdInterstitialShowed,
          onAdInterstitialClicked: onAdInterstitialClicked,
          onAdInterstitialFailedToLoad: onAdInterstitialFailedToLoad,
          onAdInterstitialFailedToShow: onAdInterstitialFailedToShow,
          onAdInterstitialDismissed: onAdInterstitialDismissed,
          onInterstitialPaidEvent: onInterstitialPaidEvent,
          configInterstitial: configInterstitial,
          onAdAppOpenLoaded: onAdAppOpenLoaded,
          onAdAppOpenShowed: onAdAppOpenShowed,
          onAdAppOpenClicked: onAdAppOpenClicked,
          onAdAppOpenFailedToLoad: onAdAppOpenFailedToLoad,
          onAdAppOpenFailedToShow: onAdAppOpenFailedToShow,
          onAdAppOpenDismissed: onAdAppOpenDismissed,
          onAppOpenPaidEvent: onAppOpenPaidEvent,
          configAppOpen: configAppOpen,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  AdSize getAdmobAdSize({
    EasyAdsBannerType type = EasyAdsBannerType.standard,
  }) {
    if (admobAdSize == null) {
      if (navigatorKey?.currentContext != null) {
        Future(
          () async {
            admobAdSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
                MediaQuery.sizeOf(navigatorKey!.currentContext!).width.toInt());
          },
        );
      }
      return AdSize.banner;
    }
    switch (type) {
      case EasyAdsBannerType.standard:
        return AdSize.banner;
      case EasyAdsBannerType.adaptive:
      case EasyAdsBannerType.collapsible_bottom:
      case EasyAdsBannerType.collapsible_top:
        return admobAdSize!;
    }
  }

  Size getAppLovinAdSize({
    EasyAdsBannerType type = EasyAdsBannerType.standard,
  }) {
    final width = isTablet() ? _leaderWidth : _bannerWidth;
    final height = isTablet() ? _leaderHeight : _bannerHeight;
    final adSize = Size(width, height);
    if (appLovinAdSize == null) {
      if (navigatorKey?.currentContext != null) {
        Future(
          () async {
            final width = MediaQuery.sizeOf(navigatorKey!.currentContext!).width;

            double? height = await AppLovinMAX.getAdaptiveBannerHeightForWidth(width);
            height ??= isTablet() ? _leaderHeight : _bannerHeight;
            appLovinAdSize = Size(width, height);
          },
        );
      }
      return adSize;
    }

    switch (type) {
      case EasyAdsBannerType.standard:
        return adSize;
      case EasyAdsBannerType.adaptive:
      case EasyAdsBannerType.collapsible_bottom:
      case EasyAdsBannerType.collapsible_top:
        return appLovinAdSize!;
    }
  }

  Future<bool> isDeviceOffline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.wifi &&
        connectivityResult != ConnectivityResult.mobile) {
      return true;
    }
    return false;
  }
}
