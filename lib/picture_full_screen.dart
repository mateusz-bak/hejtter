import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hejtter/sliding_app_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PictureFullScreen extends StatefulWidget {
  const PictureFullScreen({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  State<PictureFullScreen> createState() => _PictureFullScreenState();
}

class _PictureFullScreenState extends State<PictureFullScreen>
    with SingleTickerProviderStateMixin {
  TransformationController controllerT = TransformationController();
  dynamic initialControllerValue = null;
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
      print("Cannot get download folder path: $err");
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

    await FlutterDownloader.enqueue(
      url: widget.imageUrl,
      savedDir: downloadPath,
      saveInPublicStorage: true,
      showNotification: true,
      openFileFromNotification: true,
    );
  }

  @override
  void dispose() {
    controllerT.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SlidingAppBar(
        controller: _appbarAnimController,
        visible: _appBarVisible,
        child: AppBar(
          actions: [
            IconButton(
              onPressed: _downloadPicture,
              icon: const Icon(Icons.download),
            )
          ],
        ),
      ),
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
              onTap: () => setState(() {
                _appBarVisible = !_appBarVisible;
              }),
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
