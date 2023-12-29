package com.example.ads_sample_app;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;
import org.jetbrains.annotations.NotNull;

public class MainActivity extends FlutterActivity {


    @Override
    public void configureFlutterEngine(@NotNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        GoogleMobileAdsPlugin.NativeAdFactory largeAdFactory = new LargeNativeAd(getLayoutInflater());
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "large_ad_factory", largeAdFactory);

        GoogleMobileAdsPlugin.NativeAdFactory mediumAdFactory = new MediumNativeAd(getLayoutInflater());
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "medium_ad_factory", mediumAdFactory);

        GoogleMobileAdsPlugin.NativeAdFactory smallAdFactory = new SmallNativeAd(getLayoutInflater());
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "small_ad_factory", smallAdFactory);
    }


    @Override
    public void cleanUpFlutterEngine(@NotNull FlutterEngine flutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "large_ad_factory");
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "medium_ad_factory");
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "small_ad_factory");
    }
}
