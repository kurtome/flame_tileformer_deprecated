import 'level.dart';
import 'package:flame_grab_bag/base_composed_component.dart';
import 'package:flame/position.dart';
import 'dart:math' as math;

class CollisionInfo {
  PhysicalComponent downCollision;
  PhysicalComponent leftCollision;
  PhysicalComponent rightCollision;

  bool get down => downCollision != null;
  bool get left => leftCollision != null;
  bool get right => rightCollision != null;

  void reset() {
    downCollision = null;
    leftCollision = null;
    rightCollision = null;
  }
}

enum Layer {
  // Solid object
  Obstacle,
  // Only solid on the top, can pass through sides and bottom
  Platform,
  // Can pass through
  Enemy,
  // Can pass through
  Item
}

abstract class PhysicalComponent extends BaseComposedComponent {
  /// Position object to store the x/y components
  final Position velocity = Position.empty();
  final CollisionInfo collisionInfo = CollisionInfo();
  bool static = false;
  final Set<Layer> layers = new Set();
  Level level;
  int health;

  /// How much gravity applies to this
  double gravityRate = 1;

  PhysicalComponent({this.health = 10});

  // Used to store collision during detection
  final List<PhysicalComponent> _tmpHits = [];

  void updatePhysics(double dt) {
    if (level.tileRenderSize == null) return;

    if (!static) {
      this.collisionDetection(dt);

      if (collisionInfo.down) {
        // Set the bottom of this to the top of the collision underneath
        this.velocity.y = 0;
        this.bottom = collisionInfo.downCollision.top;
      }
      if (collisionInfo.right) {
        this.velocity.x = 0;
        this.right = collisionInfo.rightCollision.left;
      }
      if (collisionInfo.left) {
        this.velocity.x = 0;
        this.left = collisionInfo.leftCollision.right;
      }

      // Velocity has been updated by collision detection, so it's ok to
      // apply it now
      x += velocity.x * dt;
      y += velocity.y * dt;
    }
  }

  void levelUpdated(Level level) {
    this.level = level;
  }

  void collisionDetection(double dt) {
    collisionInfo.reset();

    // The collision detection process work in a few steps:
    //
    // 1. Update x/y position as if there were no collisions (from velocity)
    // 2. Find all objects that collide with this in its new position
    // 3. Reset x/y position to original values
    // 4. Inspect the collisions to determine how far the x/y values can be updated
    // 5. Keep references to which collisions still apply, for game logic

    final originalX = x;
    final originalY = y;

    if (velocity.y > 0) {
      final originalBottom = bottom;
      // moving down
      y += velocity.y * dt;

      this.calculateHits((c) {
        return (c.layers.contains(Layer.Obstacle) ||
                c.layers.contains(Layer.Platform)) &&
            c.top <= this.bottom &&
            c.bottom >= this.bottom &&
            originalBottom <= c.top;
      });
      y = originalY;

      if (_tmpHits.isNotEmpty) {
        _tmpHits.sort((a, b) => a.top.compareTo(b.top));
        PhysicalComponent firstBottomHit = _tmpHits.first;
        collisionInfo.downCollision = firstBottomHit;
      }
    }

    if (velocity.x > 0) {
      // moving right
      x += velocity.x * dt;
      this.calculateHits((c) {
        return c.layers.contains(Layer.Obstacle) &&
            c.left <= this.right &&
            c.right >= this.right;
      });
      x = originalX;

      if (_tmpHits.isNotEmpty) {
        _tmpHits.sort((a, b) => a.left.compareTo(b.left));
        PhysicalComponent firstRightHit = _tmpHits.first;
        collisionInfo.rightCollision = firstRightHit;
      }
    }
    if (velocity.x < 0) {
      // moving left
      x += velocity.x * dt;
      this.calculateHits((c) {
        return c.layers.contains(Layer.Obstacle) &&
            c.left <= this.left &&
            c.right >= this.left;
      });
      x = originalX;

      if (_tmpHits.isNotEmpty) {
        _tmpHits.sort((a, b) => b.right.compareTo(a.right));
        PhysicalComponent firstLeftHit = _tmpHits.first;
        collisionInfo.leftCollision = firstLeftHit;
      }
    }
  }

  void calculateHits(bool Function(PhysicalComponent) filter) {
    _tmpHits.clear();

    // Find the edges of the map
    final maxXTile = level.map.layer.length - 1;
    final maxYTile = level.map.layer[0].length - 1;

    // Find the edges of this phyical component, in tile space
    final leftTile = math.max(0, tileLeft - 2);
    final rightTile = math.min(maxXTile, tileRight + 2);
    final topTile = math.max(0, tileTop - 2);
    final bottomTile = math.min(maxYTile, tileBottom + 2);

    for (int j = leftTile; j <= rightTile; j++) {
      for (int i = topTile; i <= bottomTile; i++) {
        final tile = level.map.layer[j][i];
        if (tile != null && intersects(tile) && filter(tile)) {
          _tmpHits.add(tile);
        }
      }
    }
  }

  bool intersects(PhysicalComponent b) {
    // This works by checking if the distance between the objects is less than their
    // combined width (meaning they must overlap)
    return ((this.centerX - b.centerX).abs() * 2 <= (this.width + b.width)) &&
        ((this.centerY - b.centerY).abs() * 2 <= (this.height + b.height));
  }

  double get left {
    return this.x;
  }

  set left(double newLeft) {
    this.x = newLeft;
  }

  double get right {
    return this.x + this.width;
  }

  set right(double newRight) {
    this.x = newRight - this.width;
  }

  double get top {
    return this.y;
  }

  double get bottom {
    return this.y + this.height;
  }

  set bottom(double newBottom) {
    this.y = newBottom - this.height;
  }

  int get tileLeft {
    return (left / level.tileRenderSize).floor();
  }

  int get tileRight {
    return (right / level.tileRenderSize).ceil();
  }

  int get tileTop {
    return (top / level.tileRenderSize).floor();
  }

  int get tileBottom {
    return (bottom / level.tileRenderSize).ceil();
  }

  double get centerX {
    return this.x + (this.width / 2);
  }

  double get centerY {
    return this.y + (this.height / 2);
  }
}
