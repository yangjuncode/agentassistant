import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:file_picker/file_picker.dart';

import '../proto/agentassist.pb.dart' as pb;

/// Represents an attachment item for replies
class AttachmentItem {
  final AttachmentType type;
  final String base64Data;
  final String mimeType;
  final String? fileName;
  final Uint8List? thumbnailData;

  AttachmentItem({
    required this.type,
    required this.base64Data,
    required this.mimeType,
    this.fileName,
    this.thumbnailData,
  });

  /// Check if this is an image
  bool get isImage => type == AttachmentType.image;

  /// Check if this is an audio
  bool get isAudio => type == AttachmentType.audio;

  /// Check if this is a file
  bool get isFile => type == AttachmentType.file;

  /// Get display name
  String get displayName {
    if (fileName != null && fileName!.isNotEmpty) {
      return fileName!;
    }
    if (isImage) return 'Image';
    if (isAudio) return 'Audio';
    return 'File';
  }

  /// Convert to McpResultContent for protobuf
  pb.McpResultContent toMcpResultContent() {
    if (isImage) {
      return pb.McpResultContent()
        ..type = 2 // image
        ..image = (pb.ImageContent()
          ..type = 'image'
          ..data = base64Data
          ..mimeType = mimeType);
    } else if (isAudio) {
      return pb.McpResultContent()
        ..type = 3 // audio
        ..audio = (pb.AudioContent()
          ..type = 'audio'
          ..data = base64Data
          ..mimeType = mimeType);
    } else {
      // Use embedded resource for files
      return pb.McpResultContent()
        ..type = 4 // embedded resource
        ..embeddedResource = (pb.EmbeddedResource()
          ..type = 'embedded_resource'
          ..uri = 'file://${fileName ?? "attachment"}'
          ..mimeType = mimeType
          ..data = base64Decode(base64Data));
    }
  }
}

/// Attachment type enum
enum AttachmentType { image, audio, file }

/// Service for handling file and image attachments
class AttachmentService {
  /// Load attachment from file path
  static Future<AttachmentItem?> loadFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('File does not exist: $filePath');
        return null;
      }

      final bytes = await file.readAsBytes();
      final base64Data = base64Encode(bytes);
      final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';
      final fileName = filePath.split(Platform.pathSeparator).last;

      final normalizedMime = mimeType.toLowerCase();
      final isImage = normalizedMime.startsWith('image/');
      final isAudio = normalizedMime.startsWith('audio/');

      return AttachmentItem(
        type: isImage
            ? AttachmentType.image
            : (isAudio ? AttachmentType.audio : AttachmentType.file),
        base64Data: base64Data,
        mimeType: mimeType,
        fileName: fileName,
        thumbnailData: isImage ? bytes : null,
      );
    } catch (e) {
      debugPrint('Error loading file: $e');
      return null;
    }
  }

  /// Load attachment from bytes
  static AttachmentItem? loadFromBytes(
    Uint8List bytes, {
    required String mimeType,
    String? fileName,
  }) {
    try {
      final base64Data = base64Encode(bytes);
      final normalizedMime = mimeType.toLowerCase();
      final isImage = normalizedMime.startsWith('image/');
      final isAudio = normalizedMime.startsWith('audio/');

      return AttachmentItem(
        type: isImage
            ? AttachmentType.image
            : (isAudio ? AttachmentType.audio : AttachmentType.file),
        base64Data: base64Data,
        mimeType: mimeType,
        fileName: fileName,
        thumbnailData: isImage ? bytes : null,
      );
    } catch (e) {
      debugPrint('Error loading from bytes: $e');
      return null;
    }
  }

  /// Load attachment from PlatformFile (file picker result)
  static Future<AttachmentItem?> loadFromPlatformFile(
      PlatformFile platformFile) async {
    try {
      Uint8List? bytes;

      if (platformFile.bytes != null) {
        bytes = platformFile.bytes!;
      } else if (platformFile.path != null) {
        final file = File(platformFile.path!);
        bytes = await file.readAsBytes();
      }

      if (bytes == null) {
        debugPrint('Could not read file bytes');
        return null;
      }

      final base64Data = base64Encode(bytes);
      final mimeType = lookupMimeType(
            platformFile.path ?? platformFile.name,
          ) ??
          'application/octet-stream';
      final normalizedMime = mimeType.toLowerCase();
      final isImage = normalizedMime.startsWith('image/');
      final isAudio = normalizedMime.startsWith('audio/');

      return AttachmentItem(
        type: isImage
            ? AttachmentType.image
            : (isAudio ? AttachmentType.audio : AttachmentType.file),
        base64Data: base64Data,
        mimeType: mimeType,
        fileName: platformFile.name,
        thumbnailData: isImage ? bytes : null,
      );
    } catch (e) {
      debugPrint('Error loading platform file: $e');
      return null;
    }
  }

  /// Load image from clipboard using pasteboard
  static Future<AttachmentItem?> loadFromClipboard() async {
    try {
      // First try to get image from clipboard
      final imageBytes = await Pasteboard.image;
      if (imageBytes != null) {
        return loadFromBytes(
          imageBytes,
          mimeType: 'image/png',
          fileName: 'clipboard_image.png',
        );
      }

      // If no image, try to get files from clipboard
      final files = await Pasteboard.files();
      if (files.isNotEmpty) {
        final filePath = files.first;
        return await loadFromFile(filePath);
      }

      debugPrint('No supported content found in clipboard');
      return null;
    } catch (e) {
      debugPrint('Error reading clipboard: $e');
      return null;
    }
  }

  /// Pick files using file picker
  static Future<List<AttachmentItem>> pickFiles(
      {bool allowMultiple = true}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: allowMultiple,
        type: FileType.any,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      final attachments = <AttachmentItem>[];
      for (final file in result.files) {
        final attachment = await loadFromPlatformFile(file);
        if (attachment != null) {
          attachments.add(attachment);
        }
      }

      return attachments;
    } catch (e) {
      debugPrint('Error picking files: $e');
      return [];
    }
  }

  /// Pick images using file picker
  static Future<List<AttachmentItem>> pickImages(
      {bool allowMultiple = true}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: allowMultiple,
        type: FileType.image,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      final attachments = <AttachmentItem>[];
      for (final file in result.files) {
        final attachment = await loadFromPlatformFile(file);
        if (attachment != null) {
          attachments.add(attachment);
        }
      }

      return attachments;
    } catch (e) {
      debugPrint('Error picking images: $e');
      return [];
    }
  }
}
