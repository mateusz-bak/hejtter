import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hejtter/ui/post_screen/picture_full_screen.dart';

class PicturePreview extends StatelessWidget {
  const PicturePreview({
    Key? key,
    required this.imageUrl,
    this.clickable = true,
  }) : super(key: key);

  final String imageUrl;
  final bool clickable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 60,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: GestureDetector(
            onTap: clickable
                ? () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return PictureFullScreen(
                        imageUrl: imageUrl,
                      );
                    }));
                  }
                : null,
            child: CachedNetworkImage(
              fit: BoxFit.contain,
              imageUrl: imageUrl,
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }
}
