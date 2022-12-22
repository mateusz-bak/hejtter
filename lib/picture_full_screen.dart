import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


class PictureFullScreen extends StatefulWidget {
  const PictureFullScreen({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  State<PictureFullScreen> createState() => _PictureFullScreenState();
}

class _PictureFullScreenState extends State<PictureFullScreen> {
  TransformationController controllerT = TransformationController();
  dynamic initialControllerValue = null;

  @override
  void dispose() {
    controllerT.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: GestureDetector(
              child: InteractiveViewer(
                transformationController: controllerT,
                minScale: 1.0,
                maxScale: 4.0,
                onInteractionStart: (details) {
                  initialControllerValue ??= controllerT.value;
                },
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                ),
              ),
              onDoubleTap: () {
                controllerT.value = initialControllerValue;
              },
            ),
          ),
        ],
      ),
    );
  }
}
