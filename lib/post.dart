// To parse this JSON data, do
//
//     final post = postFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

PostsResponse postFromJson(String str) =>
    PostsResponse.fromJson(json.decode(str));

// String postToJson(Post data) => json.encode(data.toJson());

class PostsResponse {
  PostsResponse({
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
  final PostLinks? links;
  final Embedded? embedded;

  // Post copyWith({
  //   required int page,
  //   required int limit,
  //   required int pages,
  //   required int total,
  //   required PostLinks links,
  //   required Embedded embedded,
  // }) =>
  //     Post(
  //       page: page,
  //       limit: limit,
  //       pages: pages,
  //       total: total,
  //       links: links,
  //       embedded: embedded,
  //     );

  factory PostsResponse.fromJson(Map<String, dynamic> json) {
    // print('embedded: ${json["_embedded"]}');
    return PostsResponse(
      page: json["page"],
      limit: json["limit"],
      pages: json["pages"],
      total: json["total"],
      links: json["_links"] == null ? null : PostLinks.fromJson(json["_links"]),
      embedded: json["_embedded"] == null
          ? null
          : Embedded.fromJson(json["_embedded"]),
    );
  }

  // Map<String, dynamic> toJson() => {
  //       "page": page == null ? null : page,
  //       "limit": limit == null ? null : limit,
  //       "pages": pages == null ? null : pages,
  //       "total": total == null ? null : total,
  //       "_links": links == null ? null : links.toJson(),
  //       "_embedded": embedded == null ? null : embedded.toJson(),
  //     };
}

class Embedded {
  Embedded({
    this.items,
  });

  final List<Item>? items;

  // Embedded copyWith({
  //   List<Item> items,
  // }) =>
  //     Embedded(
  //       items: items ?? this.items,
  //     );

  factory Embedded.fromJson(Map<String, dynamic> json) => Embedded(
        items: json["items"] == null
            ? null
            : List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
      );

  // Map<String, dynamic> toJson() => {
  //       "items": items == null
  //           ? null
  //           : List<dynamic>.from(items.map((x) => x.toJson())),
  //     };
}

class Item {
  Item({
    this.comments,
    this.type,
    this.title,
    this.slug,
    this.content,
    this.contentPlain,
    this.excerpt,
    this.status,
    this.hot,
    this.contentLinks,
    this.images,
    this.tags,
    this.author,
    this.stats,
    this.interactions,
    this.community,
    this.nsfw,
    this.controversial,
    this.commentsEnabled,
    this.favoritesEnabled,
    this.likesEnabled,
    this.reportsEnabled,
    this.sharesEnabled,
    this.createdAt,
    this.discr,
    this.links,
    this.communityTopic,
    this.link,
    this.updatedAt,
  });

  final List<Comment>? comments;
  final String? type;
  final String? title;
  final String? slug;
  final String? content;
  final String? contentPlain;
  final String? excerpt;
  final String? status;
  final bool? hot;
  final List<dynamic>? contentLinks;
  final List<Image>? images;
  final List<Tag>? tags;
  final ItemAuthor? author;
  final ItemStats? stats;
  final ItemInteractions? interactions;
  final Community? community;
  final bool? nsfw;
  final bool? controversial;
  final bool? commentsEnabled;
  final bool? favoritesEnabled;
  final bool? likesEnabled;
  final bool? reportsEnabled;
  final bool? sharesEnabled;
  final DateTime? createdAt;
  final String? discr;
  final ItemLinks? links;
  final CommunityTopic? communityTopic;
  final String? link;
  final DateTime? updatedAt;

  // Item copyWith({
  //   required List<Comment> comments,
  //   required String type,
  //   required String title,
  //   required String slug,
  //   required String content,
  //   required String contentPlain,
  //   required String excerpt,
  //   required String status,
  //   required bool hot,
  //   required List<dynamic> contentLinks,
  //   required List<Image> images,
  //   required List<Tag> tags,
  //   required ItemAuthor author,
  //   required ItemStats stats,
  //   required ItemInteractions interactions,
  //   required Community community,
  //   required bool nsfw,
  //   required bool controversial,
  //   required bool commentsEnabled,
  //   required bool favoritesEnabled,
  //   required bool likesEnabled,
  //   required bool reportsEnabled,
  //   required bool sharesEnabled,
  //   required DateTime createdAt,
  //   required String discr,
  //   required ItemLinks links,
  //   required CommunityTopic communityTopic,
  //   required String link,
  //   required DateTime updatedAt,
  // }) =>
  //     Item(
  //       comments: comments,
  //       type: type,
  //       title: title,
  //       slug: slug,
  //       content: content,
  //       contentPlain: contentPlain,
  //       excerpt: excerpt,
  //       status: status,
  //       hot: hot,
  //       contentLinks: contentLinks,
  //       images: images,
  //       tags: tags,
  //       author: author,
  //       stats: stats,
  //       interactions: interactions,
  //       community: community,
  //       nsfw: nsfw,
  //       controversial: controversial,
  //       commentsEnabled: commentsEnabled,
  //       favoritesEnabled: favoritesEnabled,
  //       likesEnabled: likesEnabled,
  //       reportsEnabled: reportsEnabled,
  //       sharesEnabled: sharesEnabled,
  //       createdAt: createdAt,
  //       discr: discr,
  //       links: links,
  //       communityTopic: communityTopic,
  //       link: link,
  //       updatedAt: updatedAt,
  //     );

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        comments: json["comments"] == null
            ? null
            : List<Comment>.from(
                json["comments"].map((x) => Comment.fromJson(x))),
        type: json["type"],
        title: json["title"],
        slug: json["slug"],
        content: json["content"],
        contentPlain: json["content_plain"],
        excerpt: json["excerpt"],
        status: json["status"],
        hot: json["hot"],
        contentLinks: json["content_links"] == null
            ? null
            : List<dynamic>.from(json["content_links"].map((x) => x)),
        images: json["images"] == null
            ? null
            : List<Image>.from(json["images"].map((x) => Image.fromJson(x))),
        tags: json["tags"] == null
            ? null
            : List<Tag>.from(json["tags"].map((x) => Tag.fromJson(x))),
        author:
            json["author"] == null ? null : ItemAuthor.fromJson(json["author"]),
        stats: json["stats"] == null ? null : ItemStats.fromJson(json["stats"]),
        interactions: json["interactions"] == null
            ? null
            : ItemInteractions.fromJson(json["interactions"]),
        community: json["community"] == null
            ? null
            : Community.fromJson(json["community"]),
        nsfw: json["nsfw"],
        controversial: json["controversial"],
        commentsEnabled: json["comments_enabled"],
        favoritesEnabled: json["favorites_enabled"],
        likesEnabled: json["likes_enabled"],
        reportsEnabled: json["reports_enabled"],
        sharesEnabled: json["shares_enabled"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        discr: json["discr"],
        links:
            json["_links"] == null ? null : ItemLinks.fromJson(json["_links"]),
        communityTopic: json["community_topic"] == null
            ? null
            : CommunityTopic.fromJson(json["community_topic"]),
        link: json["link"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  // Map<String, dynamic> toJson() => {
  //       "comments": comments == null
  //           ? null
  //           : List<dynamic>.from(comments.map((x) => x.toJson())),
  //       "type": type,
  //       "title": title,
  //       "slug": slug,
  //       "content": content,
  //       "content_plain": contentPlain,
  //       "excerpt": excerpt,
  //       "status": status,
  //       "hot": hot,
  //       "content_links": contentLinks == null
  //           ? null
  //           : List<dynamic>.from(contentLinks.map((x) => x)),
  //       "images": images == null
  //           ? null
  //           : List<dynamic>.from(images.map((x) => x.toJson())),
  //       "tags": tags == null
  //           ? null
  //           : List<dynamic>.from(tags.map((x) => x.toJson())),
  //       "author": author == null ? null : author.toJson(),
  //       "stats": stats == null ? null : stats.toJson(),
  //       "interactions": interactions == null ? null : interactions.toJson(),
  //       "community": community == null ? null : community.toJson(),
  //       "nsfw": nsfw,
  //       "controversial": controversial,
  //       "comments_enabled": commentsEnabled,
  //       "favorites_enabled": favoritesEnabled,
  //       "likes_enabled": likesEnabled,
  //       "reports_enabled": reportsEnabled,
  //       "shares_enabled": sharesEnabled,
  //       "created_at": createdAt == null ? null : createdAt.toIso8601String(),
  //       "discr": discr,
  //       "_links": links == null ? null : links.toJson(),
  //       "community_topic":
  //           communityTopic == null ? null : communityTopic.toJson(),
  //       "link": link,
  //       "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
  //     };
}

class ItemAuthor {
  ItemAuthor({
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
  final CommunityAvatar? avatar;
  final CommunityBackground? background;
  final String? status;
  final String? currentRank;
  final String? currentColor;
  final bool? verified;
  final bool? sponsor;
  final DateTime? createdAt;
  final AuthorLinks? links;

  // ItemAuthor copyWith({
  //   required String username,
  //   required CommunityAvatar avatar,
  //   required CommunityBackground background,
  //   required String status,
  //   required String currentRank,
  //   required String currentColor,
  //   required bool verified,
  //   required bool sponsor,
  //   required DateTime createdAt,
  //   required AuthorLinks links,
  // }) =>
  //     ItemAuthor(
  //       username: username,
  //       avatar: avatar,
  //       background: background,
  //       status: status,
  //       currentRank: currentRank,
  //       currentColor: currentColor,
  //       verified: verified,
  //       sponsor: sponsor,
  //       createdAt: createdAt,
  //       links: links,
  //     );

  factory ItemAuthor.fromJson(Map<String, dynamic> json) => ItemAuthor(
        username: json["username"],
        avatar: json["avatar"] == null
            ? null
            : CommunityAvatar.fromJson(json["avatar"]),
        background: json["background"] == null
            ? null
            : CommunityBackground.fromJson(json["background"]),
        status: json["status"],
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

  // Map<String, dynamic> toJson() => {
  //       "username": username,
  //       "avatar": avatar == null ? null : avatar.toJson(),
  //       "background": background == null ? null : background.toJson(),
  //       "status": status,
  //       "current_rank": currentRank,
  //       "current_color": currentColor,
  //       "verified": verified,
  //       "sponsor": sponsor,
  //       "created_at": createdAt == null ? null : createdAt.toIso8601String(),
  //       "_links": links == null ? null : links.toJson(),
  //     };
}

class CommunityAvatar {
  CommunityAvatar({
    this.urls,
    this.uuid,
    this.alt,
  });

  final AvatarUrls? urls;
  final String? uuid;
  final String? alt;

  // CommunityAvatar copyWith({
  //   required AvatarUrls urls,
  //   required String uuid,
  //   required String alt,
  // }) =>
  //     CommunityAvatar(
  //       urls: urls,
  //       uuid: uuid,
  //       alt: alt,
  //     );

  factory CommunityAvatar.fromJson(Map<String, dynamic> json) =>
      CommunityAvatar(
        urls: AvatarUrls.fromJson(json["urls"]),
        uuid: json["uuid"],
        alt: json["alt"],
      );

  // Map<String, dynamic> toJson() => {
  //       "urls": urls.toJson(),
  //       "uuid": uuid,
  //       "alt": alt,
  //     };
}

class AvatarUrls {
  AvatarUrls({
    this.the100X100,
    this.the250X250,
  });

  final String? the100X100;
  final String? the250X250;

  // AvatarUrls copyWith({
  //   required String the100X100,
  //   required String the250X250,
  // }) =>
  //     AvatarUrls(
  //       the100X100: the100X100,
  //       the250X250: the250X250,
  //     );

  factory AvatarUrls.fromJson(Map<String, dynamic> json) => AvatarUrls(
        the100X100: json["100x100"],
        the250X250: json["250x250"],
      );

  // Map<String, dynamic> toJson() => {
  //       "100x100": the100X100,
  //       "250x250": the250X250,
  //     };
}

class CommunityBackground {
  CommunityBackground({
    this.urls,
    this.uuid,
    this.alt,
  });

  final BackgroundUrls? urls;
  final String? uuid;
  final String? alt;

  // CommunityBackground copyWith({
  //   required BackgroundUrls urls,
  //   required String uuid,
  //   required String alt,
  // }) =>
  //     CommunityBackground(
  //       urls: urls,
  //       uuid: uuid,
  //       alt: alt,
  //     );

  factory CommunityBackground.fromJson(Map<String, dynamic> json) =>
      CommunityBackground(
        urls: BackgroundUrls.fromJson(json["urls"]),
        uuid: json["uuid"],
        alt: json["alt"],
      );

  // Map<String, dynamic> toJson() => {
  //       "urls": urls == null ? null : urls.toJson(),
  //       "uuid": uuid,
  //       "alt": alt,
  //     };
}

class BackgroundUrls {
  BackgroundUrls({
    this.the400X300,
    this.the1200X900,
  });

  final String? the400X300;
  final String? the1200X900;

  // BackgroundUrls copyWith({
  //   required String the400X300,
  //   required String the1200X900,
  // }) =>
  //     BackgroundUrls(
  //       the400X300: the400X300 ?? this.the400X300,
  //       the1200X900: the1200X900 ?? this.the1200X900,
  //     );

  factory BackgroundUrls.fromJson(Map<String, dynamic> json) => BackgroundUrls(
        the400X300: json["400x300"],
        the1200X900: json["1200x900"],
      );

  // Map<String, dynamic> toJson() => {
  //       "400x300": the400X300,
  //       "1200x900": the1200X900,
  //     };
}

class AuthorLinks {
  AuthorLinks({
    this.self,
    this.follows,
  });

  final First? self;
  final First? follows;

  // AuthorLinks copyWith({
  //   required First self,
  //   required First follows,
  // }) =>
  //     AuthorLinks(
  //       self: self ?? this.self,
  //       follows: follows ?? this.follows,
  //     );

  factory AuthorLinks.fromJson(Map<String, dynamic> json) => AuthorLinks(
        self: First.fromJson(json["self"]),
        follows: First.fromJson(json["follows"]),
      );

  // Map<String, dynamic> toJson() => {
  //       "self": self == null ? null : self.toJson(),
  //       "follows": follows == null ? null : follows.toJson(),
  //     };
}

class First {
  First({
    this.href,
  });

  final String? href;

  // First copyWith({
  //   required String href,
  // }) =>
  //     First(
  //       href: href ?? this.href,
  //     );

  factory First.fromJson(Map<String, dynamic> json) => First(
        href: json["href"],
      );

  // Map<String, dynamic> toJson() => {
  //       "href": href,
  //     };
}

class Comment {
  Comment({
    this.postSlug,
    this.content,
    this.contentPlain,
    this.status,
    this.contentLinks,
    this.author,
    this.images,
    this.stats,
    this.interactions,
    this.createdAt,
    this.uuid,
    this.links,
  });

  final String? postSlug;
  final String? content;
  final String? contentPlain;
  final String? status;
  final List<dynamic>? contentLinks;
  final CommentAuthor? author;
  final List<dynamic>? images;
  final CommentStats? stats;
  final CommentInteractions? interactions;
  final DateTime? createdAt;
  final String? uuid;
  final CommentLinks? links;

  // Comment copyWith({
  //   required String postSlug,
  //   required String content,
  //   required String contentPlain,
  //   required String status,
  //   required List<dynamic> contentLinks,
  //   required CommentAuthor author,
  //   required List<dynamic> images,
  //   required CommentStats stats,
  //   required CommentInteractions interactions,
  //   required DateTime createdAt,
  //   required String uuid,
  //   required CommentLinks links,
  // }) =>
  //     Comment(
  //       postSlug: postSlug ?? this.postSlug,
  //       content: content ?? this.content,
  //       contentPlain: contentPlain ?? this.contentPlain,
  //       status: status ?? this.status,
  //       contentLinks: contentLinks ?? this.contentLinks,
  //       author: author ?? this.author,
  //       images: images ?? this.images,
  //       stats: stats ?? this.stats,
  //       interactions: interactions ?? this.interactions,
  //       createdAt: createdAt ?? this.createdAt,
  //       uuid: uuid ?? this.uuid,
  //       links: links ?? this.links,
  //     );

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        postSlug: json["post_slug"],
        content: json["content"],
        contentPlain: json["content_plain"],
        status: json["status"],
        contentLinks: List<dynamic>.from(json["content_links"].map((x) => x)),
        author: CommentAuthor.fromJson(json["author"]),
        images: List<dynamic>.from(json["images"].map((x) => x)),
        stats: CommentStats.fromJson(json["stats"]),
        interactions: CommentInteractions.fromJson(json["interactions"]),
        createdAt: DateTime.parse(json["created_at"]),
        uuid: json["uuid"],
        links: CommentLinks.fromJson(json["_links"]),
      );

  // Map<String, dynamic> toJson() => {
  //       "post_slug": postSlug,
  //       "content": content,
  //       "content_plain": contentPlain,
  //       "status": status,
  //       "content_links": contentLinks == null
  //           ? null
  //           : List<dynamic>.from(contentLinks.map((x) => x)),
  //       "author": author == null ? null : author.toJson(),
  //       "images":
  //           images == null ? null : List<dynamic>.from(images.map((x) => x)),
  //       "stats": stats == null ? null : stats.toJson(),
  //       "interactions": interactions == null ? null : interactions.toJson(),
  //       "created_at": createdAt == null ? null : createdAt.toIso8601String(),
  //       "uuid": uuid,
  //       "_links": links == null ? null : links.toJson(),
  //     };
}

class CommentAuthor {
  CommentAuthor({
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
  final PurpleAvatar? avatar;
  final PurpleBackground? background;
  final String? status;
  final String? currentRank;
  final String? currentColor;
  final bool? verified;
  final bool? sponsor;
  final DateTime? createdAt;
  final AuthorLinks? links;

  // CommentAuthor copyWith({
  //   required String username,
  //   required PurpleAvatar avatar,
  //   required PurpleBackground background,
  //   required String status,
  //   required String currentRank,
  //   required String currentColor,
  //   required bool verified,
  //   required bool sponsor,
  //   required DateTime createdAt,
  //   required AuthorLinks links,
  // }) =>
  //     CommentAuthor(
  //       username: username ?? this.username,
  //       avatar: avatar ?? this.avatar,
  //       background: background ?? this.background,
  //       status: status ?? this.status,
  //       currentRank: currentRank ?? this.currentRank,
  //       currentColor: currentColor ?? this.currentColor,
  //       verified: verified ?? this.verified,
  //       sponsor: sponsor ?? this.sponsor,
  //       createdAt: createdAt ?? this.createdAt,
  //       links: links ?? this.links,
  //     );

  factory CommentAuthor.fromJson(Map<String, dynamic> json) => CommentAuthor(
        username: json["username"],
        avatar: json["avatar"] == null
            ? null
            : PurpleAvatar.fromJson(json["avatar"]),
        background: json["background"] == null
            ? null
            : PurpleBackground.fromJson(json["background"]),
        status: json["status"],
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

  // Map<String, dynamic> toJson() => {
  //       "username": username,
  //       "avatar": avatar == null ? null : avatar.toJson(),
  //       "background": background == null ? null : background.toJson(),
  //       "status": status,
  //       "current_rank": currentRank,
  //       "current_color": currentColor,
  //       "verified": verified,
  //       "sponsor": sponsor,
  //       "created_at": createdAt == null ? null : createdAt.toIso8601String(),
  //       "_links": links == null ? null : links.toJson(),
  //     };
}

class PurpleAvatar {
  PurpleAvatar({
    this.urls,
    this.uuid,
  });

  final AvatarUrls? urls;
  final String? uuid;

  // PurpleAvatar copyWith({
  //   required AvatarUrls urls,
  //   required String uuid,
  // }) =>
  //     PurpleAvatar(
  //       urls: urls ?? this.urls,
  //       uuid: uuid ?? this.uuid,
  //     );

  factory PurpleAvatar.fromJson(Map<String, dynamic> json) => PurpleAvatar(
        urls: AvatarUrls.fromJson(json["urls"]),
        uuid: json["uuid"],
      );

  // Map<String, dynamic> toJson() => {
  //       "urls": urls == null ? null : urls.toJson(),
  //       "uuid": uuid,
  //     };
}

class PurpleBackground {
  PurpleBackground({
    this.urls,
    this.uuid,
  });

  final BackgroundUrls? urls;
  final String? uuid;

  // PurpleBackground copyWith({
  //   required BackgroundUrls urls,
  //   required String uuid,
  // }) =>
  //     PurpleBackground(
  //       urls: urls ?? this.urls,
  //       uuid: uuid ?? this.uuid,
  //     );

  factory PurpleBackground.fromJson(Map<String, dynamic> json) =>
      PurpleBackground(
        urls: BackgroundUrls.fromJson(json["urls"]),
        uuid: json["uuid"],
      );

  // Map<String, dynamic> toJson() => {
  //       "urls": urls == null ? null : urls.toJson(),
  //       "uuid": uuid,
  //     };
}

class CommentInteractions {
  CommentInteractions({
    this.isLiked,
    this.isReported,
  });

  final bool? isLiked;
  final bool? isReported;

  // CommentInteractions copyWith({
  //   required bool isLiked,
  //   required bool isReported,
  // }) =>
  //     CommentInteractions(
  //       isLiked: isLiked ?? this.isLiked,
  //       isReported: isReported ?? this.isReported,
  //     );

  factory CommentInteractions.fromJson(Map<String, dynamic> json) =>
      CommentInteractions(
        isLiked: json["is_liked"],
        isReported: json["is_reported"],
      );

  // Map<String, dynamic> toJson() => {
  //       "is_liked": isLiked,
  //       "is_reported": isReported,
  //     };
}

class CommentLinks {
  CommentLinks({
    this.self,
    this.likes,
  });

  final First? self;
  final First? likes;

  // CommentLinks copyWith({
  //   required First self,
  //   required First likes,
  // }) =>
  //     CommentLinks(
  //       self: self ?? this.self,
  //       likes: likes ?? this.likes,
  //     );

  factory CommentLinks.fromJson(Map<String, dynamic> json) => CommentLinks(
        self: First.fromJson(json["self"]),
        likes: First.fromJson(json["likes"]),
      );

  // Map<String, dynamic> toJson() => {
  //       "self": self == null ? null : self.toJson(),
  //       "likes": likes == null ? null : likes.toJson(),
  //     };
}

class CommentStats {
  CommentStats({
    this.numLikes,
    this.numReports,
  });

  final int? numLikes;
  final int? numReports;

  // CommentStats copyWith({
  //   required int numLikes,
  //   required int numReports,
  // }) =>
  //     CommentStats(
  //       numLikes: numLikes ?? this.numLikes,
  //       numReports: numReports ?? this.numReports,
  //     );

  factory CommentStats.fromJson(Map<String, dynamic> json) => CommentStats(
        numLikes: json["num_likes"],
        numReports: json["num_reports"],
      );

  // Map<String, dynamic> toJson() => {
  //       "num_likes": numLikes,
  //       "num_reports": numReports,
  //     };
}

class Community {
  Community({
    this.name,
    this.slug,
    this.avatar,
    this.background,
  });

  final String? name;
  final String? slug;
  final CommunityAvatar? avatar;
  final CommunityBackground? background;

  // Community copyWith({
  //   required String name,
  //   required String slug,
  //   required CommunityAvatar avatar,
  //   required CommunityBackground background,
  // }) =>
  //     Community(
  //       name: name ?? this.name,
  //       slug: slug ?? this.slug,
  //       avatar: avatar ?? this.avatar,
  //       background: background ?? this.background,
  //     );

  factory Community.fromJson(Map<String, dynamic> json) => Community(
        name: json["name"],
        slug: json["slug"],
        avatar: json["avatar"] == null
            ? null
            : CommunityAvatar.fromJson(json["avatar"]),
        background: json["background"] == null
            ? null
            : CommunityBackground.fromJson(json["background"]),
      );

  // Map<String, dynamic> toJson() => {
  //       "name": name,
  //       "slug": slug,
  //       "avatar": avatar == null ? null : avatar.toJson(),
  //       "background": background == null ? null : background.toJson(),
  //     };
}

class CommunityTopic {
  CommunityTopic({
    this.name,
    this.slug,
  });

  final String? name;
  final String? slug;

  // CommunityTopic copyWith({
  //   required String name,
  //   required String slug,
  // }) =>
  //     CommunityTopic(
  //       name: name ?? this.name,
  //       slug: slug ?? this.slug,
  //     );

  factory CommunityTopic.fromJson(Map<String, dynamic> json) => CommunityTopic(
        name: json["name"],
        slug: json["slug"],
      );

  // Map<String, dynamic> toJson() => {
  //       "name": name,
  //       "slug": slug,
  //     };
}

class Image {
  Image({
    this.urls,
    this.uuid,
    this.position,
  });

  final ImageUrls? urls;
  final String? uuid;
  final int? position;

  // Image copyWith({
  //   required ImageUrls urls,
  //   required String uuid,
  //   required int position,
  // }) =>
  //     Image(
  //       urls: urls ?? this.urls,
  //       uuid: uuid ?? this.uuid,
  //       position: position ?? this.position,
  //     );

  factory Image.fromJson(Map<String, dynamic> json) => Image(
        urls: ImageUrls.fromJson(json["urls"]),
        uuid: json["uuid"],
        position: json["position"],
      );

  // Map<String, dynamic> toJson() => {
  //       "urls": urls == null ? null : urls.toJson(),
  //       "uuid": uuid,
  //       "position": position,
  //     };
}

class ImageUrls {
  ImageUrls({
    this.the250X250,
    this.the500X500,
    this.the1200X900,
  });

  final String? the250X250;
  final String? the500X500;
  final String? the1200X900;

  // ImageUrls copyWith({
  //   required String the250X250,
  //   required String the500X500,
  //   required String the1200X900,
  // }) =>
  //     ImageUrls(
  //       the250X250: the250X250 ?? this.the250X250,
  //       the500X500: the500X500 ?? this.the500X500,
  //       the1200X900: the1200X900 ?? this.the1200X900,
  //     );

  factory ImageUrls.fromJson(Map<String, dynamic> json) => ImageUrls(
        the250X250: json["250x250"],
        the500X500: json["500x500"],
        the1200X900: json["1200x900"],
      );

  // Map<String, dynamic> toJson() => {
  //       "250x250": the250X250,
  //       "500x500": the500X500,
  //       "1200x900": the1200X900,
  //     };
}

class ItemInteractions {
  ItemInteractions({
    this.isLiked,
    this.isCommented,
    this.isFavorited,
  });

  final bool? isLiked;
  final bool? isCommented;
  final bool? isFavorited;

  // ItemInteractions copyWith({
  //   required bool isLiked,
  //   required bool isCommented,
  //   required bool isFavorited,
  // }) =>
  //     ItemInteractions(
  //       isLiked: isLiked ?? this.isLiked,
  //       isCommented: isCommented ?? this.isCommented,
  //       isFavorited: isFavorited ?? this.isFavorited,
  //     );

  factory ItemInteractions.fromJson(Map<String, dynamic> json) =>
      ItemInteractions(
        isLiked: json["is_liked"],
        isCommented: json["is_commented"],
        isFavorited: json["is_favorited"],
      );

  // Map<String, dynamic> toJson() => {
  //       "is_liked": isLiked,
  //       "is_commented": isCommented,
  //       "is_favorited": isFavorited,
  //     };
}

class ItemLinks {
  ItemLinks({
    this.self,
    this.comments,
    this.likes,
    this.favorites,
  });

  final First? self;
  final First? comments;
  final First? likes;
  final First? favorites;

  // ItemLinks copyWith({
  //   required First self,
  //   required First comments,
  //   required First likes,
  //   required First favorites,
  // }) =>
  //     ItemLinks(
  //       self: self ?? this.self,
  //       comments: comments ?? this.comments,
  //       likes: likes ?? this.likes,
  //       favorites: favorites ?? this.favorites,
  //     );

  factory ItemLinks.fromJson(Map<String, dynamic> json) => ItemLinks(
        self: First.fromJson(json["self"]),
        comments: First.fromJson(json["comments"]),
        likes: First.fromJson(json["likes"]),
        favorites: First.fromJson(json["favorites"]),
      );

  // Map<String, dynamic> toJson() => {
  //       "self": self == null ? null : self.toJson(),
  //       "comments": comments == null ? null : comments.toJson(),
  //       "likes": likes == null ? null : likes.toJson(),
  //       "favorites": favorites == null ? null : favorites.toJson(),
  //     };
}

class ItemStats {
  ItemStats({
    this.numLikes,
    this.numComments,
    this.numFavorites,
    this.hotness,
  });

  final int? numLikes;
  final int? numComments;
  final int? numFavorites;
  final int? hotness;

  // ItemStats copyWith({
  //   int? numLikes,
  //   int? numComments,
  //   int? numFavorites,
  //   int? hotness,
  // }) =>
  //     ItemStats(
  //       numLikes: numLikes ?? this.numLikes,
  //       numComments: numComments ?? this.numComments,
  //       numFavorites: numFavorites ?? this.numFavorites,
  //       hotness: hotness ?? this.hotness,
  //     );

  factory ItemStats.fromJson(Map<String, dynamic> json) => ItemStats(
        numLikes: json["num_likes"],
        numComments: json["num_comments"],
        numFavorites: json["num_favorites"],
        hotness: json["hotness"],
      );

  // Map<String, dynamic> toJson() => {
  //       "num_likes": numLikes,
  //       "num_comments": numComments,
  //       "num_favorites": numFavorites,
  //       "hotness": hotness,
  //     };
}

class Tag {
  Tag({
    this.name,
    this.links,
  });

  final String? name;
  final TagLinks? links;

  // Tag copyWith({
  //   String? name,
  //   TagLinks? links,
  // }) =>
  //     Tag(
  //       name: name ?? this.name,
  //       links: links ?? this.links,
  //     );

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        name: json["name"],
        links: TagLinks.fromJson(json["_links"]),
      );

  // Map<String, dynamic> toJson() => {
  //       "name": name,
  //       "_links": links == null ? null : links.toJson(),
  //     };
}

class TagLinks {
  TagLinks({
    this.self,
    this.follows,
    this.blocks,
  });

  final First? self;
  final First? follows;
  final First? blocks;

  // TagLinks copyWith({
  //   First? self,
  //   First? follows,
  //   First? blocks,
  // }) =>
  //     TagLinks(
  //       self: self ?? this.self,
  //       follows: follows ?? this.follows,
  //       blocks: blocks ?? this.blocks,
  //     );

  factory TagLinks.fromJson(Map<String, dynamic> json) => TagLinks(
        self: First.fromJson(json["self"]),
        follows: First.fromJson(json["follows"]),
        blocks: First.fromJson(json["blocks"]),
      );

  // Map<String, dynamic> toJson() => {
  //       "self": self == null ? null : self.toJson(),
  //       "follows": follows == null ? null : follows.toJson(),
  //       "blocks": blocks == null ? null : blocks.toJson(),
  //     };
}

class PostLinks {
  PostLinks({
    this.self,
    this.first,
    this.last,
    this.next,
  });

  final First? self;
  final First? first;
  final First? last;
  final First? next;

  // PostLinks copyWith({
  //   First? self,
  //   First? first,
  //   First? last,
  //   First? next,
  // }) =>
  //     PostLinks(
  //       self: self ?? this.self,
  //       first: first ?? this.first,
  //       last: last ?? this.last,
  //       next: next ?? this.next,
  //     );

  factory PostLinks.fromJson(Map<String, dynamic> json) => PostLinks(
        self: First.fromJson(json["self"]),
        first: First.fromJson(json["first"]),
        last: First.fromJson(json["last"]),
        next: First.fromJson(json["next"]),
      );

  // Map<String, dynamic> toJson() => {
  //       "self": self == null ? null : self.toJson(),
  //       "first": first == null ? null : first.toJson(),
  //       "last": last == null ? null : last.toJson(),
  //       "next": next == null ? null : next.toJson(),
  //     };
}
