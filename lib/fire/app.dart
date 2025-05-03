import 'dart:math';

import 'package:fire_and_rain/fire/game.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class FireApp extends StatefulWidget {
  const FireApp({Key? key}) : super(key: key);

  @override
  State<FireApp> createState() => _FireAppState();
}

class _FireAppState extends State<FireApp> {
  final buttonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(game: FireGame(buttonKey)),
            Positioned(
              left: 100,
              top: 400,
              child: ElevatedButton(
                key: buttonKey,
                onPressed: () {},
                child: const Text('Catch the fireball!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}