import 'package:flame/components/component.dart';
import 'package:flame/position.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

class Camera {
  final Position flameCamera;
  final Size screenSize;

  Camera(this.flameCamera, this.screenSize);

  double get left => flameCamera.x;
  set left(double x) => flameCamera.x = x;

  double get right => flameCamera.x + screenSize.width;
  set right(double x) => flameCamera.x = x - screenSize.width;

  double get top => flameCamera.y;
  set top(double y) => flameCamera.y = y;

  double get bottom => flameCamera.y + screenSize.height;
  set bottom(double y) => flameCamera.y = y - screenSize.height;

  double get width => screenSize.width;
  double get height => screenSize.height;
}

class CameraComponent extends Component {
  Camera camera;
  CameraStrategy strategy = CameraStrategy();

  CameraComponent(this.camera);

  @override
  void render(Canvas c) {}

  @override
  void update(double dt) {
    if (camera.screenSize == null) {
      return;
    }
    strategy.update(dt, camera);
  }

  // @override
  // void resize(Size size) {
  //   camera.resize(size);
  // }
}

class CameraStrategy {
  void update(double dt, Camera camera) {}
}
