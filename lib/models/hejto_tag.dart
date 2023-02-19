class HejtoTag {
  String? name;
  bool? controversial;
  bool? warContent;
  bool? nsfw;
  int? numFollows;
  int? numPosts;
  bool? isFollowed;
  bool? isBlocked;
  Links? lLinks;

  HejtoTag(
      {this.name,
      this.controversial,
      this.warContent,
      this.nsfw,
      this.numFollows,
      this.numPosts,
      this.isFollowed,
      this.isBlocked,
      this.lLinks});

  HejtoTag.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    controversial = json['controversial'];
    warContent = json['war_content'];
    nsfw = json['nsfw'];
    numFollows = json['num_follows'];
    numPosts = json['num_posts'];
    isFollowed = json['is_followed'];
    isBlocked = json['is_blocked'];
    lLinks = json['_links'] != null ? Links.fromJson(json['_links']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['controversial'] = controversial;
    data['war_content'] = warContent;
    data['nsfw'] = nsfw;
    data['num_follows'] = numFollows;
    data['num_posts'] = numPosts;
    data['is_followed'] = isFollowed;
    data['is_blocked'] = isBlocked;
    if (lLinks != null) {
      data['_links'] = lLinks!.toJson();
    }
    return data;
  }
}

class Links {
  Self? self;
  Self? follows;
  Self? blocks;

  Links({this.self, this.follows, this.blocks});

  Links.fromJson(Map<String, dynamic> json) {
    self = json['self'] != null ? Self.fromJson(json['self']) : null;
    follows = json['follows'] != null ? Self.fromJson(json['follows']) : null;
    blocks = json['blocks'] != null ? Self.fromJson(json['blocks']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (self != null) {
      data['self'] = self!.toJson();
    }
    if (follows != null) {
      data['follows'] = follows!.toJson();
    }
    if (blocks != null) {
      data['blocks'] = blocks!.toJson();
    }
    return data;
  }
}

class Self {
  String? href;

  Self({this.href});

  Self.fromJson(Map<String, dynamic> json) {
    href = json['href'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['href'] = href;
    return data;
  }
}
