import 'character.dart';
import 'phyiscal_component.dart';
import 'package:flame/animation.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/painting.dart';

class Tile extends Character {
  Sprite sprite;
  Animation animation;

  Tile(this.sprite, {Layer layer, this.animation}) {
    // this.sprite = SpriteComponent.fromSprite(width, height, sprite);

    if (layer != null) {
      layers.add(layer);
    }

    if (animation != null) {
      sprite = animation.getSprite();
    }

    this.static = true;
  }

  @override
  void render(Canvas c) {
    sprite.renderPosition(c, this.toPosition(), size: this.toSize());
  }

  @override
  void update(double dt) {
    if (animation != null) {
      animation.update(dt);
      sprite = animation.getSprite();
    }
  }

  Tile.obstacle(Sprite sprite) : this(sprite, layer: Layer.Obstacle);
  Tile.platform(Sprite sprite) : this(sprite, layer: Layer.Platform);

  void setTileSizeAndPosition(double size, int row, int column) {
    // + 1 here to fill in 1px gaps between tiles
    this.width = size + 1;
    this.height = size + 1;
    this.x = column * size;
    this.y = row * size;
  }
}
