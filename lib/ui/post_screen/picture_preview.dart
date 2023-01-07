import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';

import 'package:hejtter/models/posts_response.dart';
import 'package:hejtter/ui/post_screen/picture_full_screen.dart';
import 'package:hejtter/utils/constants.dart';

class PicturePreview extends StatefulWidget {
  const PicturePreview({
    Key? key,
    required this.imageUrl,
    required this.imagesUrls,
    required this.multiplePics,
    required this.nsfw,
  }) : super(key: key);

  final String imageUrl;
  final List<PostImage>? imagesUrls;
  final bool multiplePics;
  final bool nsfw;

  @override
  State<PicturePreview> createState() => _PicturePreviewState();
}

class _PicturePreviewState extends State<PicturePreview> {
  bool _hideNsfw = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 5),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return PictureFullScreen(
              imagesUrls: widget.imagesUrls,
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
                  imageUrl: widget.imageUrl,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            widget.nsfw && _hideNsfw
                ? Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                        child: Container(
                          color: Colors.black.withOpacity(0.2),
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            widget.multiplePics
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: backgroundColor.withAlpha(150),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Icon(
                        Icons.filter,
                        size: 20,
                      ),
                    ),
                  )
                : const SizedBox(),
            widget.nsfw
                ? Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _hideNsfw = !_hideNsfw;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: backgroundColor.withAlpha(150),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Icon(
                            _hideNsfw ? Icons.visibility : Icons.visibility_off,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
