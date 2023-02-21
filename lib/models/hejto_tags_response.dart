import 'package:hejtter/models/hejto_tag.dart';

class HejtoTagsResponse {
  int? page;
  int? limit;
  int? pages;
  int? total;
  Links? lLinks;
  Embedded? embedded;

  HejtoTagsResponse(
      {this.page,
      this.limit,
      this.pages,
      this.total,
      this.lLinks,
      this.embedded});

  HejtoTagsResponse.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    pages = json['pages'];
    total = json['total'];
    lLinks = json['_links'] != null ? Links.fromJson(json['_links']) : null;
    embedded =
        json['_embedded'] != null ? Embedded.fromJson(json['_embedded']) : null;
  }
}

class Links {
  Self? self;
  Self? first;
  Self? last;
  Self? next;

  Links({this.self, this.first, this.last, this.next});

  Links.fromJson(Map<String, dynamic> json) {
    self = json['self'] != null ? Self.fromJson(json['self']) : null;
    first = json['first'] != null ? Self.fromJson(json['first']) : null;
    last = json['last'] != null ? Self.fromJson(json['last']) : null;
    next = json['next'] != null ? Self.fromJson(json['next']) : null;
  }
}

class Self {
  String? href;

  Self({this.href});

  Self.fromJson(Map<String, dynamic> json) {
    href = json['href'];
  }
}

class Embedded {
  List<HejtoTag>? items;

  Embedded({this.items});

  Embedded.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <HejtoTag>[];
      json['items'].forEach((v) {
        items!.add(HejtoTag.fromJson(v));
      });
    }
  }
}
