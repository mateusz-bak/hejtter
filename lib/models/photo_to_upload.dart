import 'package:flutter/foundation.dart';

class PhotoToUpload {
  PhotoToUpload({
    required this.bytes,
    required this.position,
    this.uuid,
  });

  final Uint8List bytes;
  final int position;
  final String? uuid;

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'position': position,
      };
}
