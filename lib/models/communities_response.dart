import 'dart:convert';

import 'package:hejtter/models/avatar.dart';
import 'package:hejtter/models/background.dart';

CommunitiesResponse communitiesResponseFromJson(String str) =>
    CommunitiesResponse.fromJson(json.decode(str));

class CommunitiesResponse {
  CommunitiesResponse({
    this.page,
    this.limit,
    this.pages,
    this.total,
    this.links,
    this.embedded,
  });

  final int? page;
  final int? limit;
  final int? pages;
  final int? total;
  final CommunitiesResponseLinks? links;
  final Embedded? embedded;

  factory CommunitiesResponse.fromJson(Map<String, dynamic> json) =>
      CommunitiesResponse(
        page: json["page"],
        limit: json["limit"],
        pages: json["pages"],
        total: json["total"],
        links: json["_links"] == null
            ? null
            : CommunitiesResponseLinks.fromJson(json["_links"]),
        embedded: json["_embedded"] == null
            ? null
            : Embedded.fromJson(json["_embedded"]),
      );
}

class Embedded {
  Embedded({
    this.items,
  });

  final List<Community>? items;

  factory Embedded.fromJson(Map<String, dynamic> json) => Embedded(
        items: json["items"] == null
            ? null
            : List<Community>.from(
                json["items"].map((x) => Community.fromJson(x))),
      );
}

class Community {
  Community({
    this.name,
    this.slug,
    // this.status,
    this.postTypes,
    this.avatar,
    this.background,
    this.primitive,
    this.category,
    this.numMembers,
    this.numPosts,
    this.isMember,
    this.newPosts,
    this.updatedAt,
    this.links,
    this.description,
    this.memberRole,
  });

  final String? name;
  final String? slug;
  // final Status? status;
  final List<PostType>? postTypes;
  final Avatar? avatar;
  final Background? background;
  final bool? primitive;
  final Category? category;
  final int? numMembers;
  final int? numPosts;
  final bool? isMember;
  final int? newPosts;
  final DateTime? updatedAt;
  final ItemLinks? links;
  final String? description;
  final String? memberRole;

  factory Community.fromJson(Map<String, dynamic> json) => Community(
        name: json["name"],
        slug: json["slug"],
        // status:
        //     json["status"] == null ? null : statusValues.map[json["status"]],
        // postTypes: json["post_types"] == null
        //     ? null
        //     : List<PostType>.from(
        //         json["post_types"].map((x) => postTypeValues.map[x])),
        avatar: json["avatar"] == null ? null : Avatar.fromJson(json["avatar"]),
        background: json["background"] == null
            ? null
            : Background.fromJson(json["background"]),
        primitive: json["primitive"],
        category: json["category"] == null
            ? null
            : Category.fromJson(json["category"]),
        numMembers: json["num_members"],
        numPosts: json["num_posts"],
        isMember: json["is_member"],
        newPosts: json["new_posts"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        links:
            json["_links"] == null ? null : ItemLinks.fromJson(json["_links"]),
        description: json["description"],
        memberRole: json["member_role"],
      );
}

class Category {
  Category({
    this.name,
    this.slug,
    this.numPosts,
  });

  final String? name;
  final String? slug;
  final int? numPosts;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        name: json["name"],
        slug: json["slug"],
        numPosts: json["num_posts"],
      );
}

class ItemLinks {
  ItemLinks({
    this.self,
  });

  final First? self;

  factory ItemLinks.fromJson(Map<String, dynamic> json) => ItemLinks(
        self: json["self"] == null ? null : First.fromJson(json["self"]),
      );
}

class First {
  First({
    this.href,
  });

  final String? href;

  factory First.fromJson(Map<String, dynamic> json) => First(
        href: json["href"],
      );
}

enum PostType { DISCUSSION, LINK, ARTICLE, OFFER }

// final postTypeValues = EnumValues({
//   "article": PostType.ARTICLE,
//   "discussion": PostType.DISCUSSION,
//   "link": PostType.LINK,
//   "offer": PostType.OFFER
// });

// enum Status { ACTIVE }

// final statusValues = EnumValues({"active": Status.ACTIVE});

class CommunitiesResponseLinks {
  CommunitiesResponseLinks({
    this.self,
    this.first,
    this.last,
    this.next,
  });

  final First? self;
  final First? first;
  final First? last;
  final First? next;

  factory CommunitiesResponseLinks.fromJson(Map<String, dynamic> json) =>
      CommunitiesResponseLinks(
        self: json["self"] == null ? null : First.fromJson(json["self"]),
        first: json["first"] == null ? null : First.fromJson(json["first"]),
        last: json["last"] == null ? null : First.fromJson(json["last"]),
        next: json["next"] == null ? null : First.fromJson(json["next"]),
      );
}

// class EnumValues<T> {
//   Map<String, T> map;
//   Map<T, String> reverseMap;

//   EnumValues(this.map);

//   Map<T, String> get reverse {
//     if (reverseMap == null) {
//       reverseMap = map.map((k, v) => new MapEntry(v, k));
//     }
//     return reverseMap;
//   }
// }
