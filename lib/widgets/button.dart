import 'package:flutter/material.dart';

class GlassButton extends StatelessWidget {
  final bool active;
  final VoidCallback onPressed;
  final Image signToShow;
  final double width;
  final double height;
  const GlassButton(
      {super.key,
      required this.active,
      required this.onPressed,
      required this.signToShow,
      this.width = 100,
      this.height = 100});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(alignment: Alignment.center, children: [
        SizedBox(
          width: width,
          height: height,
          child: Image.asset(active
              ? 'assets/button_active.png'
              : 'assets/button_inactive.png'),
        ),
        if (active)
          SizedBox(width: width / 2.5, height: height / 2.5, child: signToShow)
      ]),
      onPressed: active ? onPressed : null,
    );
  }
}
