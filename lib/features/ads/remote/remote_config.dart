class RemoteConfig {
  static Future<void> init() async {
    /// fake delay fetch
    await Future.delayed(const Duration(seconds: 2));
  }

  static void getRemoteConfig() {
    /// fake value assign
  }

  /// remote config value here
  static bool interSplashConfig = true;
  static bool appOpenSplashConfig = true;
  static bool resumeConfig = true;
  static bool interConfig = true;
  static bool nativeConfig = true;
  static bool bannerConfig = true;
  static bool rewardConfig = true;
}
