import 'package:flutter/material.dart';

class ResizableText extends Text {
  const ResizableText(
    super.data, {
    super.key,
    this.fit = BoxFit.scaleDown,
    super.style,
    super.strutStyle,
    super.textAlign,
    super.textDirection,
    super.locale,
    super.softWrap,
    super.overflow,
    super.textScaler,
    super.maxLines,
    super.semanticsLabel,
    super.textWidthBasis,
    super.textHeightBehavior,
    super.selectionColor,
  });

  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: fit,
      child: super.build(context),
    );
  }
}
