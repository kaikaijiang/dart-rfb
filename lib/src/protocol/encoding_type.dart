import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'encoding_type.freezed.dart';

/// Encoding types as defined by RFC 6143.
///
/// See: https://www.rfc-editor.org/rfc/rfc6143.html#section-7.7
@freezed
class RemoteFrameBufferEncodingType with _$RemoteFrameBufferEncodingType {
  const factory RemoteFrameBufferEncodingType.copyRect() =
      RemoteFrameBufferEncodingTypeCopyRect;
  const factory RemoteFrameBufferEncodingType.cursor() =
      RemoteFrameBufferEncodingTypeCursor;
  const factory RemoteFrameBufferEncodingType.desktopSize() =
      RemoteFrameBufferEncodingTypeDesktopSize;
  const factory RemoteFrameBufferEncodingType.raw() =
      RemoteFrameBufferEncodingTypeRaw;
  const factory RemoteFrameBufferEncodingType.unsupported({
    required final ByteData bytes,
    required final int encodingId,
  }) = RemoteFrameBufferEncodingTypeUnsupported;

  /// Parse [bytes].
  factory RemoteFrameBufferEncodingType.fromBytes({
    required final ByteData bytes,
  }) {
    final int encodingId = bytes.getInt32(0);
    switch (encodingId) {
      case -239: // Cursor pseudo-encoding
        return const RemoteFrameBufferEncodingType.cursor();
      case -223: // DesktopSize pseudo-encoding
        return const RemoteFrameBufferEncodingType.desktopSize();
      case 0:
        return const RemoteFrameBufferEncodingType.raw();
      case 1:
        return const RemoteFrameBufferEncodingType.copyRect();
      default:
        return RemoteFrameBufferEncodingType.unsupported(
          bytes: bytes,
          encodingId: encodingId,
        );
    }
  }

  /// Generate byte representation of thie encoding type.
  ByteData toBytes() => ByteData(4)
    ..setInt32(
      0,
      map(
        copyRect: (final _) => 1,
        cursor: (final _) => -239,
        desktopSize: (final _) => -223,
        raw: (final _) => 0,
        unsupported:
            (final RemoteFrameBufferEncodingTypeUnsupported unsupported) =>
                unsupported.encodingId,
      ),
    );

  const RemoteFrameBufferEncodingType._();
}
