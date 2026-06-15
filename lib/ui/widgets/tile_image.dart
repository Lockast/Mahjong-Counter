import 'package:flutter/material.dart';

import '../../core/models/tile.dart';

/// Displays a Mahjong tile image, falling back to a placeholder if the
/// asset is missing.
class TileImage extends StatelessWidget {
  const TileImage({
    super.key,
    required this.tile,
    this.size = 48,
    this.selected = false,
    this.exposed = false,
    this.onTap,
  });

  final Tile tile;
  final double size;
  final bool selected;
  final bool exposed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      tile.assetPath,
      width: size,
      height: size * 1.4,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _Placeholder(tile: tile, size: size),
    );

    if (selected) {
      image = Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: exposed
                ? Colors.orange.shade600
                : Theme.of(context).colorScheme.primary,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: image,
      );
    }

    if (onTap != null) {
      image = GestureDetector(onTap: onTap, child: image);
    }

    return image;
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.tile, required this.size});
  final Tile tile;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.4,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          tile.label.substring(0, 1),
          style: TextStyle(
            fontSize: size * 0.35,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
