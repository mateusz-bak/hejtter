import 'dart:convert';

UserNotification userNotificationFromJson(String str) =>
    UserNotification.fromJson(json.decode(str));

class UserNotification {
  UserNotification({
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
  final UserNotificationLinks? links;
  final Embedded? embedded;

  factory UserNotification.fromJson(Map<String, dynamic> json) =>
      UserNotification(
        page: json["page"],
        limit: json["limit"],
        pages: json["pages"],
        total: json["total"],
        links: UserNotificationLinks.fromJson(json["_links"]),
        embedded: Embedded.fromJson(json["_embedded"]),
      );
}

class Embedded {
  Embedded({
    this.items,
  });

  final List<NotificationItem>? items;

  factory Embedded.fromJson(Map<String, dynamic> json) => Embedded(
        items: json["items"] == null
            ? null
            : List<NotificationItem>.from(
                json["items"].map((x) => NotificationItem.fromJson(x))),
      );
}

class NotificationItem {
  NotificationItem({
    this.excerpt,
    this.status,
    this.sender,
    this.type,
    this.resourceName,
    this.resourceAction,
    this.resourceParams,
    this.content,
    this.uuid,
    this.createdAt,
    this.links,
  });

  final String? excerpt;
  final ItemStatus? status;
  final Sender? sender;
  final Type? type;
  final ResourceName? resourceName;
  final ResourceAction? resourceAction;
  final ResourceParams? resourceParams;
  final String? content;
  final String? uuid;
  final DateTime? createdAt;
  final ItemLinks? links;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        excerpt: json["excerpt"],
        status: itemStatusValues!.map[json["status"]],
        sender: Sender.fromJson(json["sender"]),
        type: typeValues!.map[json["type"]],
        resourceName: resourceNameValues!.map[json["resource_name"]],
        resourceAction: resourceActionValues!.map[json["resource_action"]],
        resourceParams: ResourceParams.fromJson(json["resource_params"]),
        content: json["content"],
        uuid: json["uuid"],
        createdAt: DateTime.parse(json["created_at"]),
        links: ItemLinks.fromJson(json["_links"]),
      );
}

class ItemLinks {
  ItemLinks({
    this.self,
  });

  final First? self;

  factory ItemLinks.fromJson(Map<String, dynamic> json) => ItemLinks(
        self: First.fromJson(json["self"]),
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

enum ResourceAction { CREATED }

final resourceActionValues = EnumValues({"created": ResourceAction.CREATED});

enum ResourceName { POST, POST_COMMENT_LIKE, POST_LIKE, POST_COMMENT }

final resourceNameValues = EnumValues({
  "post": ResourceName.POST,
  "post_comment": ResourceName.POST_COMMENT,
  "post_comment_like": ResourceName.POST_COMMENT_LIKE,
  "post_like": ResourceName.POST_LIKE
});

class ResourceParams {
  ResourceParams({
    this.slug,
    this.uuid,
  });

  final String? slug;
  final String? uuid;

  factory ResourceParams.fromJson(Map<String, dynamic> json) => ResourceParams(
        slug: json["slug"],
        uuid: json["uuid"],
      );
}

class Sender {
  Sender({
    this.username,
    this.status,
    this.currentRank,
    this.currentColor,
    this.verified,
    this.sponsor,
    this.createdAt,
    this.links,
    this.avatar,
    this.background,
    this.sex,
  });

  final String? username;
  final SenderStatus? status;
  final String? currentRank;
  final String? currentColor;
  final bool? verified;
  final bool? sponsor;
  final DateTime? createdAt;
  final SenderLinks? links;
  final Avatar? avatar;
  final Background? background;
  final String? sex;

  factory Sender.fromJson(Map<String, dynamic> json) => Sender(
        username: json["username"],
        status: senderStatusValues!.map[json["status"]],
        currentRank: json["current_rank"],
        currentColor: json["current_color"],
        verified: json["verified"],
        sponsor: json["sponsor"],
        createdAt: DateTime.parse(json["created_at"]),
        links: SenderLinks.fromJson(json["_links"]),
        avatar: json["avatar"] == null ? null : Avatar.fromJson(json["avatar"]),
        background: json["background"] == null
            ? null
            : Background.fromJson(json["background"]),
        sex: json["sex"],
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
        urls: AvatarUrls.fromJson(json["urls"]),
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
        urls: BackgroundUrls.fromJson(json["urls"]),
        uuid: json["uuid"],
        alt: json["alt"],
      );
}

class BackgroundUrls {
  BackgroundUrls({
    this.the400X300,
    this.the1200X900,
  });

  final String? the400X300;
  final String? the1200X900;

  factory BackgroundUrls.fromJson(Map<String, dynamic> json) => BackgroundUrls(
        the400X300: json["400x300"],
        the1200X900: json["1200x900"],
      );
}

class SenderLinks {
  SenderLinks({
    this.self,
    this.follows,
  });

  final First? self;
  final First? follows;

  factory SenderLinks.fromJson(Map<String, dynamic> json) => SenderLinks(
        self: First.fromJson(json["self"]),
        follows: First.fromJson(json["follows"]),
      );
}

enum SenderStatus { ACTIVE }

final senderStatusValues = EnumValues({"active": SenderStatus.ACTIVE});

enum ItemStatus { NEW, READ }

final itemStatusValues =
    EnumValues({"new": ItemStatus.NEW, "read": ItemStatus.READ});

enum Type { RESOURCE }

final typeValues = EnumValues({"resource": Type.RESOURCE});

class UserNotificationLinks {
  UserNotificationLinks({
    this.self,
    this.first,
    this.last,
    this.next,
  });

  final First? self;
  final First? first;
  final First? last;
  final First? next;

  factory UserNotificationLinks.fromJson(Map<String, dynamic> json) =>
      UserNotificationLinks(
        self: First.fromJson(json["self"]),
        first: First.fromJson(json["first"]),
        last: First.fromJson(json["last"]),
        next: First.fromJson(json["next"]),
      );
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String>? get reverse {
    reverseMap ??= map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
