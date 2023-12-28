import 'dart:async';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:easy_ads_flutter/src/ump/ump_handler.dart';
import 'package:flutter/material.dart';

class EasyAppOpenAd extends StatefulWidget {
  final AdNetwork adNetwork;
  final String adId;
  final int orientation;
  final EasyAdCallback? onAdLoaded;
  final EasyAdCallback? onAdShowed;
  final EasyAdCallback? onAdClicked;
  final EasyAdFailedCallback? onAdFailedToLoad;
  final EasyAdFailedCallback? onAdFailedToShow;
  final EasyAdCallback? onAdDismissed;
  final EasyAdEarnedReward? onEarnedReward;
  final EasyAdOnPaidEvent? onPaidEvent;

  const EasyAppOpenAd({
    Key? key,
    this.adNetwork = AdNetwork.admob,
    required this.adId,
    this.orientation = AppOpenAd.orientationPortrait,
    this.onAdLoaded,
    this.onAdShowed,
    this.onAdClicked,
    this.onAdFailedToLoad,
    this.onAdFailedToShow,
    this.onAdDismissed,
    this.onEarnedReward,
    this.onPaidEvent,
  }) : super(key: key);

  @override
  State<EasyAppOpenAd> createState() => _EasyAppOpenAdState();
}

class _EasyAppOpenAdState extends State<EasyAppOpenAd> with WidgetsBindingObserver {
  late final EasyAdBase? _appOpenAd;

  Future<void> _showAd() => Future.delayed(
        const Duration(milliseconds: 500),
        () {
          if (_appLifecycleState == AppLifecycleState.resumed) {
            if (mounted) {
              _appOpenAd!.show();
            }
          } else {
            _adFailedToShow = true;
          }
        },
      );

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    EasyAds.instance.setFullscreenAdShowing(true);
    if (!UmpHandler.umpShowed) {
      UmpHandler.handleRequestUmp(handleOk: () {
        initAndLoadAd();
      }, handleError: () {
        if (mounted) {
          Navigator.of(context).pop();
        }
        widget.onAdFailedToLoad?.call(widget.adNetwork, AdUnitType.appOpen, null, "");
        EasyAds.instance.setFullscreenAdShowing(false);
      });
    } else {
      initAndLoadAd();
    }
    super.initState();
  }

  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  bool _adFailedToShow = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
    if (state == AppLifecycleState.resumed && _adFailedToShow) {
      _showAd();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void initAndLoadAd() {
    _appOpenAd = EasyAds.instance.createAppOpenAd(
      adNetwork: widget.adNetwork,
      adId: widget.adId,
      orientation: widget.orientation,
      onAdLoaded: (adNetwork, adUnitType, data) {
        widget.onAdLoaded?.call(adNetwork, adUnitType, data);
        _showAd();
      },
      onAdClicked: (adNetwork, adUnitType, data) {
        widget.onAdClicked?.call(adNetwork, adUnitType, data);
      },
      onAdDismissed: (adNetwork, adUnitType, data) {
        if (widget.onAdShowed == null) {
          Navigator.of(context).pop();
        }
        widget.onAdDismissed?.call(adNetwork, adUnitType, data);
        EasyAds.instance.setFullscreenAdShowing(false);
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        if (mounted) {
          Navigator.of(context).pop();
        }
        widget.onAdFailedToLoad?.call(adNetwork, adUnitType, data, errorMessage);
        EasyAds.instance.setFullscreenAdShowing(false);
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        if (mounted) {
          Navigator.of(context).pop();
        }
        widget.onAdFailedToShow?.call(adNetwork, adUnitType, data, errorMessage);
        EasyAds.instance.setFullscreenAdShowing(false);
      },
      onAdShowed: (adNetwork, adUnitType, data) {
        if (widget.onAdShowed != null) {
          Navigator.of(context).pop();
          widget.onAdShowed!.call(adNetwork, adUnitType, data);
        }
      },
      onEarnedReward: (adNetwork, adUnitType, rewardType, rewardAmount) {
        widget.onEarnedReward?.call(adNetwork, adUnitType, rewardType, rewardAmount);
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
      },
    );
    _appOpenAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: const Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Welcome back',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
