import 'dart:convert';

Account accountFromJson(String str) => Account.fromJson(json.decode(str));

class Account {
  Account({
    this.passwordSet,
    this.canChangeUsername,
    this.username,
    this.email,
    this.avatar,
    this.background,
    this.status,
    this.passwordRequestedAt,
    this.passwordChangedAt,
    this.roles,
    this.accountStats,
    this.lastActivity,
    this.referralCode,
    this.currentRank,
    this.currentColor,
    this.nextRank,
    this.nextColor,
    this.rankProgress,
    this.verified,
    this.sponsor,
    this.theme,
    this.showNsfw,
    this.showControversial,
    this.blurNsfw,
    this.createdAt,
    this.links,
  });

  final bool? passwordSet;
  final bool? canChangeUsername;
  final String? username;
  final String? email;
  final Avatar? avatar;
  final Background? background;
  final String? status;
  final DateTime? passwordRequestedAt;
  final DateTime? passwordChangedAt;
  final List<String>? roles;
  final AccountStats? accountStats;
  final DateTime? lastActivity;
  final String? referralCode;
  final String? currentRank;
  final String? currentColor;
  final String? nextRank;
  final String? nextColor;
  final String? rankProgress;
  final bool? verified;
  final bool? sponsor;
  final String? theme;
  final bool? showNsfw;
  final bool? showControversial;
  final bool? blurNsfw;
  final DateTime? createdAt;
  final Links? links;

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        passwordSet: json["password_set"],
        canChangeUsername: json["can_change_username"],
        username: json["username"],
        email: json["email"],
        avatar: json["avatar"] == null ? null : Avatar.fromJson(json["avatar"]),
        background: json["background"] == null
            ? null
            : Background.fromJson(json["background"]),
        status: json["status"],
        passwordRequestedAt: json["password_requested_at"] == null
            ? null
            : DateTime.parse(json["password_requested_at"]),
        passwordChangedAt: json["password_changed_at"] == null
            ? null
            : DateTime.parse(json["password_changed_at"]),
        roles: json["roles"] == null
            ? null
            : List<String>.from(json["roles"].map((x) => x)),
        accountStats: json["account_stats"] == null
            ? null
            : AccountStats.fromJson(json["account_stats"]),
        lastActivity: json["last_activity"] == null
            ? null
            : DateTime.parse(json["last_activity"]),
        referralCode: json["referral_code"],
        currentRank: json["current_rank"],
        currentColor: json["current_color"],
        nextRank: json["next_rank"],
        nextColor: json["next_color"],
        rankProgress: json["rank_progress"],
        verified: json["verified"],
        sponsor: json["sponsor"],
        theme: json["theme"],
        showNsfw: json["show_nsfw"],
        showControversial: json["show_controversial"],
        blurNsfw: json["blur_nsfw"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        links: json["_links"] == null ? null : Links.fromJson(json["_links"]),
      );
}

class AccountStats {
  AccountStats({
    this.numUnreadNotifications,
    this.numUnreadConversations,
    this.numPosts,
    this.numComments,
    this.numFollows,
    this.sumScores,
  });

  final int? numUnreadNotifications;
  final int? numUnreadConversations;
  final int? numPosts;
  final int? numComments;
  final int? numFollows;
  final int? sumScores;

  factory AccountStats.fromJson(Map<String, dynamic> json) => AccountStats(
        numUnreadNotifications: json["num_unread_notifications"],
        numUnreadConversations: json["num_unread_conversations"],
        numPosts: json["num_posts"],
        numComments: json["num_comments"],
        numFollows: json["num_follows"],
        sumScores: json["sum_scores"],
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
}

class Background {
  Background({
    this.urls,
    this.uuid,
  });

  final BackgroundUrls? urls;
  final String? uuid;

  factory Background.fromJson(Map<String, dynamic> json) => Background(
        urls:
            json["urls"] == null ? null : BackgroundUrls.fromJson(json["urls"]),
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

class Links {
  Links({
    this.account,
    this.notifications,
    this.self,
  });

  final AccountClass? account;
  final AccountClass? notifications;
  final AccountClass? self;

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        account: json["account"] == null
            ? null
            : AccountClass.fromJson(json["account"]),
        notifications: json["notifications"] == null
            ? null
            : AccountClass.fromJson(json["notifications"]),
        self: json["self"] == null ? null : AccountClass.fromJson(json["self"]),
      );
}

class AccountClass {
  AccountClass({
    this.href,
  });

  final String? href;

  factory AccountClass.fromJson(Map<String, dynamic> json) => AccountClass(
        href: json["href"],
      );
}
