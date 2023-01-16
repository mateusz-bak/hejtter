class Avatar {
  Avatar({
    this.urls,
    this.alt,
    this.uuid,
  });

  final AvatarUrls? urls;
  final Alt? alt;
  final String? uuid;

  factory Avatar.fromJson(Map<String, dynamic> json) => Avatar(
        urls: json["urls"] == null ? null : AvatarUrls.fromJson(json["urls"]),
        // alt: json["alt"] == null ? null : altValues.map[json["alt"]],
        uuid: json["uuid"],
      );
}

// final altValues = EnumValues({"blob": Alt.BLOB});
enum Alt { BLOB }

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
