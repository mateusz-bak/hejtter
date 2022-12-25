import 'dart:convert';

UserDetailsResponse userDetailsResponseFromJson(String str) =>
    UserDetailsResponse.fromJson(json.decode(str));

class UserDetailsResponse {
  UserDetailsResponse({
    this.username,
    this.avatar,
    this.background,
    this.status,
    this.achievements,
    this.stats,
    this.interactions,
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
  final String? status;
  final List<AchievementElement>? achievements;
  final Stats? stats;
  final Interactions? interactions;
  final String? currentRank;
  final String? currentColor;
  final bool? verified;
  final bool? sponsor;
  final DateTime? createdAt;
  final UserDetailsResponseLinks? links;

  factory UserDetailsResponse.fromJson(Map<String, dynamic> json) =>
      UserDetailsResponse(
        username: json["username"],
        avatar: json["avatar"] == null ? null : Avatar.fromJson(json["avatar"]),
        background: json["background"] == null
            ? null
            : Background.fromJson(json["background"]),
        status: json["status"],
        achievements: json["achievements"] == null
            ? null
            : List<AchievementElement>.from(json["achievements"]
                .map((x) => AchievementElement.fromJson(x))),
        stats: json["stats"] == null ? null : Stats.fromJson(json["stats"]),
        interactions: json["interactions"] == null
            ? null
            : Interactions.fromJson(json["interactions"]),
        currentRank: json["current_rank"],
        currentColor: json["current_color"],
        verified: json["verified"],
        sponsor: json["sponsor"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        links: json["_links"] == null
            ? null
            : UserDetailsResponseLinks.fromJson(json["_links"]),
      );
}

class AchievementElement {
  AchievementElement({
    this.achievement,
    this.createdAt,
  });

  final AchievementAchievement? achievement;
  final DateTime? createdAt;

  factory AchievementElement.fromJson(Map<String, dynamic> json) =>
      AchievementElement(
        achievement: json["achievement"] == null
            ? null
            : AchievementAchievement.fromJson(json["achievement"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );
}

class AchievementAchievement {
  AchievementAchievement({
    this.name,
    this.slug,
    this.description,
    this.icon,
    this.createdAt,
    this.links,
  });

  final String? name;
  final String? slug;
  final String? description;
  final UserIcon? icon;
  final DateTime? createdAt;
  final AchievementLinks? links;

  factory AchievementAchievement.fromJson(Map<String, dynamic> json) =>
      AchievementAchievement(
        name: json["name"],
        slug: json["slug"],
        description: json["description"],
        icon: json["icon"] == null ? null : UserIcon.fromJson(json["icon"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        links: json["_links"] == null
            ? null
            : AchievementLinks.fromJson(json["_links"]),
      );
}

class UserIcon {
  UserIcon({
    this.urls,
    this.alt,
    this.uuid,
  });

  final IconUrls? urls;
  final String? alt;
  final String? uuid;

  factory UserIcon.fromJson(Map<String, dynamic> json) => UserIcon(
        urls: json["urls"] == null ? null : IconUrls.fromJson(json["urls"]),
        alt: json["alt"],
        uuid: json["uuid"],
      );
}

class IconUrls {
  IconUrls({
    this.the50X50,
    this.the250X250,
  });

  final String? the50X50;
  final String? the250X250;

  factory IconUrls.fromJson(Map<String, dynamic> json) => IconUrls(
        the50X50: json["50x50"],
        the250X250: json["250x250"],
      );
}

class AchievementLinks {
  AchievementLinks({
    this.self,
  });

  final Follows? self;

  factory AchievementLinks.fromJson(Map<String, dynamic> json) =>
      AchievementLinks(
        self: json["self"] == null ? null : Follows.fromJson(json["self"]),
      );
}

class Follows {
  Follows({
    this.href,
  });

  final String? href;

  factory Follows.fromJson(Map<String, dynamic> json) => Follows(
        href: json["href"],
      );
}

class Avatar {
  Avatar({
    this.urls,
    this.alt,
    this.uuid,
  });

  final AvatarUrls? urls;
  final String? alt;
  final String? uuid;

  factory Avatar.fromJson(Map<String, dynamic> json) => Avatar(
        urls: json["urls"] == null ? null : AvatarUrls.fromJson(json["urls"]),
        alt: json["alt"],
        uuid: json["uuid"],
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

  Map<String, dynamic> toJson() => {
        "100x100": the100X100,
        "250x250": the250X250,
      };
}

class Background {
  Background({
    this.urls,
    this.alt,
    this.uuid,
  });

  final BackgroundUrls? urls;
  final String? alt;
  final String? uuid;

  factory Background.fromJson(Map<String, dynamic> json) => Background(
        urls:
            json["urls"] == null ? null : BackgroundUrls.fromJson(json["urls"]),
        alt: json["alt"],
        uuid: json["uuid"],
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

class Interactions {
  Interactions({
    this.isFollowed,
    this.isBlocked,
  });

  final bool? isFollowed;
  final bool? isBlocked;

  factory Interactions.fromJson(Map<String, dynamic> json) => Interactions(
        isFollowed: json["is_followed"],
        isBlocked: json["is_blocked"],
      );
}

class UserDetailsResponseLinks {
  UserDetailsResponseLinks({
    this.self,
    this.follows,
  });

  final Follows? self;
  final Follows? follows;

  factory UserDetailsResponseLinks.fromJson(Map<String, dynamic> json) =>
      UserDetailsResponseLinks(
        self: json["self"] == null ? null : Follows.fromJson(json["self"]),
        follows:
            json["follows"] == null ? null : Follows.fromJson(json["follows"]),
      );
}

class Stats {
  Stats({
    this.numFollows,
    this.numPosts,
    this.numComments,
  });

  final int? numFollows;
  final int? numPosts;
  final int? numComments;

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
        numFollows: json["num_follows"],
        numPosts: json["num_posts"],
        numComments: json["num_comments"],
      );
}
