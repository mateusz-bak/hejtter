class Background {
  Background({
    this.urls,
    this.alt,
    this.uuid,
  });

  final BackgroundUrls? urls;
  final Alt? alt;
  final String? uuid;

  factory Background.fromJson(Map<String, dynamic> json) => Background(
        urls:
            json["urls"] == null ? null : BackgroundUrls.fromJson(json["urls"]),
        // alt: json["alt"] == null ? null : altValues.map[json["alt"]],
        uuid: json["uuid"],
      );
}

// final altValues = EnumValues({"blob": Alt.BLOB});
enum Alt { BLOB }

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
