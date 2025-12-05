import 'package:flutter/material.dart';

class MyLogo extends StatelessWidget {
  final double size;
  final double? radius;
  const MyLogo({
    super.key,
   required this.size,
    this.radius

  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: this.size,
        height: this.size,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2
          ),
            borderRadius: BorderRadius.circular(radius ?? 24)
        ),
        child: ClipRRect(
          borderRadius:BorderRadius.circular(radius ?? 24),
          child: Image.asset('assets/images/logo.jpg'),
        )
    );
  }
}
