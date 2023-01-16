import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hejtter/models/communities_response.dart';
import 'package:hejtter/models/photo_to_upload.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/home_screen/communities_dialog.dart';
import 'package:hejtter/ui/post_screen/post_screen.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({
    Key? key,
    required this.addPost,
  }) : super(key: key);

  final Future<String?> Function(
    String,
    bool,
    String,
    List<PhotoToUpload>?,
  ) addPost;

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  bool _isPostAdding = false;
  bool _isNsfw = false;
  bool _isMinLength = false;
  final _textController = TextEditingController();
  final _communitiesController = TextEditingController();
  List<PhotoToUpload> _postPhotos = List.empty(growable: true);

  Community? _chosenCommunity;

  _startAddingPost() async {
    setState(() {
      _isPostAdding = true;
    });

    final location = await widget.addPost(
      _textController.text,
      _isNsfw,
      _chosenCommunity?.slug ?? 'Dyskusje',
      _postPhotos,
    );

    setState(() {
      _isPostAdding = false;
    });

    if (location != null && mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return PostScreen(
          slug: location,
        );
      }));
    }
  }

  void _loadPhotoFromStorage() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final photoXFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (photoXFile == null) return;

    final tmpCroppedPhoto = await ImageCropper().cropImage(
      maxWidth: 1024,
      maxHeight: 1024,
      sourcePath: photoXFile.path,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Edit cover',
          toolbarColor: Colors.black,
          statusBarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Colors.black87,
          cropGridColor: Colors.black87,
          activeControlsWidgetColor:
              (mounted) ? Theme.of(context).primaryColor : Colors.teal,
          cropFrameColor: Colors.black87,
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
      ],
    );

    if (tmpCroppedPhoto == null) return;

    final potoBytes = await tmpCroppedPhoto.readAsBytes();
    final updatedPostphotos = await _updatePhotoList(potoBytes);

    setState(() {
      _postPhotos = updatedPostphotos;
    });
  }

  Future<List<PhotoToUpload>> _updatePhotoList(Uint8List potoBytes) async {
    final position = _postPhotos.length + 1;

    var updatedPostphotos = _postPhotos;
    updatedPostphotos.add(PhotoToUpload(
      bytes: potoBytes,
      position: position,
    ));

    setState(() {
      _postPhotos = updatedPostphotos;
    });

    final uuid = await hejtoApi.createUpload(
      context: context,
      picture: potoBytes,
    );

    updatedPostphotos = _postPhotos;
    updatedPostphotos[updatedPostphotos.indexWhere(
      (element) => element.position == position,
    )] = PhotoToUpload(
      bytes: potoBytes,
      position: position,
      uuid: uuid,
    );

    return updatedPostphotos;
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (_textController.text.length > 2) {
        setState(() {
          _isMinLength = true;
        });
      } else {
        setState(() {
          _isMinLength = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj wpis'),
        backgroundColor: backgroundColor,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: Container(
        padding: const EdgeInsets.all(10),
        color: backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white.withAlpha(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Scrollbar(
                    child: TextField(
                      autofocus: true,
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      minLines: null,
                      expands: true,
                      decoration:
                          const InputDecoration.collapsed(hintText: null),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildNsfwBox(),
                  ],
                ),
                const SizedBox(width: 20),
                _buildSearchCommunities(),
                _buildPictureAdding(),
              ],
            ),
            _buildPicturePreviews(),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: primaryColor,
                    ),
                    onPressed: _isPostAdding ||
                            _chosenCommunity == null ||
                            !_isMinLength
                        ? null
                        : _startAddingPost,
                    child: _isPostAdding
                        ? const CircularProgressIndicator()
                        : const Text('Dodaj'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildPicturePreviews() {
    final widgets = List<Widget>.empty(growable: true);

    for (var photo in _postPhotos) {
      if (photo.uuid != null) {
        widgets.add(
          _buildUploadedPicturePreview(photo),
        );
      } else {
        widgets.add(
          _buildUploadingPicturePreview(),
        );
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: widgets),
    );
  }

  Container _buildUploadingPicturePreview() {
    return Container(
      padding: const EdgeInsets.only(right: 20),
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 32,
        height: 32,
        child: const CircularProgressIndicator(),
      ),
    );
  }

  Padding _buildUploadedPicturePreview(PhotoToUpload photo) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          final updatedPostPhotos = _postPhotos;

          updatedPostPhotos.removeWhere(
            (element) => element.uuid == photo.uuid,
          );

          final reorganizedPostPhotos = List<PhotoToUpload>.empty(
            growable: true,
          );

          var index = 1;
          for (var photo in updatedPostPhotos) {
            reorganizedPostPhotos.add(
              PhotoToUpload(
                bytes: photo.bytes,
                position: index,
                uuid: photo.uuid,
              ),
            );

            index++;
          }

          setState(() {
            _postPhotos = reorganizedPostPhotos;
          });
        },
        child: Image.memory(
          photo.bytes,
          width: 100,
          height: 100,
        ),
      ),
    );
  }

  Widget _buildPictureAdding() {
    return IconButton(
      onPressed: _loadPhotoFromStorage,
      icon: const Icon(Icons.image),
    );
  }

  Widget _buildNsfwBox() {
    return Row(
      children: [
        const Text('NSFW'),
        Switch(
          value: _isNsfw,
          activeColor: primaryColor,
          onChanged: (value) {
            setState(() {
              _isNsfw = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSearchCommunities() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return CommunitiesDialog(
                controller: _communitiesController,
                onCommunityPressed: (item) {
                  setState(() {
                    _chosenCommunity = item;
                    Navigator.of(context).pop();
                  });
                },
              );
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(_chosenCommunity?.name ?? 'Społeczność'),
        ),
      ),
    );
  }
}
