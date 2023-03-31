import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.splashColor,
      required this.iconSize,
      required this.iconPath,
      required this.callback});

  final Color splashColor;
  final double iconSize;
  final String iconPath;
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: callback,
          splashColor: splashColor,
          highlightColor: splashColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              iconPath,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              width: iconSize,
              height: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
