package com.zens.easy_ad;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.util.Log;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.Objects;

/**
 * EasyAd_2Plugin
 */
public class EasyAdPlugin
  implements FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

  private MethodChannel channel;
  private Context context;

  @Override
  public void onAttachedToEngine(
    @NonNull FlutterPluginBinding flutterPluginBinding
  ) {
    channel =
      new MethodChannel(
        flutterPluginBinding.getBinaryMessenger(),
        "easy_ads_flutter"
      );
    this.context = flutterPluginBinding.getApplicationContext();
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(
    @NonNull MethodCall call,
    @NonNull MethodChannel.Result result
  ) {
    switch (call.method) {
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "hasConsentForPurposeOne":
        SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(
          context
        );
        // Example value: "1111111111"
        String purposeConsents = sharedPref.getString(
          "IABTCF_PurposeConsents",
          ""
        );

        // Purposes are zero-indexed. Index 0 contains information about Purpose 1.
        if (!purposeConsents.isEmpty()) {
          String purposeOneString = String.valueOf(purposeConsents.charAt(0));
          boolean hasConsentForPurposeOne = Objects.equals(
            purposeOneString,
            "1"
          );
          result.success(hasConsentForPurposeOne);
        } else {
          result.success(null);
        }
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {}

  @Override
  public void onReattachedToActivityForConfigChanges(
    @NonNull ActivityPluginBinding binding
  ) {}

  @Override
  public void onDetachedFromActivity() {}

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {}
}
