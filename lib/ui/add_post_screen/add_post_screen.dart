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
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
    PostType,
    String?,
    String?,
  ) addPost;

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  bool _isPostAdding = false;
  bool _isNsfw = false;
  bool _isContentMinLength = false;
  bool _isTitleMinLength = false;
  bool _isUrlMinLength = false;

  final _textController = TextEditingController();
  final _linkController = TextEditingController();
  final _titleController = TextEditingController();

  final _communitiesController = TextEditingController();

  List<PhotoToUpload> _postPhotos = List.empty(growable: true);
  var _selectedPostType = PostType.DISCUSSION;

  Community? _chosenCommunity;

  _startAddingPost() async {
    setState(() {
      _isPostAdding = true;
    });

    final location = await widget.addPost(
      _textController.text,
      _isNsfw,
      _chosenCommunity?.slug ?? 'Dyskusje',
      ((_selectedPostType == PostType.ARTICLE ||
                  _selectedPostType == PostType.LINK) &&
              _postPhotos.isNotEmpty)
          ? [_postPhotos[0]]
          : _postPhotos,
      _selectedPostType,
      _titleController.text,
      _linkController.text,
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
          toolbarTitle: 'Przytnij zdjęcie',
          toolbarColor: backgroundColor,
          statusBarColor: backgroundColor,
          toolbarWidgetColor: Colors.white,
          backgroundColor: backgroundColor,
          cropGridColor: dividerColor,
          activeControlsWidgetColor: boltColor,
          cropFrameColor: dividerColor,
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

  Function()? _validatePost() {
    if (_selectedPostType == PostType.DISCUSSION) {
      if (_isPostAdding || _chosenCommunity == null || !_isContentMinLength) {
        return null;
      } else {
        return _startAddingPost;
      }
    }

    if (_selectedPostType == PostType.ARTICLE) {
      if (_isPostAdding ||
          _chosenCommunity == null ||
          !_isContentMinLength ||
          !_isTitleMinLength) {
        return null;
      } else {
        return _startAddingPost;
      }
    }

    if (_selectedPostType == PostType.LINK) {
      if (_isPostAdding ||
          _chosenCommunity == null ||
          !_isContentMinLength ||
          !_isTitleMinLength ||
          !_isUrlMinLength) {
        return null;
      } else {
        return _startAddingPost;
      }
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (_textController.text.length > 2) {
        setState(() {
          _isContentMinLength = true;
        });
      } else {
        setState(() {
          _isContentMinLength = false;
        });
      }
    });
    _titleController.addListener(() {
      if (_titleController.text.length > 2) {
        setState(() {
          _isTitleMinLength = true;
        });
      } else {
        setState(() {
          _isTitleMinLength = false;
        });
      }
    });
    _linkController.addListener(() {
      if (_linkController.text.length > 2) {
        setState(() {
          _isUrlMinLength = true;
        });
      } else {
        setState(() {
          _isUrlMinLength = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: backgroundColor,
        title: const Text(
          'Dodawanie wpisu',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPostTypeChooser(),
              _buildPostUrl(),
              _buildPostTitle(),
              const SizedBox(height: 20),
              _buildPostContent(),
              const SizedBox(height: 10),
              _buildPicturePreviews(),
              const SizedBox(height: 10),
              _buildSearchCommunities(),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildNsfwBox(),
                  const SizedBox(width: 20),
                  const Spacer(),
                  _buildPictureAdding(),
                  _buildPollAdding(),
                ],
              ),
              const SizedBox(height: 10),
              _buildPublishButton(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostUrl() {
    if (_selectedPostType != PostType.LINK) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          Expanded(
              child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: backgroundSecondaryColor,
              border: Border.all(color: dividerColor, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Scrollbar(
                child: TextField(
                  autofocus: true,
                  controller: _linkController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 1,
                  minLines: 1,
                  expands: false,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Dodaj link',
                  ),
                ),
              ),
            ),
          ))
        ],
      ),
    );
  }

  Widget _buildPostTitle() {
    if (_selectedPostType != PostType.LINK &&
        _selectedPostType != PostType.ARTICLE) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          Expanded(
              child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: backgroundSecondaryColor,
              border: Border.all(color: dividerColor, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Scrollbar(
                child: TextField(
                  autofocus: true,
                  controller: _titleController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 1,
                  minLines: 1,
                  expands: false,
                  maxLength: 140,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Wpisz tytuł',
                  ),
                ),
              ),
            ),
          ))
        ],
      ),
    );
  }

  Row _buildPublishButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _validatePost(),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: onPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(width: 1, color: dividerColor),
              ),
            ),
            child: _isPostAdding
                ? LoadingAnimationWidget.threeArchedCircle(
                    color: boltColor,
                    size: 20,
                  )
                : const Text('Opublikuj wpis'),
          ),
        ),
      ],
    );
  }

  Row _buildPostTypeChooser() {
    return Row(
      children: [
        Expanded(
          child: SegmentedButton<PostType>(
            selected: <PostType>{_selectedPostType},
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return primaryColor;
                  }
                  return backgroundColor;
                },
              ),
            ),
            segments: const [
              ButtonSegment(
                value: PostType.DISCUSSION,
                label: FittedBox(child: Text('Dyskusja')),
              ),
              ButtonSegment(
                value: PostType.ARTICLE,
                label: FittedBox(child: Text('Artykuł')),
              ),
              ButtonSegment(
                value: PostType.LINK,
                label: FittedBox(child: Text('Znalezisko')),
              ),
            ],
            onSelectionChanged: (Set<PostType> newSelection) {
              setState(() {
                _selectedPostType = newSelection.first;
              });
            },
          ),
        ),
      ],
    );
  }

  Container _buildPostContent() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: backgroundSecondaryColor,
        border: Border.all(color: dividerColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Scrollbar(
          child: TextField(
            autofocus: true,
            controller: _textController,
            keyboardType: TextInputType.multiline,
            maxLines: 15,
            minLines: 5,
            expands: false,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration.collapsed(
              hintText: 'Wpisz treść',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPicturePreviews() {
    final widgets = List<Widget>.empty(growable: true);

    if ((_selectedPostType == PostType.ARTICLE ||
            _selectedPostType == PostType.LINK) &&
        _postPhotos.isNotEmpty) {
      if (_postPhotos[0].uuid != null) {
        widgets.add(
          _buildUploadedPicturePreview(_postPhotos[0]),
        );
      } else {
        widgets.add(
          _buildUploadingPicturePreview(),
        );
      }
    } else {
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
        child: LoadingAnimationWidget.threeArchedCircle(
          color: boltColor,
          size: 20,
        ),
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
    return ElevatedButton(
      onPressed: _loadPhotoFromStorage,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(width: 1, color: dividerColor),
        ),
      ),
      child: const Icon(Icons.image),
    );
  }

  Widget _buildPollAdding() {
    if (_selectedPostType != PostType.DISCUSSION) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: ElevatedButton(
        onPressed: _loadPhotoFromStorage,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(width: 1, color: dividerColor),
          ),
        ),
        child: const Icon(Icons.poll),
      ),
    );
  }

  Widget _buildNsfwBox() {
    return Row(
      children: [
        Switch(
          value: _isNsfw,
          activeColor: primaryColor,
          onChanged: (value) {
            setState(() {
              _isNsfw = value;
            });
          },
        ),
        const SizedBox(width: 5),
        const Text('Treść 18+'),
      ],
    );
  }

  Widget _buildSearchCommunities() {
    return Row(
      children: [
        Expanded(
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: dividerColor),
                borderRadius: BorderRadius.circular(10),
                color: backgroundSecondaryColor,
              ),
              child: Row(
                children: [
                  Expanded(
                    child:
                        Text(_chosenCommunity?.name ?? 'Wybierz społeczność'),
                  ),
                  const Icon(Icons.expand_more)
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
