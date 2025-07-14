import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_cart_app/core/services/map_consts.dart';
import 'dart:ui' as ui;

import 'package:smart_cart_app/features/home/data/models/map_model_types.dart';
import 'package:smart_cart_app/features/home/data/models/map_search_product_model/map_search_product_model.dart';

class GridPainter extends CustomPainter {
  final List<List<int>> grid;
  final List<Geofence> geofences;
  final List<List<int>> path;
  final Coordinates userPosition;
  final MapSearchProductModel? selectedProduct;
  final ui.Image userIcon;
  final ui.Image productIcon;

  GridPainter({
    required this.grid,
    required this.geofences,
    required this.path,
    required this.userPosition,
    this.selectedProduct,
    required this.userIcon,
    required this.productIcon,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const cellSize = MapConstants.cellSize;
    final paint = Paint();

    // Draw grid
    for (var y = 0; y < grid.length; y++) {
      for (var x = 0; x < grid[y].length; x++) {
        paint
          ..color = grid[y][x] == 1 ? Colors.grey : Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawRect(
          Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize),
          paint,
        );
        // paint
        //   ..color = Colors.grey.shade300
        //   ..style = PaintingStyle.stroke
        //   ..strokeWidth = 1;
        // canvas.drawRect(Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize), paint);
      }
    }

    // // Draw geofences
    // for (var fence in geofences) {
    //   paint
    //     ..color = Colors.blue.withOpacity(0.2)
    //     ..style = PaintingStyle.fill;
    //   canvas.drawRect(
    //     Rect.fromLTWH(
    //       fence.bounds.minX * cellSize,
    //       fence.bounds.minY * cellSize,
    //       (fence.bounds.maxX - fence.bounds.minX + 1) * cellSize,
    //       (fence.bounds.maxY - fence.bounds.minY + 1) * cellSize,
    //     ),
    //     paint,
    //   );
    // }

    // Draw path
    if (path.isNotEmpty) {
      paint
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      for (var i = 0; i < path.length - 1; i++) {
        canvas.drawLine(
          Offset((path[i][0] + 0.5) * cellSize, (path[i][1] + 0.5) * cellSize),
          Offset(
            (path[i + 1][0] + 0.5) * cellSize,
            (path[i + 1][1] + 0.5) * cellSize,
          ),
          paint,
        );
      }
    }

    // Draw user position
    final userOffset = Offset(
      userPosition.x * cellSize + cellSize / 2,
      userPosition.y * cellSize + cellSize / 2,
    );
    final src = Rect.fromLTWH(
      0,
      0,
      userIcon.width.toDouble(),
      userIcon.height.toDouble(),
    );
    final dst = Rect.fromCenter(
      center: userOffset,
      width: cellSize * 3,
      height: cellSize * 3,
    );
    canvas.drawImageRect(userIcon, src, dst, paint);

    if (selectedProduct != null) {
      final productOffset = Offset(
        selectedProduct!.x! * cellSize + cellSize / 2,
        selectedProduct!.y! * cellSize + cellSize / 2,
      );
      final src = Rect.fromLTWH(
        0,
        0,
        productIcon.width.toDouble(),
        productIcon.height.toDouble(),
      );
      final dst = Rect.fromCenter(
        center: productOffset,
        width: cellSize * 3,
        height: cellSize * 3,
      );
      canvas.drawImageRect(productIcon, src, dst, paint);
    }

    paint
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    for (final ap in accessPoints) {
      canvas.drawCircle(
        Offset(ap.x * cellSize + cellSize / 2, ap.y * cellSize + cellSize / 2),
        cellSize / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

Future<ui.Image> loadImage(String assetPath) async {
  final data = await rootBundle.load(assetPath);
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  final frame = await codec.getNextFrame();
  return frame.image;
}
