import 'dart:convert';

import 'package:hejtter/models/posts_response.dart';

CommentsResponse commentsResponseFromJson(String str) =>
    CommentsResponse.fromJson(json.decode(str));

class CommentsResponse {
  CommentsResponse({
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
  final CommentsResponseLinks? links;
  final Embedded? embedded;

  factory CommentsResponse.fromJson(Map<String, dynamic> json) =>
      CommentsResponse(
        page: json["page"],
        limit: json["limit"],
        pages: json["pages"],
        total: json["total"],
        links: json["_links"] == null
            ? null
            : CommentsResponseLinks.fromJson(json["_links"]),
        embedded: json["_embedded"] == null
            ? null
            : Embedded.fromJson(json["_embedded"]),
      );
}

class Embedded {
  Embedded({
    this.items,
  });

  final List<CommentItem>? items;

  factory Embedded.fromJson(Map<String, dynamic> json) => Embedded(
        items: json["items"] == null
            ? null
            : List<CommentItem>.from(
                json["items"].map((x) => CommentItem.fromJson(x))),
      );
}

class CommentItem {
  CommentItem({
    this.postSlug,
    this.content,
    this.contentPlain,
    // this.contentLinks,
    this.author,
    this.images,
    this.numLikes,
    this.interactions,
    this.createdAt,
    this.uuid,
    this.links,
    this.isLiked,
  });

  final String? postSlug;
  final String? content;
  final String? contentPlain;
  // final List<ContentLink>? contentLinks;
  final Author? author;
  final List<PostImage>? images;
  final Interactions? interactions;
  final DateTime? createdAt;
  final String? uuid;
  final CommentLinks? links;
  final int? numLikes;
  final bool? isLiked;

  factory CommentItem.fromJson(Map<String, dynamic> json) => CommentItem(
        postSlug: json["post_slug"],
        content: json["content"],
        contentPlain: json["content_plain"],
        // contentLinks: json["content_links"] == null
        //     ? null
        //     : List<ContentLink>.from(
        //         json["content_links"].map((x) => ContentLink.fromJson(x))),
        author: json["author"] == null ? null : Author.fromJson(json["author"]),
        images: json["images"] == null
            ? null
            : List<PostImage>.from(
                json["images"].map((x) => PostImage.fromJson(x))),
        interactions: json["interactions"] == null
            ? null
            : Interactions.fromJson(json["interactions"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        uuid: json["uuid"],
        links: json["_links"] == null
            ? null
            : CommentLinks.fromJson(json["_links"]),
        numLikes: json["num_likes"],
        isLiked: json["is_liked"],
      );
}

class Author {
  Author({
    this.username,
    this.avatar,
    this.background,
    this.status,
    this.currentRank,
    this.currentColor,
    this.verified,
    this.sponsor,
    this.createdAt,
    this.links,
  });

  final String? username;
  final Avatar? avatar;
  final Background? background;
  final AuthorStatus? status;
  final String? currentRank;
  final String? currentColor;
  final bool? verified;
  final bool? sponsor;
  final DateTime? createdAt;
  final AuthorLinks? links;

  factory Author.fromJson(Map<String, dynamic> json) => Author(
        username: json["username"],
        avatar: json["avatar"] == null ? null : Avatar.fromJson(json["avatar"]),
        background: json["background"] == null
            ? null
            : Background.fromJson(json["background"]),
        currentRank: json["current_rank"],
        currentColor: json["current_color"],
        verified: json["verified"],
        sponsor: json["sponsor"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        links: json["_links"] == null
            ? null
            : AuthorLinks.fromJson(json["_links"]),
      );
}

class Avatar {
  Avatar({
    this.urls,
    this.uuid,
    this.alt,
  });

  final AvatarUrls? urls;
  final String? uuid;
  final String? alt;

  factory Avatar.fromJson(Map<String, dynamic> json) => Avatar(
        urls: json["urls"] == null ? null : AvatarUrls.fromJson(json["urls"]),
        uuid: json["uuid"],
        alt: json["alt"],
      );
}

class AvatarUrls {
  AvatarUrls({
    this.the100X100,
    this.the250X250,
  });

  final String? the100X100;
  final String? the250X250;

  factory AvatarUrls.fromJson(Map<String, dynamic> json) => AvatarUrls(
        the100X100: json["100x100"],
        the250X250: json["250x250"],
      );
}

class Background {
  Background({
    this.urls,
    this.uuid,
    this.alt,
  });

  final BackgroundUrls? urls;
  final String? uuid;
  final String? alt;

  factory Background.fromJson(Map<String, dynamic> json) => Background(
        urls:
            json["urls"] == null ? null : BackgroundUrls.fromJson(json["urls"]),
        uuid: json["uuid"],
        alt: json["alt"],
      );
}

class BackgroundUrls {
  BackgroundUrls({
    this.the400X300,
    this.the1200X900,
    this.original,
  });

  final String? the400X300;
  final String? the1200X900;
  final String? original;

  factory BackgroundUrls.fromJson(Map<String, dynamic> json) => BackgroundUrls(
        the400X300: json["400x300"],
        the1200X900: json["1200x900"],
        original: json["original"],
      );
}

class AuthorLinks {
  AuthorLinks({
    this.self,
    this.follows,
  });

  final First? self;
  final First? follows;

  factory AuthorLinks.fromJson(Map<String, dynamic> json) => AuthorLinks(
        self: json["self"] == null ? null : First.fromJson(json["self"]),
        follows:
            json["follows"] == null ? null : First.fromJson(json["follows"]),
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

enum AuthorStatus { ACTIVE }

// final authorStatusValues = EnumValues({"active": AuthorStatus.ACTIVE});

class ContentLink {
  ContentLink({
    this.url,
    this.site,
    this.type,
    this.title,
    this.audios,
    this.images,
    this.videos,
    // this.favicon,
    this.description,
  });

  final String? url;
  final String? site;
  final String? type;
  final String? title;
  final List<dynamic>? audios;
  final List<Image>? images;
  final List<Video>? videos;
  // final Favicon? favicon;
  final String? description;

  factory ContentLink.fromJson(Map<String, dynamic> json) => ContentLink(
        url: json["url"],
        site: json["site"],
        type: json["type"],
        title: json["title"],
        audios: json["audios"] == null
            ? null
            : List<dynamic>.from(json["audios"].map((x) => x)),
        images: json["images"] == null
            ? null
            : List<Image>.from(json["images"].map((x) => Image.fromJson(x))),
        videos: json["videos"] == null
            ? null
            : List<Video>.from(json["videos"].map((x) => Video.fromJson(x))),
        // favicon:
        //     json["favicon"] == null ? null : Favicon.fromJson(json["favicon"]),
        description: json["description"],
      );
}

class Favicon {
  Favicon({
    this.url,
    this.safe,
  });

  final String? url;
  final String? safe;

  factory Favicon.fromJson(Map<String, dynamic> json) => Favicon(
        url: json["url"],
        safe: json["safe"],
      );
}

class Image {
  Image({
    this.url,
    this.safe,
    this.width,
    this.height,
  });

  final String? url;
  final String? safe;
  final int? width;
  final int? height;

  factory Image.fromJson(Map<String, dynamic> json) => Image(
        url: json["url"],
        safe: json["safe"],
        width: json["width"],
        height: json["height"],
      );
}

class Video {
  Video({
    this.url,
    this.type,
    this.width,
    this.height,
    this.secureUrl,
  });

  final String? url;
  final String? type;
  final int? width;
  final int? height;
  final String? secureUrl;

  factory Video.fromJson(Map<String, dynamic> json) => Video(
        url: json["url"],
        type: json["type"],
        width: json["width"],
        height: json["height"],
        secureUrl: json["secureUrl"],
      );
}

class Interactions {
  Interactions({
    this.isLiked,
    this.isReported,
  });

  final bool? isLiked;
  final bool? isReported;

  factory Interactions.fromJson(Map<String, dynamic> json) => Interactions(
        isLiked: json["is_liked"],
        isReported: json["is_reported"],
      );
}

class CommentLinks {
  CommentLinks({
    this.self,
    this.likes,
  });

  final First? self;
  final First? likes;

  factory CommentLinks.fromJson(Map<String, dynamic> json) => CommentLinks(
        self: json["self"] == null ? null : First.fromJson(json["self"]),
        likes: json["likes"] == null ? null : First.fromJson(json["likes"]),
      );
}

enum ItemStatus { PUBLISHED }

// final itemStatusValues = EnumValues({"published": ItemStatus.PUBLISHED});

class CommentsResponseLinks {
  CommentsResponseLinks({
    this.self,
    this.first,
    this.last,
    this.next,
  });

  final First? self;
  final First? first;
  final First? last;
  final First? next;

  factory CommentsResponseLinks.fromJson(Map<String, dynamic> json) =>
      CommentsResponseLinks(
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
