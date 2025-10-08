import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/theme.dart';

class MuscleMap extends StatelessWidget {
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final double width;
  final double height;

  const MuscleMap({
    super.key,
    required this.primaryMuscles,
    this.secondaryMuscles = const [],
    this.width = 80,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: SvgPicture.asset(
        'assets/images/body_front.svg', 
        colorFilter: const ColorFilter.mode(darkCardColor, BlendMode.srcIn),
        semanticsLabel: 'Muscle Map Front',
      ),
    );
  }
}