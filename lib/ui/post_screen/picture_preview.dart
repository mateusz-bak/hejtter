import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hejtter/ui/post_screen/picture_full_screen.dart';
import 'package:hejtter/utils/constants.dart';

class PicturePreview extends StatelessWidget {
  const PicturePreview({
    Key? key,
    required this.imageUrl,
    required this.multiplePics,
    required this.nsfw,
  }) : super(key: key);

  final String imageUrl;
  final bool multiplePics;
  final bool nsfw;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 5),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return PictureFullScreen(
              imageUrl: imageUrl,
            );
          }));
        },
        child: Stack(
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: imageUrl,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            nsfw
                ? Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          color: Colors.black.withOpacity(0.2),
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            multiplePics
                ? Padding(
                    padding: const EdgeInsets.all(7),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: backgroundColor.withAlpha(150),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.filter),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
