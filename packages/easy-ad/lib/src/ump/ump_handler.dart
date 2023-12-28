import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../easy_ads_flutter.dart';

class UmpHandler {
  static bool _umpShowed = false;
  static bool umpConfig = false;

  static bool get umpShowed => _umpShowed;

  static void handleRequestUmp(
      {required VoidCallback handleOk, required VoidCallback handleError}) {
    //TODO: bỏ reset và debugSetting khi lên prod
    // ConsentInformation.instance.reset();
    // ConsentDebugSettings debugSettings = ConsentDebugSettings(
    //     debugGeography: DebugGeography.debugGeographyEea,
    //     testIdentifiers: ["8376397C928FD432F926C7F278AEDFD0"]);

    ///===========================================

    if (!umpConfig) {
      handleOk.call();
      return;
    }

    final params = ConsentRequestParameters();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          _loadUmpForm(
            handleOk: handleOk,
            handleError: handleError,
          );
        } else {
          handleOk.call();
          _umpShowed = true;
          print("UMP: Consent form not available");
        }
      },
      (FormError error) {
        _umpShowed = true;
        handleOk.call();
        print("UMP: Get consent info failed");
      },
    );
  }

  static void _loadUmpForm({required VoidCallback handleOk, required VoidCallback handleError}) {
    ConsentForm.loadConsentForm(
      (ConsentForm consentForm) async {
        // Present the form
        var status = await ConsentInformation.instance.getConsentStatus();
        switch (status) {
          case ConsentStatus.required:
            consentForm.show(
              (FormError? formError) async {
                var statusAfterClick = await ConsentInformation.instance.getConsentStatus();
                switch (statusAfterClick) {
                  case ConsentStatus.unknown:
                    //disable ads
                    handleError.call();
                    _umpShowed = false;
                    break;
                  case ConsentStatus.obtained:
                  case ConsentStatus.notRequired:
                    //init ads
                    handleOk.call();
                    _umpShowed = true;
                    break;
                  case ConsentStatus.required:
                    _loadUmpForm(handleOk: handleOk, handleError: handleError);
                    break;
                }
              },
            );
            break;
          case ConsentStatus.obtained:
          case ConsentStatus.notRequired:
            // init ads
            handleOk.call();
            _umpShowed = true;
            break;
          case ConsentStatus.unknown:
            // disable ads
            handleError.call();
            _umpShowed = false;
            break;
        }
      },
      (FormError formError) async {
        // disable ads module
        handleError.call();
        _umpShowed = false;
      },
    );
  }
}
