import 'dart:math';

import 'package:animation_tuts/animated_prompt.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const App(),
    );
  }
}

class FlipContainer extends StatefulWidget {
  const FlipContainer({super.key});

  @override
  State<FlipContainer> createState() => _FlipContainerState();
}

class _FlipContainerState extends State<FlipContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    animationController.forward();
    animationController.repeat();

    animation = Tween<double>(begin: 0, end: 2 * pi).animate(
      animationController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(animation.value),
                child: Container(
                  height: 200,
                  width: 200,
                  color: Colors.deepPurple,
                ),
              );
            }),
      ),
    );
  }
}

class CircleChainedAnimation extends StatefulWidget {
  const CircleChainedAnimation({super.key});

  @override
  State<CircleChainedAnimation> createState() => _CircleChainedAnimationState();
}

class _CircleChainedAnimationState extends State<CircleChainedAnimation>
    with TickerProviderStateMixin {
  late AnimationController rotationController;
  late AnimationController flipController;

  late Animation<double> rotationAnimation;
  late Animation<double> flipAnimation;

  @override
  void initState() {
    super.initState();

    rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    flipController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    rotationAnimation = Tween<double>(begin: 0, end: (-pi / 2)).animate(
      CurvedAnimation(
        parent: flipController,
        curve: Curves.bounceOut,
      ),
    );

    flipAnimation = Tween<double>(
      begin: 0,
      end: pi,
    ).animate(
      CurvedAnimation(
        parent: rotationController,
        curve: Curves.bounceOut,
      ),
    );

    flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        rotationAnimation = Tween<double>(
                begin: rotationAnimation.value,
                end: rotationAnimation.value + (-pi / 2))
            .animate(
          CurvedAnimation(
            parent: flipController,
            curve: Curves.bounceOut,
          ),
        );

        rotationController
          ..reset()
          ..forward();
      }
    });

    rotationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        flipAnimation = Tween<double>(
          begin: flipAnimation.value,
          end: flipAnimation.value + pi,
        ).animate(
          CurvedAnimation(
            parent: rotationController,
            curve: Curves.bounceOut,
          ),
        );

        flipController
          ..reset()
          ..forward();
      }
    });

    rotationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
            animation: rotationController,
            builder: (context, _) {
              return AnimatedBuilder(
                  animation: flipController,
                  builder: (context, _) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateZ(rotationAnimation.value)
                        ..rotateY(flipAnimation.value),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipPath(
                            clipper: const HalfCircleClipper(
                              circleSide: CircleSide.left,
                            ),
                            child: Container(
                              height: 150,
                              width: 150,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          ClipPath(
                            clipper: const HalfCircleClipper(
                              circleSide: CircleSide.right,
                            ),
                            child: Container(
                              height: 150,
                              width: 150,
                              decoration: const BoxDecoration(
                                color: Colors.yellow,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            }),
      ),
    );
  }
}

enum CircleSide {
  left,
  right,
}

extension ToPath on CircleSide {
  Path toPath(Size size) {
    final path = Path();

    late Offset offset;
    late bool clockwise;

    switch (this) {
      case CircleSide.left:
        path.moveTo(size.width, 0);
        offset = Offset(size.width, size.height);
        clockwise = false;
        break;
      case CircleSide.right:
        offset = Offset(0, size.height);
        clockwise = true;
        break;
    }
    path.arcToPoint(
      offset,
      radius: Radius.elliptical(size.width / 2, size.height / 2),
      clockwise: clockwise,
    );

    path.close();
    return path;
  }
}

class HalfCircleClipper extends CustomClipper<Path> {
  final CircleSide circleSide;

  const HalfCircleClipper({
    required this.circleSide,
  });

  @override
  Path getClip(Size size) {
    return circleSide.toPath(size);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    throw true;
  }
}

class ThreeDAnimation extends StatefulWidget {
  const ThreeDAnimation({super.key});

  @override
  State<ThreeDAnimation> createState() => _ThreeDAnimationState();
}

class _ThreeDAnimationState extends State<ThreeDAnimation>
    with TickerProviderStateMixin {
  late AnimationController xController;
  late AnimationController yController;
  late AnimationController zController;

  late Tween<double> animation;

  double widthAndHeight = 150;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    xController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    yController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    zController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    animation = Tween<double>(begin: 0, end: 2 * pi);

    xController.forward();
    yController.forward();
    zController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            xController,
            yController,
            zController,
          ]),
          builder: (_, __) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..rotateX(animation.evaluate(xController))
                ..rotateY(animation.evaluate(yController))
                ..rotateZ(animation.evaluate(zController)),
              child: Stack(
                children: [
                  // back
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translate(Vector3(0, 0, -widthAndHeight)),
                    child: Container(
                      color: Colors.purple,
                      width: widthAndHeight,
                      height: widthAndHeight,
                    ),
                  ),
                  // left side
                  Transform(
                    alignment: Alignment.centerLeft,
                    transform: Matrix4.identity()..rotateY(pi / 2.0),
                    child: Container(
                      color: Colors.red,
                      width: widthAndHeight,
                      height: widthAndHeight,
                    ),
                  ),
                  // left side
                  Transform(
                    alignment: Alignment.centerRight,
                    transform: Matrix4.identity()..rotateY(-pi / 2.0),
                    child: Container(
                      color: Colors.blue,
                      width: widthAndHeight,
                      height: widthAndHeight,
                    ),
                  ),
                  // front
                  Container(
                    color: Colors.green,
                    width: widthAndHeight,
                    height: widthAndHeight,
                  ),
                  // top side
                  Transform(
                    alignment: Alignment.topCenter,
                    transform: Matrix4.identity()..rotateX(-pi / 2.0),
                    child: Container(
                      color: Colors.orange,
                      width: widthAndHeight,
                      height: widthAndHeight,
                    ),
                  ),
                  // bottom side
                  Transform(
                    alignment: Alignment.bottomCenter,
                    transform: Matrix4.identity()..rotateX(pi / 2.0),
                    child: Container(
                      color: Colors.brown,
                      width: widthAndHeight,
                      height: widthAndHeight,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class TweenMultiColorCircle extends StatefulWidget {
  const TweenMultiColorCircle({super.key});

  @override
  State<TweenMultiColorCircle> createState() => _TweenMultiColorCircleState();
}

class _TweenMultiColorCircleState extends State<TweenMultiColorCircle> {
  Color color = getRandomColor();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ClipPath(
          clipper: CircleCliper(),
          child: TweenAnimationBuilder(
            tween: ColorTween(
              begin: getRandomColor(),
              end: color,
            ),
            duration: const Duration(seconds: 1),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              color: Colors.red,
            ),
            builder: (context, value, child) {
              return ColorFiltered(
                colorFilter: ColorFilter.mode(
                  value!,
                  BlendMode.srcATop,
                ),
                child: child,
              );
            },
            onEnd: () {
              setState(() {
                color = getRandomColor();
              });
            },
          ),
        ),
      ),
    );
  }
}

