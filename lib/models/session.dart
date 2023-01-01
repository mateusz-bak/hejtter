import 'dart:convert';

Session sessionFromJson(String str) => Session.fromJson(json.decode(str));

class Session {
  Session({
    this.user,
    this.expires,
    this.accessToken,
    this.accessTokenExpiry,
  });

  final User? user;
  final DateTime? expires;
  final String? accessToken;
  final int? accessTokenExpiry;

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        expires: json["expires"] == null
            ? null
            : DateTime.parse(
                json["expires"],
              ),
        accessToken: json["accessToken"],
        accessTokenExpiry: json["accessTokenExpiry"],
      );
}

class User {
  User();

  factory User.fromJson(Map<String, dynamic> json) => User();

  Map<String, dynamic> toJson() => {};
}
