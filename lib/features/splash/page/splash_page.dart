import 'package:ads_sample_app/features/splash/controller/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final controller = Get.put(SplashController());

  @override
  void initState() {
    controller.initAdModule();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: CircularProgressIndicator()),
          SizedBox(height: 50),
          Text(
            "This is where you init your ads module!",
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
