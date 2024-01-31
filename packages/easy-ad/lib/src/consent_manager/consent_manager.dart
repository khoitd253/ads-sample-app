import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../easy_ads_flutter.dart';

class ConsentManager {
  static ConsentManager ins = ConsentManager._();

  ConsentManager._();

  static bool _canRequestAds = true;

  bool get canRequestAds => _canRequestAds;

  bool _isMediationInitialized = false;
  bool _isMobileAdsInitialized = false;

  final ConsentDebugSettings _debugSettings = ConsentDebugSettings(
    debugGeography: DebugGeography.debugGeographyEea,
    testIdentifiers: ["8376397C928FD432F926C7F278AEDFD0", "A77F255171A904EBE39BA06DB1654C9C"],
  );

  Future<dynamic> Function(bool)? initMediation;

  Future<void> initMobileAds() async {
    if (_canRequestAds && !_isMobileAdsInitialized) {
      if (EasyAds.instance.admobConfiguration != null) {
        MobileAds.instance.updateRequestConfiguration(EasyAds.instance.admobConfiguration!);
      }

      final initializationStatus = await MobileAds.instance.initialize();
      initializationStatus.adapterStatuses.forEach((key, value) {
        Logger().i('Adapter status for $key: ${value.description}');
      });
      _isMobileAdsInitialized = true;
    }
  }

  Future<void> handleRequestUmp({VoidCallback? onPostExecute}) async {
    //TODO: bỏ reset và debugSetting khi lên prod
    // ConsentInformation.instance.reset();
    // final params =
    //     ConsentRequestParameters(consentDebugSettings: _debugSettings);
    final params = ConsentRequestParameters();

    bool? consentResult = await EasyAds.instance.getConsentResult();

    if (consentResult != null) {
      _canRequestAds = consentResult;

      if (_canRequestAds && !_isMediationInitialized) {
        await initMediation?.call(_canRequestAds);
        _isMediationInitialized = true;
      }
      await initMobileAds();
      onPostExecute?.call();
      return;
    }

    ///===========================================
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          ///form available, try to show it
          _loadAndShowUmpForm(onPostExecute);
        } else {
          _canRequestAds = true;
          await initMediation?.call(_canRequestAds);
          _isMediationInitialized = true;
          await initMobileAds();
          onPostExecute?.call();
          print("Easy Ads UMP: Consent form not available, can request ads!");
        }
      },
      (FormError error) {
        _canRequestAds = true;
        onPostExecute?.call();
        print("Easy Ads UMP: Get consent update info failed, can request ads!");
      },
    );
  }

  void _loadAndShowUmpForm(VoidCallback? onPostExecute) {
    ConsentForm.loadConsentForm(
      (ConsentForm consentForm) async {
        //show the form
        var consentResult = await EasyAds.instance.getConsentResult();
        if (consentResult != null) {
          _canRequestAds = consentResult;
          if (_canRequestAds) {
            await initMediation?.call(_canRequestAds);
            _isMediationInitialized = true;
          }
          await initMobileAds();
          onPostExecute?.call();
        } else {
          consentForm.show((formError) async {
            _canRequestAds = await EasyAds.instance.getConsentResult() ?? true;
            await initMediation?.call(_canRequestAds);
            _isMediationInitialized = true;
            await initMobileAds();
            onPostExecute?.call();
          });
        }
      },
      (FormError formError) async {
        _canRequestAds = await EasyAds.instance.getConsentResult() ?? true;
        await initMediation?.call(_canRequestAds);
        _isMediationInitialized = true;
        await initMobileAds();
        onPostExecute?.call();
      },
    );
  }
}
