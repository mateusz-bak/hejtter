import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/models/posts_response.dart';
import 'package:hejtter/ui/post_screen/widgets.dart/widgets.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PicturePreview extends StatefulWidget {
  const PicturePreview({
    Key? key,
    required this.imageUrl,
    required this.imagesUrls,
    required this.multiplePics,
    required this.nsfw,
    this.height,
    this.width,
    this.openOnTap = true,
  }) : super(key: key);

  final String imageUrl;
  final List<PostImage>? imagesUrls;
  final bool multiplePics;
  final bool nsfw;
  final bool openOnTap;
  final double? height;
  final double? width;

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
        onTap: widget.openOnTap
            ? () {
                showModalBottomSheet(
                    useSafeArea: true,
                    isScrollControlled: true,
                    context: context,
                    builder: (_) {
                      return PictureFullScreen(
                        imagesUrls: widget.imagesUrls,
                      );
                    });
              }
            : null,
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 32,
                  maxHeight: 500,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: CachedNetworkImage(
                    fadeOutDuration: const Duration(milliseconds: 250),
                    placeholder: (context, url) {
                      return SizedBox(
                        height: 32,
                        width: 32,
                        child: Center(
                          child: LoadingAnimationWidget.threeArchedCircle(
                            color: boltColor,
                            size: 24,
                          ),
                        ),
                      );
                    },
                    height: widget.height,
                    width: widget.width,
                    fit: (widget.height == null && widget.width == null)
                        ? BoxFit.cover
                        : BoxFit.fitWidth,
                    imageUrl: widget.imageUrl,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
            ),
            widget.nsfw && _hideNsfw ? _buildNsfwBlur() : const SizedBox(),
            widget.multiplePics
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surface
                            .withAlpha(150),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Icon(
                        Icons.filter,
                        size: 20,
                      ),
                    ),
                  )
                : const SizedBox(),
            widget.nsfw ? _buildNsfwButton() : const SizedBox(),
          ],
        ),
      ),
    );
  }

  _buildNsfwBlur() {
    return BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
      if (state is ProfilePresentState) {
        if (!state.blurNsfw) {
          return const SizedBox();
        }
      }

      return Positioned.fill(
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
      );
    });
  }

  _buildNsfwButton() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfilePresentState) {
          if (!state.blurNsfw) {
            return const SizedBox();
          }
        }

        return Align(
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
                  color: Theme.of(context).colorScheme.surface.withAlpha(150),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  _hideNsfw ? Icons.visibility : Icons.visibility_off,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
