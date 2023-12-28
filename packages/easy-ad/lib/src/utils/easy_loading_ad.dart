import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EasyLoadingAd extends StatelessWidget {
  const EasyLoadingAd({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Shimmer.fromColors(
        period: const Duration(milliseconds: 300),
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.white,
        child: Container(
          color: Colors.grey,
        ),
      ),
    );
  }
}
