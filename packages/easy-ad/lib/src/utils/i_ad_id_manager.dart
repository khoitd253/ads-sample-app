abstract class IAdIdManager {
  const IAdIdManager();

  /// Pass null if you wish not to implement admob ads
  ///
  /// AppAdIds? get admobAdIds => null;
  AppAdIds? get admobAdIds;

  /// Pass null if you wish not to implement appLovin ads
  ///
  /// AppAdIds? get appLovinAdIds => null;
  AppAdIds? get appLovinAdIds;
}

class AppAdIds {
  /// App Id should never be null, if there is no app id for a particular ad network, leave it empty
  final String appId;

  const AppAdIds({
    required this.appId,
  });
}
