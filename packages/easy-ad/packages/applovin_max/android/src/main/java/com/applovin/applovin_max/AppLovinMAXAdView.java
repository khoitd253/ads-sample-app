package com.applovin.applovin_max;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.applovin.mediation.MaxAd;
import com.applovin.mediation.MaxAdFormat;
import com.applovin.mediation.MaxAdRevenueListener;
import com.applovin.mediation.MaxAdViewAdListener;
import com.applovin.mediation.MaxError;
import com.applovin.mediation.ads.MaxAdView;
import com.applovin.sdk.AppLovinSdk;
import com.applovin.sdk.AppLovinSdkUtils;

import java.util.Map;
import java.util.Objects;
import java.util.concurrent.atomic.AtomicBoolean;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

/**
 * Created by Thomas So on July 17 2022
 */
public class AppLovinMAXAdView implements PlatformView, MaxAdViewAdListener, MaxAdRevenueListener {
    private final MethodChannel channel;

    @Nullable
    private MaxAdView adView;

    private final Context context;

    private final AppLovinSdk sdk;

    @Nullable
    private Map<String, Object> extraParameters;
    @Nullable
    private Map<String, Object> localExtraParameters;
    private final AtomicBoolean isLoading = new AtomicBoolean(); // Guard against repeated ad loads

    private final String adUnitId;
    @Nullable
    private final String placement;
    @Nullable
    private final String customData;

    private final Boolean isAutoRefreshEnabled;

    private final MaxAdFormat adFormat;

    @Nullable
    private MaxAd nativeAd;

    public AppLovinMAXAdView(final int viewId, final String adUnitId, final MaxAdFormat adFormat, final boolean isAutoRefreshEnabled, @Nullable final String placement, @Nullable final String customData, @Nullable final Map<String, Object> extraParameters, @Nullable final Map<String, Object> localExtraParameters, final BinaryMessenger messenger, final AppLovinSdk sdk, final Context context) {
        this.context = context;
        this.sdk = sdk;
        this.extraParameters = extraParameters;
        this.localExtraParameters = localExtraParameters;
        this.adUnitId = adUnitId;
        this.placement = placement;
        this.customData = customData;
        this.isAutoRefreshEnabled = isAutoRefreshEnabled;
        this.adFormat = adFormat;
        String uniqueChannelName = "applovin_max/adview_" + viewId;
        channel = new MethodChannel(messenger, uniqueChannelName);
        channel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(@NonNull final MethodCall call, @NonNull final MethodChannel.Result result) {
                if ("startAutoRefresh".equals(call.method)) {
                    if (adView != null) {
                        adView.startAutoRefresh();
                    }

                    result.success(null);
                } else if ("stopAutoRefresh".equals(call.method)) {
                    if (adView != null) {
                        adView.stopAutoRefresh();
                    }

                    result.success(null);
                } else if ("loadAd".equals(call.method)) {
                    loadAd();
                    result.success(null);
                } else {
                    result.notImplemented();
                }
            }
        });

        loadAd();
    }

    private void loadAd() {
        if (isLoading.compareAndSet(false, true)) {
            AppLovinMAX.d("Loading a banner ad for Ad Unit ID: " + adUnitId + "...");
            if (adView == null || !adUnitId.equals(adView.getAdUnitId())) {
                adView = new MaxAdView(adUnitId, adFormat, sdk, context);
                adView.setListener(this);
                adView.setRevenueListener(this);
                adView.setPlacement(placement);
                adView.setCustomData(customData);

                adView.setExtraParameter("allow_pause_auto_refresh_immediately", "true");

                Boolean adaptiveBannerEnabled = false;
                int adaptiveBannerWidth = 0;
                if (extraParameters != null) {
                    for (Map.Entry<String, Object> entry : extraParameters.entrySet()) {
                        adView.setExtraParameter(entry.getKey(), (String) entry.getValue());
                        if (entry.getKey().equalsIgnoreCase("adaptive_banner")) {
                            adaptiveBannerEnabled = Objects.equals((String) entry.getValue(), "true");
                        }
                    }
                }

                if (localExtraParameters != null) {
                    for (Map.Entry<String, Object> entry : localExtraParameters.entrySet()) {
                        adView.setLocalExtraParameter(entry.getKey(), entry.getValue());
                        if (entry.getKey().equalsIgnoreCase("adaptive_banner_width")) {
                            adaptiveBannerWidth = (int) entry.getValue();
                        }
                    }
                }

                if (adaptiveBannerEnabled && adaptiveBannerWidth > 0) {
                    final int height = adView.getAdFormat().getAdaptiveSize(adaptiveBannerWidth, context).getHeight();
                    adView.setLayoutParams(new FrameLayout.LayoutParams(adaptiveBannerWidth, height));
                } else {
                    final AppLovinMAX.AdViewSize adViewSize = AppLovinMAX.getAdViewSize(adFormat);
                    final int width = AppLovinSdkUtils.dpToPx(context, adViewSize.widthDp);
                    final int height = AppLovinSdkUtils.dpToPx(context, adViewSize.heightDp);
                    adView.setLayoutParams(new FrameLayout.LayoutParams(width, height));
                }
            }

            adView.loadAd();

            if (!isAutoRefreshEnabled) {
                adView.stopAutoRefresh();
            }
        } else {
            AppLovinMAX.e("Ignoring request to load banner ad for Ad Unit ID " + adUnitId + ", another ad load in progress");
        }
    }

    /// Flutter Lifecycle Methods

    @Nullable
    @Override
    public View getView() {
        return adView;
    }

    @Override
    public void onFlutterViewAttached(@NonNull final View flutterView) {
    }

    @Override
    public void onFlutterViewDetached() {
    }

    @Override
    public void dispose() {
        maybeDestroyCurrentAd();

        if (channel != null) {
            channel.setMethodCallHandler(null);
        }
    }

    @Override
    public void onAdLoaded(final MaxAd ad) {
        AppLovinMAX.d("Banner ad loaded: " + ad);
        isLoading.set(false);
        sendEvent("OnAdViewAdLoadedEvent", ad);
    }

    @Override
    public void onAdLoadFailed(final String adUnitId, final MaxError error) {
        isLoading.set(false);
        AppLovinMAX.getInstance().fireErrorCallback("OnAdViewAdLoadFailedEvent", adUnitId, error, channel);
    }

    @Override
    public void onAdClicked(final MaxAd ad) {
        sendEvent("OnAdViewAdClickedEvent", ad);
    }

    @Override
    public void onAdExpanded(final MaxAd ad) {
        sendEvent("OnAdViewAdExpandedEvent", ad);
    }

    @Override
    public void onAdCollapsed(final MaxAd ad) {
        sendEvent("OnAdViewAdCollapsedEvent", ad);
    }

    @Override
    public void onAdDisplayed(final MaxAd ad) {
    }

    @Override
    public void onAdDisplayFailed(final MaxAd ad, final MaxError error) {
    }

    @Override
    public void onAdHidden(final MaxAd ad) {
    }

    @Override
    public void onAdRevenuePaid(final MaxAd ad) {
        sendEvent("OnAdViewAdRevenuePaidEvent", ad);
    }

    private void sendEvent(final String event, final MaxAd ad) {
        AppLovinMAX.getInstance().fireCallback(event, ad, channel);
    }


    private void maybeDestroyCurrentAd() {
        if (nativeAd != null) {
            nativeAd = null;
        }
        if (adView != null) {
            adView.destroy();
            adView.setListener(null);
            adView.setRevenueListener(null);
            adView = null;
        }
    }
}
