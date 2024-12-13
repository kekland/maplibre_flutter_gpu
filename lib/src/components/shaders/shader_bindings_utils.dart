import 'dart:typed_data';

import 'package:vector_math/vector_math.dart';

int setVector2(int offset, ByteData data, Vector2 vector) {
  data.setFloat32(offset, vector.storage[0], Endian.little);
  data.setFloat32(offset + 4, vector.storage[1], Endian.little);

  return offset + 8;
}

int setVector3(int offset, ByteData data, Vector3 vector) {
  data.setFloat32(offset, vector.storage[0], Endian.little);
  data.setFloat32(offset + 4, vector.storage[1], Endian.little);
  data.setFloat32(offset + 8, vector.storage[2], Endian.little);

  return offset + 12;
}

int setVector4(int offset, ByteData data, Vector4 vector) {
  data.setFloat32(offset, vector.storage[0], Endian.little);
  data.setFloat32(offset + 4, vector.storage[1], Endian.little);
  data.setFloat32(offset + 8, vector.storage[2], Endian.little);
  data.setFloat32(offset + 12, vector.storage[3], Endian.little);

  return offset + 16;
}

int setMatrix4(int offset, ByteData data, Matrix4 matrix) {
  data.setFloat32(offset, matrix.storage[0], Endian.little);
  data.setFloat32(offset + 4, matrix.storage[1], Endian.little);
  data.setFloat32(offset + 8, matrix.storage[2], Endian.little);
  data.setFloat32(offset + 12, matrix.storage[3], Endian.little);
  data.setFloat32(offset + 16, matrix.storage[4], Endian.little);
  data.setFloat32(offset + 20, matrix.storage[5], Endian.little);
  data.setFloat32(offset + 24, matrix.storage[6], Endian.little);
  data.setFloat32(offset + 28, matrix.storage[7], Endian.little);
  data.setFloat32(offset + 32, matrix.storage[8], Endian.little);
  data.setFloat32(offset + 36, matrix.storage[9], Endian.little);
  data.setFloat32(offset + 40, matrix.storage[10], Endian.little);
  data.setFloat32(offset + 44, matrix.storage[11], Endian.little);
  data.setFloat32(offset + 48, matrix.storage[12], Endian.little);
  data.setFloat32(offset + 52, matrix.storage[13], Endian.little);
  data.setFloat32(offset + 56, matrix.storage[14], Endian.little);
  data.setFloat32(offset + 60, matrix.storage[15], Endian.little);

  return offset + 64;
}

int setFloat(int offset, ByteData data, double value) {
  data.setFloat32(offset, value, Endian.little);
  return offset + 4;
}

int setInt(int offset, ByteData data, int value) {
  data.setInt32(offset, value, Endian.little);
  return offset + 4;
}
