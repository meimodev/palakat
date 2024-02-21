import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:simple_animations/simple_animations.dart';


class ScanningAnimationWidget extends StatelessWidget {
  const ScanningAnimationWidget({
    super.key,
    required this.containerHeight,
    this.dividerHeight = 0,
    this.baseAnimationDurationMilliSeconds = 1000,
    this.addedAnimationDurationMilliSeconds = 1000,
    required this.dividerColor,
  })  : assert(containerHeight > 0),
        assert(dividerHeight > 0);

  final double containerHeight;
  final double dividerHeight;

  final int baseAnimationDurationMilliSeconds;
  final int addedAnimationDurationMilliSeconds;

  final Color dividerColor;

  MovieTween _calculateTween({required double maxGradientHeight}) {
    const double maxOpacity = 0.75;

    final int addedDuration = addedAnimationDurationMilliSeconds;
    final int baseDuration =
        baseAnimationDurationMilliSeconds + (maxGradientHeight * 1.5).toInt();

    final int firstTimingTotalDuration = baseDuration + addedDuration;

    final int secondTimingBaseDuration = firstTimingTotalDuration;

    return MovieTween()
    // First timing -->
    // upContainer Expand + downContainer Shrink
    // + upGradient Showing + downGradient Fading
      ..scene(
        begin: const Duration(milliseconds: 0),
        duration: Duration(
          milliseconds: baseDuration + addedDuration,
        ),
      ).tween(
        'up_container',
        Tween(begin: 0.0, end: maxGradientHeight),
      )
      ..scene(
        begin: const Duration(milliseconds: 0),
        duration: Duration(
          milliseconds: baseDuration + addedDuration,
        ),
      ).tween(
        'down_container',
        Tween(begin: maxGradientHeight, end: 0.0),
      )
      ..scene(
        begin: const Duration(milliseconds: 0),
        duration: Duration(
          milliseconds: baseDuration + addedDuration,
        ),
      ).tween(
        'up_gradient',
        Tween(begin: 0.0, end: maxOpacity),
      )
      ..scene(
        begin: const Duration(milliseconds: 0),
        duration: Duration(milliseconds: firstTimingTotalDuration ~/ 2),
      ).tween(
        'down_gradient',
        Tween(begin: maxOpacity, end: 0.0),
      )
    // Second timing -->
    // upContainer Shrinking + downContainer Expanding
    // + upGradient Fading + downGradient Showing
      ..scene(
        begin: Duration(milliseconds: firstTimingTotalDuration),
        duration: Duration(milliseconds: secondTimingBaseDuration),
      ).tween(
        'up_container',
        Tween(begin: maxGradientHeight, end: 0.0),
      )
      ..scene(
        begin: Duration(milliseconds: firstTimingTotalDuration),
        duration: Duration(milliseconds: secondTimingBaseDuration),
      ).tween(
        'down_container',
        Tween(begin: 0.0, end: maxGradientHeight),
      )
      ..scene(
        begin: Duration(milliseconds: firstTimingTotalDuration),
        duration: Duration(milliseconds: secondTimingBaseDuration ~/ 2),
      ).tween(
        'up_gradient',
        Tween(begin: maxOpacity, end: 0.0),
      )
      ..scene(
        begin: Duration(milliseconds: firstTimingTotalDuration),
        duration: Duration(milliseconds: secondTimingBaseDuration),
      ).tween(
        'down_gradient',
        Tween(begin: 0.0, end: maxOpacity),
      );
  }

  Widget _buildContainer({
    required double height,
    required double maxHeight,
    required double opacity,
    required ImageProvider image,
    bool flip = false,
  }) {
    return RotatedBox(
      quarterTurns: flip ? 2 : 0,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          image: DecorationImage(
            opacity: opacity,
            image: image,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxGradientHeight = (containerHeight / 2) - dividerHeight;
    final tween = _calculateTween(maxGradientHeight: maxGradientHeight);

    return SizedBox(
      height: containerHeight,
      child: MirrorAnimationBuilder<Movie>(
        tween: tween,
        duration: tween.duration,
        builder: (context, value, child) {
          final upContainer = value.get('up_container') ?? 0.0;
          final downContainer = value.get('down_container') ?? 0.0;
          final upGradient = value.get('up_gradient') ?? 0.0;
          final downGradient = value.get('down_gradient') ?? 0.0;

          return Column(
            children: [
              _buildContainer(
                height: upContainer,
                maxHeight: maxGradientHeight,
                opacity: upGradient,
                flip: true,
                image: Assets.images.gradient.image().image,
              ),
              Container(
                height: dividerHeight,
                color: dividerColor,
              ),
              _buildContainer(
                height: downContainer,
                maxHeight: maxGradientHeight,
                opacity: downGradient,
                image: Assets.images.gradient.image().image,
              ),
            ],
          );
        },
      ),
    );
  }
}
