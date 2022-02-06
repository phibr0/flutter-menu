import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class ProfileIcon extends StatelessWidget {
  const ProfileIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        child: const CircleAvatar(
          foregroundImage: NetworkImage(
            "https://cdn.onlinewebfonts.com/svg/download_206976.png",
          ),
          backgroundColor: Colors.transparent,
        ),
        onLongPress: () {
          if (kDebugMode) {
            storage.deleteAll();
          }
        },
      ),
    );
  }
}
