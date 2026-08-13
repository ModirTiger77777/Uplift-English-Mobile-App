import 'package:flutter/material.dart';

class ZoomablePage extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;

  const ZoomablePage({
    Key? key,
    required this.child,
    this.minScale = 0.8,
    this.maxScale = 2.5,
  }) : super(key: key);

  @override
  State<ZoomablePage> createState() => _ZoomablePageState();
}

class _ZoomablePageState extends State<ZoomablePage> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (details) {
        setState(() {
          _scale =
              (_scale * details.scale).clamp(widget.minScale, widget.maxScale);
        });
      },
      onScaleEnd: (_) {
        // Optional: limit to avoid stuck zoom
        if (_scale < widget.minScale) _scale = widget.minScale;
        if (_scale > widget.maxScale) _scale = widget.maxScale;
      },
      child: Transform.scale(
        scale: _scale,
        alignment: Alignment.topCenter,
        child: widget.child,
      ),
    );
  }
}
