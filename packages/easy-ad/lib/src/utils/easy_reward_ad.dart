import 'dart:async';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:easy_ads_flutter/src/ump/ump_handler.dart';
import 'package:flutter/material.dart';

class EasyRewardAd extends StatefulWidget {
  final AdNetwork adNetwork;
  final String adId;
  final bool immersiveModeEnabled;
  final EasyAdCallback? onAdLoaded;
  final EasyAdCallback? onAdShowed;
  final EasyAdCallback? onAdClicked;
  final EasyAdFailedCallback? onAdFailedToLoad;
  final EasyAdFailedCallback? onAdFailedToShow;
  final EasyAdCallback? onAdDismissed;
  final EasyAdEarnedReward? onEarnedReward;
  final EasyAdOnPaidEvent? onPaidEvent;

  const EasyRewardAd({
    Key? key,
    required this.adNetwork,
    required this.adId,
    required this.immersiveModeEnabled,
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
  State<EasyRewardAd> createState() => _EasyRewardAdState();
}

class _EasyRewardAdState extends State<EasyRewardAd> with WidgetsBindingObserver {
  late final EasyAdBase? _rewardAd;

  Future<void> _showAd() => Future.delayed(
        const Duration(seconds: 1),
        () {
          if (_appLifecycleState == AppLifecycleState.resumed) {
            if (mounted) {
              _rewardAd?.show();
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
      UmpHandler.handleRequestUmp(
          handleOk: () {
            initAndLoadAd();
          },
          handleError: () {});
      _rewardAd?.load();
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
    _rewardAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: const Scaffold(
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
              'Loading Ads',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void initAndLoadAd() {
    _rewardAd = EasyAds.instance.createReward(
      adNetwork: widget.adNetwork,
      adId: widget.adId,
      immersiveModeEnabled: widget.immersiveModeEnabled,
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
        Navigator.of(context).pop();
        widget.onAdFailedToLoad?.call(adNetwork, adUnitType, data, errorMessage);
        EasyAds.instance.setFullscreenAdShowing(false);
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        Navigator.of(context).pop();
        widget.onAdFailedToShow?.call(adNetwork, adUnitType, data, errorMessage);
        EasyAds.instance.setFullscreenAdShowing(false);
      },
      onAdLoaded: (adNetwork, adUnitType, data) {
        widget.onAdLoaded?.call(adNetwork, adUnitType, data);
        _showAd();
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
  }
}
