import 'level.dart';
import 'tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class TileMap {
  // Row / column grid of tiles
  List<List<Tile>> layer = [[]];
  Level level;

  TileMap(int width, int height) {
    // Create a [width x height] grid
    layer = List.generate(width, (i) => List(height));
  }

  int get width {
    return layer.length;
  }

  int get height {
    return layer[0].length;
  }

  void removeTileAt(int x, int y) {
    layer[x][y] = null;
  }

  void setTileAt(Tile tile, double tileRenderSize, int x, int y) {
    layer[x][y] = tile;
    if (tileRenderSize != null) {
      tile.setTileSizeAndPosition(tileRenderSize, y, x);
    }
  }

  void update(double dt) {
    _forEachTile((tile, row, col) {
      if (tile.destroy()) {
        removeTileAt(col, row);
      } else {
        tile.update(dt);
      }
    });
  }

  void render(Canvas canvas) {
    _forEachTile((tile, row, col) {
      tile.render(canvas);
    });
  }

  void levelUpdated(Level level) {
    this.level = level;
    double tileRenderSize = level.tileRenderSize;
    _forEachTile((tile, row, col) {
      tile.levelUpdated(level);
      tile.setTileSizeAndPosition(tileRenderSize, row, col);
    });
  }

  void _forEachTile(Function(Tile, int, int) block) {
    for (int c = 0; c < layer.length; c++) {
      final column = layer[c];
      for (int r = 0; r < column.length; r++) {
        final tile = column[r];
        if (tile != null) {
          block(tile, r, c);
        }
      }
    }
  }
}
