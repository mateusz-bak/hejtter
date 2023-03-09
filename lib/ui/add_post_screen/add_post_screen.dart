import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hejtter/models/communities_response.dart';
import 'package:hejtter/models/photo_to_upload.dart';
import 'package:hejtter/models/poll_to_be_created.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/add_post_screen/widgets/widgets.dart';
import 'package:hejtter/ui/home_screen/widgets/widgets.dart';
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
    PollToBeCreated?,
  ) addPost;

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  bool _isPostAdding = false;
  bool _isNsfw = false;
  bool _addPoll = false;

  bool _isContentMinLength = false;
  bool _isTitleMinLength = false;
  bool _isUrlMinLength = false;
  bool _isPollQuestionMinLength = false;
  bool _isFirstPollMinLength = false;
  bool _isSecondPollMinLength = false;
  bool _isThirdPollMinLength = false;
  bool _isFourthPollMinLength = false;
  bool _isFifthPollMinLength = false;

  final _textController = TextEditingController();
  final _linkController = TextEditingController();
  final _titleController = TextEditingController();

  final _communitiesController = TextEditingController();

  final _pollQuestionController = TextEditingController();
  final _firstPollAnswerController = TextEditingController();
  final _secondPollAnswerController = TextEditingController();
  final _thirdPollAnswerController = TextEditingController();
  final _fourthPollAnswerController = TextEditingController();
  final _fifthPollAnswerController = TextEditingController();

  int _numberOfPollAnswers = 2;

  List<PhotoToUpload> _postPhotos = List.empty(growable: true);
  var _selectedPostType = PostType.DISCUSSION;

  Community? _chosenCommunity;

  _startAddingPost() async {
    setState(() {
      _isPostAdding = true;
    });

    final pollOptions = <OptionOfPollToBeCreated>[
      OptionOfPollToBeCreated(title: _firstPollAnswerController.text),
      OptionOfPollToBeCreated(title: _secondPollAnswerController.text),
    ];

    if (_numberOfPollAnswers > 2) {
      pollOptions.add(
        OptionOfPollToBeCreated(title: _thirdPollAnswerController.text),
      );
    }
    if (_numberOfPollAnswers > 3) {
      pollOptions.add(
        OptionOfPollToBeCreated(title: _fourthPollAnswerController.text),
      );
    }
    if (_numberOfPollAnswers > 4) {
      pollOptions.add(
        OptionOfPollToBeCreated(title: _fifthPollAnswerController.text),
      );
    }

    final poll = PollToBeCreated(
      title: _pollQuestionController.text,
      options: pollOptions,
    );

    final exp = RegExp(r'(#+[a-zA-Z0-9(_)]{1,})');
    final String content = _textController.text.replaceAllMapped(
      exp,
      (match) => "[${match[0]}](/tag/${match[0]?.replaceAll('#', '')})",
    );

    final location = await widget.addPost(
      content,
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
      _addPoll && _selectedPostType == PostType.DISCUSSION ? poll : null,
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
        if (_addPoll) {
          if (!_isPollQuestionMinLength ||
              !_isFirstPollMinLength ||
              !_isSecondPollMinLength) {
            return null;
          }

          if (_numberOfPollAnswers == 3 && !_isThirdPollMinLength) {
            return null;
          }
          if (_numberOfPollAnswers == 4 &&
              (!_isThirdPollMinLength || !_isFourthPollMinLength)) {
            return null;
          }
          if (_numberOfPollAnswers == 5 &&
              (!_isThirdPollMinLength ||
                  !_isFourthPollMinLength ||
                  !_isFifthPollMinLength)) {
            return null;
          }
        }

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
      _linkController.text.length > 2
          ? setState(() {
              _isUrlMinLength = true;
            })
          : setState(() {
              _isUrlMinLength = false;
            });
    });

    _pollQuestionController.addListener(() {
      _pollQuestionController.text.isNotEmpty
          ? setState(() {
              _isPollQuestionMinLength = true;
            })
          : setState(() {
              _isPollQuestionMinLength = false;
            });
    });

    _firstPollAnswerController.addListener(() {
      _firstPollAnswerController.text.isNotEmpty
          ? setState(() {
              _isFirstPollMinLength = true;
            })
          : setState(() {
              _isFirstPollMinLength = false;
            });
    });

    _secondPollAnswerController.addListener(() {
      _secondPollAnswerController.text.isNotEmpty
          ? setState(() {
              _isSecondPollMinLength = true;
            })
          : setState(() {
              _isSecondPollMinLength = false;
            });
    });

    _thirdPollAnswerController.addListener(() {
      _thirdPollAnswerController.text.isNotEmpty
          ? setState(() {
              _isThirdPollMinLength = true;
            })
          : setState(() {
              _isThirdPollMinLength = false;
            });
    });

    _fourthPollAnswerController.addListener(() {
      _fourthPollAnswerController.text.isNotEmpty
          ? setState(() {
              _isFourthPollMinLength = true;
            })
          : setState(() {
              _isFourthPollMinLength = false;
            });
    });

    _fifthPollAnswerController.addListener(() {
      _fifthPollAnswerController.text.isNotEmpty
          ? setState(() {
              _isFifthPollMinLength = true;
            })
          : setState(() {
              _isFifthPollMinLength = false;
            });
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
              _buildPoll(),
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

  Widget _buildPoll() {
    if (!_addPoll || _selectedPostType != PostType.DISCUSSION) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Ankieta:',
          style: TextStyle(fontSize: 18),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: backgroundSecondaryColor,
              border: Border.all(color: dividerColor, width: 1),
            ),
            child: Column(
              children: [
                TextField(
                  autofocus: true,
                  controller: _pollQuestionController,
                  expands: false,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Pytanie do ankiety',
                  ),
                ),
                ..._buildPollAnswers(),
                ..._buildPollOptionButtons(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPollAnswers() {
    return [
      PollAnswer(
        textController: _firstPollAnswerController,
        number: '1',
      ),
      PollAnswer(
        textController: _secondPollAnswerController,
        number: '2',
      ),
      _numberOfPollAnswers > 2
          ? PollAnswer(
              textController: _thirdPollAnswerController,
              number: '3',
            )
          : const SizedBox(),
      _numberOfPollAnswers > 3
          ? PollAnswer(
              textController: _fourthPollAnswerController,
              number: '4',
            )
          : const SizedBox(),
      _numberOfPollAnswers > 4
          ? PollAnswer(
              textController: _fifthPollAnswerController,
              number: '5',
            )
          : const SizedBox(),
    ];
  }

  List<Widget> _buildPollOptionButtons() {
    return [
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _numberOfPollAnswers > 2
                  ? () {
                      setState(() {
                        _numberOfPollAnswers = _numberOfPollAnswers - 1;
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: onPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(width: 1, color: dividerColor),
                ),
              ),
              child: const Icon(Icons.exposure_minus_1),
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: ElevatedButton(
              onPressed: _numberOfPollAnswers < 5
                  ? () {
                      setState(() {
                        _numberOfPollAnswers = _numberOfPollAnswers + 1;
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: onPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(width: 1, color: dividerColor),
                ),
              ),
              child: const Icon(Icons.plus_one),
            ),
          ),
        ],
      ),
    ];
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
        onPressed: () {
          setState(() {
            _addPoll = !_addPoll;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _addPoll ? boltColor : primaryColor,
          foregroundColor: _addPoll ? Colors.black : onPrimaryColor,
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
