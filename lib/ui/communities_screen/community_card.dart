import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';

import 'package:hejtter/models/communities_response.dart';
import 'package:hejtter/ui/community_screen/community_screen.dart';

class CommunityCard extends StatelessWidget {
  const CommunityCard({
    required this.item,
    super.key,
  });

  final Community item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0, top: 10),
      child: GestureDetector(
        onTap: (() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommunityScreen(
                communitySlug: item.slug,
              ),
            ),
          );
        }),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 80,
                  width: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      color: Theme.of(context).colorScheme.onSurface,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedNetworkImage(
                          imageUrl: '${item.avatar?.urls?.the100X100}',
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      item.category?.name == item.name
                          ? const SizedBox()
                          : Text(
                              '${item.category?.name}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70),
                            ),
                      item.description != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text('${item.description}'),
                            )
                          : const SizedBox(),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Text(item.numMembers.toString()),
                          Text(
                            ' członków',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(item.numPosts.toString()),
                          Text(
                            ' wpisów',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // ElevatedButton(
                //   onPressed: () {},
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: item.isMember == true
                //         ? null
                //         : const Color(
                //             0xff2295F3,
                //           ),
                //     foregroundColor: Colors.white,
                //   ),
                //   child: item.isMember == true
                //       ? const Text('Opuść')
                //       : const Text('Dołącz'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
