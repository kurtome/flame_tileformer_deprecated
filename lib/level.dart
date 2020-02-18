import 'package:flame_grab_bag/base_composed_component.dart';
import 'phyiscal_component.dart';
import 'tile.dart';
import 'tile_map.dart';
import 'package:flame/components/component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'dart:math' as math;

/// The level and it's corresponding tilemap
abstract class Level extends BaseComposedComponent {
  final TileMap map;
  final List<PhysicalComponent> physicals = [];
  final Size size;
  double tileRenderSize = 8;
  double gravity = 0;
  double maxVelocity = 0;

  /// The number of tiles that should fit across the screen horizontally.
  /// This takes precedences over [yScreenTiles]
  int xScreenTiles;

  /// The number of tiles that should fit across the screen vertically
  int yScreenTiles;

  Level(this.map, this.size,
      {this.tileRenderSize = 48, this.xScreenTiles, this.yScreenTiles}) {
    if (this.xScreenTiles != null) {
      this.tileRenderSize = size.width / this.xScreenTiles;
    } else if (this.yScreenTiles != null) {
      this.tileRenderSize = size.height / this.yScreenTiles;
    }

    gravity = tileRenderSize * 32;
    maxVelocity = tileRenderSize * 20;

    this.physicals.forEach((p) => p.levelUpdated(this));
    map.levelUpdated(this);
  }

  @override
  void add(Component c) {
    if (c is PhysicalComponent) {
      physicals.add(c);
      c.levelUpdated(this);
    }
    super.add(c);
  }

  void setTileAt(Tile tile, int x, int y) {
    // add(tile);
    map.setTileAt(tile, tileRenderSize, x, y);
    physicals.add(tile);
    tile.levelUpdated(this);
  }

  @override
  void update(double dt) {
    double gAccel = gravity * dt;
    physicals.forEach((physical) {
      final y = physical.velocity.y;
      final desiredVelocity = (gAccel * physical.gravityRate) + y;
      physical.velocity.y = math.min(desiredVelocity, maxVelocity);
    });
    super.update(dt);
    map.update(dt);
    physicals.removeWhere((c) => c.destroy());
  }

  @override
  void render(Canvas c) {
    map.render(c);
    super.render(c);
  }

  @override
  Rect toRect() => Rect.zero;

  bool isOutside(PhysicalComponent other) {
    if (other.tileRight < 0 || other.tileLeft > this.map.width) {
      return true;
    }
    if (other.tileBottom < 0 || other.tileTop > this.map.height) {
      return true;
    }
    return false;
  }

  bool isInside(PhysicalComponent other) => !isOutside(other);

  double get screenWidth {
    return map.width * tileRenderSize;
  }

  double get screenHeight {
    return map.height * tileRenderSize;
  }
}
