import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class IconDataAdapter extends TypeAdapter<IconData> {
  @override
  final int typeId = 3; // 注意，这个 typeId 应该是唯一的，且不同于其他的 typeId

  @override
  IconData read(BinaryReader reader) {
    final int codePoint = reader.readInt();
    final String fontFamily = reader.readString();
    return IconData(codePoint, fontFamily: fontFamily);
  }

  @override
  void write(BinaryWriter writer, IconData obj) {
    writer.writeInt(obj.codePoint);
    writer.writeString(obj.fontFamily ?? '');
  }
}
