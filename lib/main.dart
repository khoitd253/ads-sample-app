import 'package:ads_sample_app/features/ads/manager/ad_id_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'features/app.dart';
import 'firebase_options.dart';

AppAdIdManager adIdManager = AppAdIdManager();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
