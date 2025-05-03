import 'package:fire_and_rain/rain/game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RainApp extends StatefulWidget {
  const RainApp({Key? key}) : super(key: key);

  @override
  State<RainApp> createState() => _RainAppState();
}

class _RainAppState extends State<RainApp> {
  final personKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(game: RainGame(personKey)),
            Positioned(
              left: 100 + 50,
              top: 200 + 38,
              child: ClipOval(
                key: personKey,
                clipper: UmbrellaClipper(),
                child: const CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 100,
                ),
              ),
            ),
            Positioned(
              left: 100,
              top: 200,
              child: SvgPicture.asset(
                "assets/person.svg",
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UmbrellaClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return const Rect.fromLTWH(0, 0, 200, 50);
  }

  @override
  bool shouldReclip(oldClipper) {
    return false;
  }
}
