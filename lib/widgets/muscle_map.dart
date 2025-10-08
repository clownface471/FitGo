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

  bool _isFrontMuscle(String muscle) {
    const frontMuscles = {'shoulders', 'chest', 'abs', 'obliques', 'adductors', 'quadriceps', 'biceps', 'forearms'};
    return frontMuscles.contains(muscle);
  }

  @override
  Widget build(BuildContext context) {
    bool showFront = primaryMuscles.any(_isFrontMuscle) || primaryMuscles.isEmpty;

    return SizedBox(
      width: width,
      height: height,
      child: SvgPicture.asset(
        showFront ? 'assets/images/body_front.svg' : 'assets/images/body_back.svg',
        colorFilter: const ColorFilter.mode(darkCardColor, BlendMode.srcIn),
        semanticsLabel: 'Muscle Map',
      ),
    );
  }
}