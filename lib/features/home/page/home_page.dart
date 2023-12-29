import 'package:ads_sample_app/features/home/controller/home_controller.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../main.dart';
import '../../ads/remote/remote_config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Text(
                "Hide App to background to show Resume Ad",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.showInterAd,
                child: const Text("Show Interstitial Ad"),
              ),
              ElevatedButton(
                onPressed: () => controller.changeAdIndex(0),
                child: const Text("Show Banner Ad"),
              ),
              ElevatedButton(
                onPressed: () => controller.changeAdIndex(1),
                child: const Text("Show Banner Collapsible Ad"),
              ),
              ElevatedButton(
                onPressed: controller.showRewardAd,
                child: const Text("Show Reward Ad"),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.changeAdIndex(2),
                      child: const Text(
                        "Large Native",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.changeAdIndex(3),
                      child: const Text(
                        "Medium Native",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.changeAdIndex(4),
                      child: const Text(
                        "Small Native",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (controller.indexToShowAd[0])
                EasyBannerAd(
                  key: UniqueKey(),
                  adId: adIdManager.bannerId,
                  type: EasyAdsBannerType.adaptive,
                  config: RemoteConfig.bannerConfig,
                  visibilityDetectorKey: runtimeType.toString(),
                ),
              if (controller.indexToShowAd[1])
                EasyBannerAd(
                  key: UniqueKey(),
                  adId: adIdManager.bannerCollapseId,
                  type: EasyAdsBannerType.collapsible_bottom,
                  config: RemoteConfig.bannerConfig,
                  visibilityDetectorKey: runtimeType.toString(),
                ),
              if (controller.indexToShowAd[2])
                EasyNativeAd(
                  key: UniqueKey(),
                  factoryId: adIdManager.largeNativeFactory,
                  adId: adIdManager.nativeId,
                  height: adIdManager.largeNativeAdHeight,
                  color: const Color(0xfff6f6f6),
                  border: null,
                  padding: null,
                  config: RemoteConfig.nativeConfig,
                  visibilityDetectorKey: runtimeType.toString(),
                ),
              if (controller.indexToShowAd[3])
                EasyNativeAd(
                  key: UniqueKey(),
                  factoryId: adIdManager.mediumNativeFactory,
                  adId: adIdManager.nativeId,
                  height: adIdManager.mediumNativeAdHeight,
                  color: const Color(0xfff6f6f6),
                  border: null,
                  padding: null,
                  config: RemoteConfig.nativeConfig,
                  visibilityDetectorKey: runtimeType.toString(),
                ),
              if (controller.indexToShowAd[4])
                EasyNativeAd(
                  key: UniqueKey(),
                  factoryId: adIdManager.smallNativeFactory,
                  adId: adIdManager.nativeId,
                  height: adIdManager.smallNativeAdHeight,
                  color: const Color(0xfff6f6f6),
                  border: null,
                  padding: null,
                  config: RemoteConfig.nativeConfig,
                  visibilityDetectorKey: runtimeType.toString(),
                ),
            ],
          );
        },
      ),
    );
  }
}
