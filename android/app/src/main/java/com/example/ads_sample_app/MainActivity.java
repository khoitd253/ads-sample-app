package com.example.ads_sample_app;

import org.jetbrains.annotations.NotNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;

public class MainActivity extends FlutterActivity {


    @Override
    public void configureFlutterEngine(@NotNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor()
                .getBinaryMessenger(), "channel")
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "init_mediation": {
                            boolean canRequestAds = (boolean) call.arguments;
                            initMediation(canRequestAds);
                            result.success(true);
                        }
                        case "flavor":
                            result.success(BuildConfig.FLAVOR);
                    }
                });


        GoogleMobileAdsPlugin.NativeAdFactory largeAdFactory = new LargeNativeAd(getLayoutInflater());
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "large_ad_factory", largeAdFactory);

        GoogleMobileAdsPlugin.NativeAdFactory mediumAdFactory = new MediumNativeAd(getLayoutInflater());
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "medium_ad_factory", mediumAdFactory);

        GoogleMobileAdsPlugin.NativeAdFactory smallAdFactory = new SmallNativeAd(getLayoutInflater());
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "small_ad_factory", smallAdFactory);
    }


    private void initMediation(boolean canRequestAds) {
        /// read mediation's documentations to integrated
    }

    @Override
    public void cleanUpFlutterEngine(@NotNull FlutterEngine flutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "large_ad_factory");
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "medium_ad_factory");
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "small_ad_factory");
    }
}
