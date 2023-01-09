import 'package:flutter/material.dart';
import 'package:hejtter/models/communities_response.dart';
import 'package:hejtter/ui/home_screen/communities_dialog.dart';
import 'package:hejtter/utils/constants.dart';

class AddPostDialog extends StatefulWidget {
  const AddPostDialog({
    Key? key,
    required this.addPost,
  }) : super(key: key);

  final Future<bool> Function(String, bool, String) addPost;

  @override
  State<AddPostDialog> createState() => _AddPostDialogState();
}

class _AddPostDialogState extends State<AddPostDialog> {
  bool isPostAdding = false;
  bool _isNsfw = false;
  final _textController = TextEditingController();
  final _communitiesController = TextEditingController();

  Community? _chosenCommunity;

  _startAddingPost() async {
    setState(() {
      isPostAdding = true;
    });

    await widget.addPost(
      _textController.text,
      _isNsfw,
      _chosenCommunity?.slug ?? 'Dyskusje',
    );

    setState(() {
      isPostAdding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Nowy wpis',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white.withAlpha(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: TextField(
                autofocus: true,
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: 8,
                decoration: const InputDecoration.collapsed(hintText: null),
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
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: primaryColor,
                  ),
                  onPressed: isPostAdding || _chosenCommunity == null
                      ? null
                      : _startAddingPost,
                  child: isPostAdding
                      ? const CircularProgressIndicator()
                      : const Text('Dodaj'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
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