class CircleCliper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );

    path.addOval(rect);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}

Color getRandomColor() => Color(
      0xFF000000 +
          Random().nextInt(
            0x00FFFFFF,
          ),
    );

class ShapeMaker extends StatefulWidget {
  const ShapeMaker({super.key});

  @override
  State<ShapeMaker> createState() => _ShapeMakerState();
}

class _ShapeMakerState extends State<ShapeMaker> with TickerProviderStateMixin {
  late AnimationController sideAnimationControlller;
  late Animation<int> sideAnimation;

  late AnimationController radiusController;
  late Animation<double> radiusAnimation;

  late AnimationController rotationController;
  late Animation<double> rotationAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    sideAnimationControlller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    sideAnimation = IntTween(
      begin: 3,
      end: 10,
    ).animate(sideAnimationControlller);

    radiusController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    radiusAnimation = Tween<double>(begin: 30, end: 400)
        .chain(
          CurveTween(curve: Curves.bounceInOut),
        )
        .animate(radiusController);

    rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    rotationAnimation =
        Tween<double>(begin: 0, end: 2 * pi).animate(rotationController);

    sideAnimationControlller
      ..forward()
      ..repeat(reverse: true);

    radiusController
      ..forward()
      ..repeat(reverse: true);

    rotationController
      ..forward()
      ..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
            animation: Listenable.merge([
              sideAnimationControlller,
              radiusController,
              rotationController,
            ]),
            builder: (_, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateX(rotationAnimation.value)
                  ..rotateY(rotationAnimation.value)
                  ..rotateZ(rotationAnimation.value),
                child: CustomPaint(
                  painter: Polygon(
                    sides: sideAnimation.value,
                  ),
                  child: SizedBox(
                    height: radiusAnimation.value,
                    width: radiusAnimation.value,
                  ),
                ),
              );
            }),
      ),
    );
  }
}

class Polygon extends CustomPainter {
  final int sides;

  Polygon({
    required this.sides,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    final Path path = Path();

    final Offset center = Offset(size.width / 2, size.height / 2);

    final double eachAngle = (2 * pi) / sides;

    final List<double> angles =
        List.generate(sides, (index) => eachAngle * index);

    final double radius = size.width / 2;

    /*
     To know x and y value on circle circumference
    x = center.x + radius * cos(angle)
    y = center.y + radius * sin(angle)
    */

    path.moveTo(
      center.dx + radius * cos(0),
      center.dy + radius * sin(0),
    );

    for (double currentAngle in angles) {
      path.lineTo(
        center.dx + radius * cos(currentAngle),
        center.dy + radius * sin(currentAngle),
      );
    }

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is Polygon && oldDelegate.sides != sides;
  }
}
