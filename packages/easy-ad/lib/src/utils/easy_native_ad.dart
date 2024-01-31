import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../consent_manager/consent_manager.dart';
import '../easy_ad_base.dart';
import '../easy_ads.dart';
import '../enums/ad_network.dart';
import '../enums/ad_unit_type.dart';

class EasyNativeAd extends StatefulWidget {
  final AdNetwork adNetwork;
  final String factoryId;
  final String adId;
  final double height;
  final Color? color;
  final BorderRadiusGeometry borderRadius;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;

  final EasyAdCallback? onAdLoaded;
  final EasyAdCallback? onAdShowed;
  final EasyAdCallback? onAdClicked;
  final EasyAdFailedCallback? onAdFailedToLoad;
  final EasyAdFailedCallback? onAdFailedToShow;
  final EasyAdCallback? onAdDismissed;
  final EasyAdOnPaidEvent? onPaidEvent;
  final bool config;

  final bool reloadOnClick;

  final String visibilityDetectorKey;
  final ValueNotifier<bool>? visibilityController;

  final Widget? appLovinLayout;

  const EasyNativeAd({
    this.adNetwork = AdNetwork.admob,
    required this.factoryId,
    required this.adId,
    required this.height,
    required this.color,
    required this.border,
    required this.padding,
    this.borderRadius = BorderRadius.zero,
    this.onAdLoaded,
    this.onAdShowed,
    this.onAdClicked,
    this.onAdFailedToLoad,
    this.onAdFailedToShow,
    this.onAdDismissed,
    this.onPaidEvent,
    required this.config,
    required this.visibilityDetectorKey,
    this.visibilityController,
    this.appLovinLayout,
    this.reloadOnClick = false,
    Key? key,
  }) : super(key: key);

  @override
  State<EasyNativeAd> createState() => _EasyNativeAdState();
}

class _EasyNativeAdState extends State<EasyNativeAd> with WidgetsBindingObserver {
  EasyAdBase? _nativeAd;

  late final ValueNotifier<bool> visibilityController;
  int loadFailedCount = 0;
  static const int maxFailedTimes = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    visibilityController = widget.visibilityController ?? ValueNotifier(true);
    visibilityController.addListener(_listener);
  }

  @override
  void didChangeDependencies() {
    initAds();
    super.didChangeDependencies();
  }

  void _listener() {
    if (_nativeAd?.isAdLoading != true && visibilityController.value) {
      initAds();
    }
    if (!visibilityController.value) {
      loadFailedCount = 0;
    }
  }

  Future<void> initAds() async {
    if (loadFailedCount == maxFailedTimes) {
      return;
    }
    if (!EasyAds.instance.isEnabled) {
      return;
    }
    if (await EasyAds.instance.isDeviceOffline()) {
      return;
    }
    if (!widget.config) {
      return;
    }

    ConsentManager.ins.handleRequestUmp(
      onPostExecute: () {
        if (ConsentManager.ins.canRequestAds) {
          initAndLoadAd();
        } else {
          return;
        }
      },
    );
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    visibilityController.removeListener(_listener);
    visibilityController.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  bool isClicked = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (isClicked) {
          isClicked = false;
          initAds();
        }

        break;
      default:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.visibilityDetectorKey),
      onVisibilityChanged: (info) {
        try {
          if (info.visibleFraction < 0.1) {
            if (visibilityController.value) {
              visibilityController.value = false;
            }
          } else {
            if (!visibilityController.value) {
              visibilityController.value = true;
            }
          }
          // ignore: empty_catches
        } catch (e) {}
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: visibilityController,
        builder: (_, isVisible, __) {
          return Visibility(
            visible: isVisible,
            maintainState: widget.adNetwork == AdNetwork.appLovin,
            maintainAnimation: widget.adNetwork == AdNetwork.appLovin,
            maintainSize: widget.adNetwork == AdNetwork.appLovin,
            maintainSemantics: widget.adNetwork == AdNetwork.appLovin,
            maintainInteractivity: widget.adNetwork == AdNetwork.appLovin,
            child: _nativeAd?.show(
                  height: widget.height,
                  borderRadius: widget.borderRadius,
                  color: widget.color,
                  border: widget.border,
                  padding: widget.padding,
                ) ??
                const SizedBox(
                  height: 1,
                  width: 1,
                ),
            replacement: SizedBox(
              height: widget.height,
              width: MediaQuery.sizeOf(context).width,
            ),
          );
        },
      ),
    );
  }

  void initAndLoadAd() {
    if (widget.adNetwork != AdNetwork.appLovin) {
      if (_nativeAd != null) {
        _nativeAd!.dispose();
        _nativeAd = null;
      }
    }

    _nativeAd ??= EasyAds.instance.createNative(
      adNetwork: widget.adNetwork,
      factoryId: widget.factoryId,
      adId: widget.adId,
      appLovinLayout: widget.appLovinLayout,
      onAdClicked: (adNetwork, adUnitType, data) {
        widget.onAdClicked?.call(adNetwork, adUnitType, data);
        isClicked = widget.reloadOnClick;
        if (mounted) {
          setState(() {});
        }
      },
      onAdDismissed: (adNetwork, adUnitType, data) {
        widget.onAdDismissed?.call(adNetwork, adUnitType, data);
        if (mounted) {
          setState(() {});
        }
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        loadFailedCount++;
        widget.onAdFailedToLoad?.call(adNetwork, adUnitType, data, errorMessage);
        if (mounted) {
          setState(() {});
        }
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        widget.onAdFailedToShow?.call(adNetwork, adUnitType, data, errorMessage);
        if (mounted) {
          setState(() {});
        }
      },
      onAdLoaded: (adNetwork, adUnitType, data) {
        loadFailedCount = 0;
        widget.onAdLoaded?.call(adNetwork, adUnitType, data);
        if (mounted) {
          setState(() {});
        }
      },
      onAdShowed: (adNetwork, adUnitType, data) {
        widget.onAdShowed?.call(adNetwork, adUnitType, data);
        if (mounted) {
          setState(() {});
        }
      },
      onPaidEvent: ({
        required AdNetwork adNetwork,
        required AdUnitType adUnitType,
        required double revenue,
        required String currencyCode,
        String? network,
        String? unit,
        String? placement,
      }) {
        widget.onPaidEvent?.call(
          adNetwork: adNetwork,
          adUnitType: adUnitType,
          revenue: revenue,
          currencyCode: currencyCode,
          network: network,
          unit: unit,
          placement: placement,
        );
        if (mounted) {
          setState(() {});
        }
      },
    );

    _nativeAd?.load();
    if (mounted) {
      setState(() {});
    }
    visibilityController.value = true;
  }
}
