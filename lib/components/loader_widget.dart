import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class Loader extends StatelessWidget {
  const Loader({Key? key, this.height, this.width}) : super(key: key);
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    if (height != null && width != null) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Shimmer(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            height: height,
            width: width,
          ),
        ),
      );
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Shimmer(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            height: height,
            width: width,
          ),
        ),
      ),
    );
  }
}
