import 'dart:async';

import 'package:ads_sample_app/features/splash/page/splash_page.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AppLifecycleState? _state;
  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _streamSubscription = EasyAds.instance.onEvent.listen((event) {});
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_state == AppLifecycleState.paused) {
        EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(false);
      }
    } else if (state == AppLifecycleState.paused) {}
    _state = state;
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      home: SplashPage(),
    );
  }
}
