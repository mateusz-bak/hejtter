class HejtoUsersResponse {
  Embedded? eEmbedded;

  HejtoUsersResponse({this.eEmbedded});

  HejtoUsersResponse.fromJson(Map<String, dynamic> json) {
    eEmbedded =
        json['_embedded'] != null ? Embedded.fromJson(json['_embedded']) : null;
  }
}

class Embedded {
  List<HejtoUser>? items;

  Embedded({this.items});

  Embedded.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <HejtoUser>[];
      json['items'].forEach((v) {
        items!.add(HejtoUser.fromJson(v));
      });
    }
  }
}

class HejtoUser {
  String? username;
  String? status;
  bool? controversial;
  Stats? stats;
  Interactions? interactions;
  String? currentRank;
  String? currentColor;
  bool? verified;
  bool? sponsor;
  String? createdAt;
  Links? lLinks;
  Avatar? avatar;

  HejtoUser(
      {this.username,
      this.status,
      this.controversial,
      this.stats,
      this.interactions,
      this.currentRank,
      this.currentColor,
      this.verified,
      this.sponsor,
      this.createdAt,
      this.lLinks,
      this.avatar});

  HejtoUser.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    status = json['status'];
    controversial = json['controversial'];
    stats = json['stats'] != null ? Stats.fromJson(json['stats']) : null;
    interactions = json['interactions'] != null
        ? Interactions.fromJson(json['interactions'])
        : null;
    currentRank = json['current_rank'];
    currentColor = json['current_color'];
    verified = json['verified'];
    sponsor = json['sponsor'];
    createdAt = json['created_at'];
    lLinks = json['_links'] != null ? Links.fromJson(json['_links']) : null;
    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
  }
}

class Stats {
  int? numFollows;
  int? numPosts;
  int? numComments;
  int? numCommunityMembers;

  Stats(
      {this.numFollows,
      this.numPosts,
      this.numComments,
      this.numCommunityMembers});

  Stats.fromJson(Map<String, dynamic> json) {
    numFollows = json['num_follows'];
    numPosts = json['num_posts'];
    numComments = json['num_comments'];
    numCommunityMembers = json['num_community_members'];
  }
}

class Interactions {
  bool? isFollowed;
  bool? isBlocked;

  Interactions({this.isFollowed, this.isBlocked});

  Interactions.fromJson(Map<String, dynamic> json) {
    isFollowed = json['is_followed'];
    isBlocked = json['is_blocked'];
  }
}

class Links {
  Self? self;
  Self? follows;

  Links({this.self, this.follows});

  Links.fromJson(Map<String, dynamic> json) {
    self = json['self'] != null ? Self.fromJson(json['self']) : null;
    follows = json['follows'] != null ? Self.fromJson(json['follows']) : null;
  }
}

class Self {
  String? href;

  Self({this.href});

  Self.fromJson(Map<String, dynamic> json) {
    href = json['href'];
  }
}

class Avatar {
  Urls? urls;
  String? uuid;

  Avatar({this.urls, this.uuid});

  Avatar.fromJson(Map<String, dynamic> json) {
    urls = json['urls'] != null ? Urls.fromJson(json['urls']) : null;
    uuid = json['uuid'];
  }
}

class Urls {
  String? s100x100;
  String? s250x250;

  Urls({this.s100x100, this.s250x250});

  Urls.fromJson(Map<String, dynamic> json) {
    s100x100 = json['100x100'];
    s250x250 = json['250x250'];
  }
}
