import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';

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
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

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

  _sharePicture() async {
    final imageUrl = widget.imagesUrls?[currentIndex].urls?.the1200X900;
    if (imageUrl == null) return;

    final downloadPath = await getApplicationDocumentsDirectory();

    final imageName = imageUrl.split('/').last;

    http.get(Uri.parse(imageUrl)).then((response) {
      Uint8List bodyBytes = response.bodyBytes;
      File(path.join(downloadPath.path, imageName)).writeAsBytesSync(bodyBytes);

      Share.shareXFiles([XFile(path.join(downloadPath.path, imageName))]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: SlidingAppBar(
        controller: _appbarAnimController,
        visible: _appBarVisible,
        child: AppBar(
          title: (widget.imagesUrls != null && widget.imagesUrls!.length > 1)
              ? Text(
                  'Obraz ${currentIndex + 1}/${widget.imagesUrls?.length}',
                  style: const TextStyle(fontSize: 20),
                )
              : const SizedBox(),
          actions: [
            IconButton(
              onPressed: _sharePicture,
              icon: const Icon(Icons.share),
            ),
            IconButton(
              onPressed: _downloadPicture,
              icon: const Icon(Icons.download),
            ),
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
                backgroundDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
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
