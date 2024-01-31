import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../consent_manager/consent_manager.dart';
import '../easy_ad_base.dart';
import '../easy_ads.dart';
import '../enums/ad_network.dart';
import '../enums/ad_unit_type.dart';

class EasyBannerAd extends StatefulWidget {
  final AdNetwork adNetwork;
  final String adId;
  final EasyAdsBannerType type;

  final EasyAdCallback? onAdLoaded;
  final EasyAdCallback? onAdShowed;
  final EasyAdCallback? onAdClicked;
  final EasyAdFailedCallback? onAdFailedToLoad;
  final EasyAdFailedCallback? onAdFailedToShow;
  final EasyAdCallback? onAdDismissed;
  final EasyAdEarnedReward? onEarnedReward;
  final EasyAdOnPaidEvent? onPaidEvent;
  final bool config;
  final bool reloadOnClick;

  final String visibilityDetectorKey;
  final ValueNotifier<bool>? visibilityController;

  const EasyBannerAd({
    this.adNetwork = AdNetwork.admob,
    required this.adId,
    this.type = EasyAdsBannerType.standard,
    this.onAdLoaded,
    this.onAdShowed,
    this.onAdClicked,
    this.onAdFailedToLoad,
    this.onAdFailedToShow,
    this.onAdDismissed,
    this.onEarnedReward,
    this.onPaidEvent,
    required this.config,
    this.reloadOnClick = false,
    required this.visibilityDetectorKey,
    this.visibilityController,
    Key? key,
  }) : super(key: key);

  @override
  State<EasyBannerAd> createState() => _EasyBannerAdState();
}

class _EasyBannerAdState extends State<EasyBannerAd> with WidgetsBindingObserver {
  EasyAdBase? _bannerAd;
  int loadFailedCount = 0;
  static const int maxFailedTimes = 3;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.visibilityDetectorKey),
      onVisibilityChanged: (info) {
        if (!mounted) {
          return;
        }
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
        } catch (e) {
          /// visibility error
        }
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
            child: _bannerAd?.show() ??
                const SizedBox(
                  height: 1,
                  width: 1,
                ),
            replacement: SizedBox(
              height: 50,
              width: MediaQuery.sizeOf(context).width,
            ),
          );
        },
      ),
    );
  }

  Future<void> _initAd() async {
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

  late final ValueNotifier<bool> visibilityController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    visibilityController = widget.visibilityController ?? ValueNotifier(true);
    visibilityController.addListener(_listener);
  }

  void _listener() {
    if (_bannerAd?.isAdLoading != true && visibilityController.value) {
      _initAd();
      return;
    }

    if (!visibilityController.value) {
      loadFailedCount = 0;
      if (widget.adNetwork != AdNetwork.appLovin) {
        if (_bannerAd != null) {
          _bannerAd!.dispose();
          _bannerAd = null;
          if (mounted) {
            setState(() {});
          }
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    _initAd();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    visibilityController.removeListener(_listener);
    visibilityController.dispose();
    super.dispose();
  }

  bool isClicked = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (isClicked) {
          isClicked = false;
          _initAd();
        }

        break;
      default:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  void initAndLoadAd() {
    if (widget.adNetwork != AdNetwork.appLovin) {
      if (_bannerAd != null) {
        _bannerAd!.dispose();
        _bannerAd = null;
        if (mounted) {
          setState(() {});
        }
      }
    }

    _bannerAd ??= EasyAds.instance.createBanner(
      adNetwork: widget.adNetwork,
      adId: widget.adId,
      type: widget.type,
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

    _bannerAd?.load();
    if (mounted) {
      setState(() {});
    }
    visibilityController.value = true;
  }
}
