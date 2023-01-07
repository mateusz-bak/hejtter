import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:hejtter/models/posts_response.dart';
import 'package:hejtter/ui/post_screen/sliding_app_bar.dart';
import 'package:hejtter/utils/constants.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:path_provider/path_provider.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PictureFullScreen extends StatefulWidget {
  const PictureFullScreen({
    super.key,
    required this.imagesUrls,
  });

  final List<PostImage>? imagesUrls;

  @override
  State<PictureFullScreen> createState() => _PictureFullScreenState();
}

class _PictureFullScreenState extends State<PictureFullScreen>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  int currentIndex = 0;
  bool _appBarVisible = true;

  late final _appbarAnimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');

        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      print("Nie znaleziono ścieżki pobrań: $err");
    }
    return directory?.path;
  }

  void _downloadPicture() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    final downloadPath = await getDownloadPath();
    if (downloadPath == null) return;

    final imageUrl = widget.imagesUrls?[currentIndex].urls?.the1200X900;
    if (imageUrl == null) return;

    await FlutterDownloader.enqueue(
      url: imageUrl,
      savedDir: downloadPath,
      saveInPublicStorage: true,
      showNotification: true,
      openFileFromNotification: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: backgroundColor,
      appBar: SlidingAppBar(
        controller: _appbarAnimController,
        visible: _appBarVisible,
        child: AppBar(
          backgroundColor: backgroundColor,
          title: (widget.imagesUrls != null && widget.imagesUrls!.length > 1)
              ? Text(
                  'Obraz ${currentIndex + 1}/${widget.imagesUrls?.length}',
                )
              : const SizedBox(),
          actions: [
            IconButton(
              onPressed: _downloadPicture,
              icon: const Icon(Icons.download),
            )
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _appBarVisible = !_appBarVisible;
                });
              },
              child: PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                wantKeepAlive: true,
                builder: (BuildContext context, int index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: CachedNetworkImageProvider(
                      '${widget.imagesUrls?[index].urls?.the1200X900}',
                    ),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.contained * 3,
                  );
                },
                itemCount: widget.imagesUrls?.length ?? 0,
                loadingBuilder: (context, event) => Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                    color: Colors.white.withOpacity(0.5),
                    size: 32,
                  ),
                ),
                backgroundDecoration: const BoxDecoration(
                  color: backgroundColor,
                ),
                pageController: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
