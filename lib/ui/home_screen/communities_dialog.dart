import 'package:flutter/material.dart';
import 'package:hejtter/models/communities_response.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/home_screen/community_search_result.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CommunitiesDialog extends StatefulWidget {
  const CommunitiesDialog({
    super.key,
    required this.controller,
    required this.onCommunityPressed,
  });

  final TextEditingController controller;

  final Function(Community) onCommunityPressed;

  @override
  State<CommunitiesDialog> createState() => _CommunitiesDialogState();
}

class _CommunitiesDialogState extends State<CommunitiesDialog> {
  List<Community> _listOfCommunities = List.empty(growable: true);
  bool _isLoading = false;

  _getCommunities(String query) async {
    setState(() {
      _isLoading = true;
    });

    final result = await hejtoApi.getCommunities(
      pageKey: 1,
      pageSize: 50,
      context: context,
      query: query,
    );

    setState(() {
      if (result != null) {
        _listOfCommunities = result;
      }
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _getCommunities(widget.controller.text);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final communitiesWidgets = _listOfCommunities
        .map(
          (item) => CommunitySearchResult(
            onPressed: () {
              widget.onCommunityPressed(item);
            },
            name: '${item.name}',
          ),
        )
        .toList();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: backgroundColor,
      ),
      height: MediaQuery.of(context).size.height / 3,
      width: MediaQuery.of(context).size.width - 20,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            TextField(
              controller: widget.controller,
              autofocus: true,
              onChanged: (value) {
                _getCommunities(value);
              },
            ),
            const SizedBox(height: 10),
            !_isLoading
                ? Expanded(
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: Column(
                          children: communitiesWidgets,
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: LoadingAnimationWidget.fourRotatingDots(
                      color: primaryColor,
                      size: 32,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
