// This is a generated file - do not edit.
//
// Generated from agentassist.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'agentassist.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'agentassist.pbenum.dart';

/// TextContent represents text provided to or from an LLM.
/// It must have Type set to "text".
class TextContent extends $pb.GeneratedMessage {
  factory TextContent({
    $core.String? type,
    $core.String? text,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (text != null) result.text = text;
    return result;
  }

  TextContent._();

  factory TextContent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TextContent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TextContent',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TextContent clone() => TextContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TextContent copyWith(void Function(TextContent) updates) =>
      super.copyWith((message) => updates(message as TextContent))
          as TextContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TextContent create() => TextContent._();
  @$core.override
  TextContent createEmptyInstance() => create();
  static $pb.PbList<TextContent> createRepeated() => $pb.PbList<TextContent>();
  @$core.pragma('dart2js:noInline')
  static TextContent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TextContent>(create);
  static TextContent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => $_clearField(2);
}

/// ImageContent represents an image provided to or from an LLM.
/// It must have Type set to "image".
class ImageContent extends $pb.GeneratedMessage {
  factory ImageContent({
    $core.String? type,
    $core.String? data,
    $core.String? mimeType,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (data != null) result.data = data;
    if (mimeType != null) result.mimeType = mimeType;
    return result;
  }

  ImageContent._();

  factory ImageContent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImageContent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImageContent',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'data')
    ..aOS(3, _omitFieldNames ? '' : 'mimeType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageContent clone() => ImageContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageContent copyWith(void Function(ImageContent) updates) =>
      super.copyWith((message) => updates(message as ImageContent))
          as ImageContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImageContent create() => ImageContent._();
  @$core.override
  ImageContent createEmptyInstance() => create();
  static $pb.PbList<ImageContent> createRepeated() =>
      $pb.PbList<ImageContent>();
  @$core.pragma('dart2js:noInline')
  static ImageContent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImageContent>(create);
  static ImageContent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get data => $_getSZ(1);
  @$pb.TagNumber(2)
  set data($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get mimeType => $_getSZ(2);
  @$pb.TagNumber(3)
  set mimeType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMimeType() => $_has(2);
  @$pb.TagNumber(3)
  void clearMimeType() => $_clearField(3);
}

/// AudioContent represents audio data provided to or from an LLM.
/// It must have Type set to "audio".
class AudioContent extends $pb.GeneratedMessage {
  factory AudioContent({
    $core.String? type,
    $core.String? data,
    $core.String? mimeType,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (data != null) result.data = data;
    if (mimeType != null) result.mimeType = mimeType;
    return result;
  }

  AudioContent._();

  factory AudioContent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AudioContent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AudioContent',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'data')
    ..aOS(3, _omitFieldNames ? '' : 'mimeType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AudioContent clone() => AudioContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AudioContent copyWith(void Function(AudioContent) updates) =>
      super.copyWith((message) => updates(message as AudioContent))
          as AudioContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AudioContent create() => AudioContent._();
  @$core.override
  AudioContent createEmptyInstance() => create();
  static $pb.PbList<AudioContent> createRepeated() =>
      $pb.PbList<AudioContent>();
  @$core.pragma('dart2js:noInline')
  static AudioContent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AudioContent>(create);
  static AudioContent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get data => $_getSZ(1);
  @$pb.TagNumber(2)
  set data($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get mimeType => $_getSZ(2);
  @$pb.TagNumber(3)
  set mimeType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMimeType() => $_has(2);
  @$pb.TagNumber(3)
  void clearMimeType() => $_clearField(3);
}

/// EmbeddedResource represents a resource embedded into a prompt or tool call
/// result. It must have Type set to "embedded_resource".
class EmbeddedResource extends $pb.GeneratedMessage {
  factory EmbeddedResource({
    $core.String? type,
    $core.String? uri,
    $core.String? mimeType,
    $core.List<$core.int>? data,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (uri != null) result.uri = uri;
    if (mimeType != null) result.mimeType = mimeType;
    if (data != null) result.data = data;
    return result;
  }

  EmbeddedResource._();

  factory EmbeddedResource.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EmbeddedResource.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EmbeddedResource',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'uri')
    ..aOS(3, _omitFieldNames ? '' : 'mimeType')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EmbeddedResource clone() => EmbeddedResource()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EmbeddedResource copyWith(void Function(EmbeddedResource) updates) =>
      super.copyWith((message) => updates(message as EmbeddedResource))
          as EmbeddedResource;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EmbeddedResource create() => EmbeddedResource._();
  @$core.override
  EmbeddedResource createEmptyInstance() => create();
  static $pb.PbList<EmbeddedResource> createRepeated() =>
      $pb.PbList<EmbeddedResource>();
  @$core.pragma('dart2js:noInline')
  static EmbeddedResource getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EmbeddedResource>(create);
  static EmbeddedResource? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get uri => $_getSZ(1);
  @$pb.TagNumber(2)
  set uri($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUri() => $_has(1);
  @$pb.TagNumber(2)
  void clearUri() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get mimeType => $_getSZ(2);
  @$pb.TagNumber(3)
  set mimeType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMimeType() => $_has(2);
  @$pb.TagNumber(3)
  void clearMimeType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get data => $_getN(3);
  @$pb.TagNumber(4)
  set data($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasData() => $_has(3);
  @$pb.TagNumber(4)
  void clearData() => $_clearField(4);
}

class McpResultContent extends $pb.GeneratedMessage {
  factory McpResultContent({
    $core.int? type,
    TextContent? text,
    ImageContent? image,
    AudioContent? audio,
    EmbeddedResource? embeddedResource,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (text != null) result.text = text;
    if (image != null) result.image = image;
    if (audio != null) result.audio = audio;
    if (embeddedResource != null) result.embeddedResource = embeddedResource;
    return result;
  }

  McpResultContent._();

  factory McpResultContent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory McpResultContent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'McpResultContent',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.O3)
    ..aOM<TextContent>(2, _omitFieldNames ? '' : 'text',
        subBuilder: TextContent.create)
    ..aOM<ImageContent>(3, _omitFieldNames ? '' : 'image',
        subBuilder: ImageContent.create)
    ..aOM<AudioContent>(4, _omitFieldNames ? '' : 'audio',
        subBuilder: AudioContent.create)
    ..aOM<EmbeddedResource>(5, _omitFieldNames ? '' : 'embeddedResource',
        subBuilder: EmbeddedResource.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpResultContent clone() => McpResultContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpResultContent copyWith(void Function(McpResultContent) updates) =>
      super.copyWith((message) => updates(message as McpResultContent))
          as McpResultContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static McpResultContent create() => McpResultContent._();
  @$core.override
  McpResultContent createEmptyInstance() => create();
  static $pb.PbList<McpResultContent> createRepeated() =>
      $pb.PbList<McpResultContent>();
  @$core.pragma('dart2js:noInline')
  static McpResultContent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<McpResultContent>(create);
  static McpResultContent? _defaultInstance;

  /// content type
  ///  1: text
  ///  2: image
  ///  3: audio
  ///  4: embedded resource
  @$pb.TagNumber(1)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(1)
  set type($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  /// text
  @$pb.TagNumber(2)
  TextContent get text => $_getN(1);
  @$pb.TagNumber(2)
  set text(TextContent value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => $_clearField(2);
  @$pb.TagNumber(2)
  TextContent ensureText() => $_ensure(1);

  /// image
  @$pb.TagNumber(3)
  ImageContent get image => $_getN(2);
  @$pb.TagNumber(3)
  set image(ImageContent value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasImage() => $_has(2);
  @$pb.TagNumber(3)
  void clearImage() => $_clearField(3);
  @$pb.TagNumber(3)
  ImageContent ensureImage() => $_ensure(2);

  /// audio
  @$pb.TagNumber(4)
  AudioContent get audio => $_getN(3);
  @$pb.TagNumber(4)
  set audio(AudioContent value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasAudio() => $_has(3);
  @$pb.TagNumber(4)
  void clearAudio() => $_clearField(4);
  @$pb.TagNumber(4)
  AudioContent ensureAudio() => $_ensure(3);

  /// embedded resource
  @$pb.TagNumber(5)
  EmbeddedResource get embeddedResource => $_getN(4);
  @$pb.TagNumber(5)
  set embeddedResource(EmbeddedResource value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasEmbeddedResource() => $_has(4);
  @$pb.TagNumber(5)
  void clearEmbeddedResource() => $_clearField(5);
  @$pb.TagNumber(5)
  EmbeddedResource ensureEmbeddedResource() => $_ensure(4);
}

class MsgEmpty extends $pb.GeneratedMessage {
  factory MsgEmpty() => create();

  MsgEmpty._();

  factory MsgEmpty.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MsgEmpty.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MsgEmpty',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MsgEmpty clone() => MsgEmpty()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MsgEmpty copyWith(void Function(MsgEmpty) updates) =>
      super.copyWith((message) => updates(message as MsgEmpty)) as MsgEmpty;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MsgEmpty create() => MsgEmpty._();
  @$core.override
  MsgEmpty createEmptyInstance() => create();
  static $pb.PbList<MsgEmpty> createRepeated() => $pb.PbList<MsgEmpty>();
  @$core.pragma('dart2js:noInline')
  static MsgEmpty getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgEmpty>(create);
  static MsgEmpty? _defaultInstance;
}

class Option extends $pb.GeneratedMessage {
  factory Option({
    $core.String? label,
    $core.String? description,
  }) {
    final result = create();
    if (label != null) result.label = label;
    if (description != null) result.description = description;
    return result;
  }

  Option._();

  factory Option.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Option.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Option',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'label')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Option clone() => Option()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Option copyWith(void Function(Option) updates) =>
      super.copyWith((message) => updates(message as Option)) as Option;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Option create() => Option._();
  @$core.override
  Option createEmptyInstance() => create();
  static $pb.PbList<Option> createRepeated() => $pb.PbList<Option>();
  @$core.pragma('dart2js:noInline')
  static Option getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Option>(create);
  static Option? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get label => $_getSZ(0);
  @$pb.TagNumber(1)
  set label($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLabel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLabel() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);
}

class Question extends $pb.GeneratedMessage {
  factory Question({
    $core.String? question,
    $core.String? header,
    $core.Iterable<Option>? options,
    $core.bool? multiple,
    $core.bool? custom,
  }) {
    final result = create();
    if (question != null) result.question = question;
    if (header != null) result.header = header;
    if (options != null) result.options.addAll(options);
    if (multiple != null) result.multiple = multiple;
    if (custom != null) result.custom = custom;
    return result;
  }

  Question._();

  factory Question.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Question.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Question',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'question')
    ..aOS(2, _omitFieldNames ? '' : 'header')
    ..pc<Option>(3, _omitFieldNames ? '' : 'options', $pb.PbFieldType.PM,
        subBuilder: Option.create)
    ..aOB(4, _omitFieldNames ? '' : 'multiple')
    ..aOB(5, _omitFieldNames ? '' : 'custom')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Question clone() => Question()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Question copyWith(void Function(Question) updates) =>
      super.copyWith((message) => updates(message as Question)) as Question;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Question create() => Question._();
  @$core.override
  Question createEmptyInstance() => create();
  static $pb.PbList<Question> createRepeated() => $pb.PbList<Question>();
  @$core.pragma('dart2js:noInline')
  static Question getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Question>(create);
  static Question? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get question => $_getSZ(0);
  @$pb.TagNumber(1)
  set question($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuestion() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuestion() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get header => $_getSZ(1);
  @$pb.TagNumber(2)
  set header($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHeader() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeader() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<Option> get options => $_getList(2);

  @$pb.TagNumber(4)
  $core.bool get multiple => $_getBF(3);
  @$pb.TagNumber(4)
  set multiple($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMultiple() => $_has(3);
  @$pb.TagNumber(4)
  void clearMultiple() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get custom => $_getBF(4);
  @$pb.TagNumber(5)
  set custom($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCustom() => $_has(4);
  @$pb.TagNumber(5)
  void clearCustom() => $_clearField(5);
}

class McpAskQuestionRequest extends $pb.GeneratedMessage {
  factory McpAskQuestionRequest({
    $core.String? projectDirectory,
    @$core.Deprecated('This field is deprecated.') $core.String? question,
    $core.int? timeout,
    $core.String? agentName,
    $core.String? reasoningModelName,
    $core.String? mcpClientName,
    $core.Iterable<Question>? questions,
  }) {
    final result = create();
    if (projectDirectory != null) result.projectDirectory = projectDirectory;
    if (question != null) result.question = question;
    if (timeout != null) result.timeout = timeout;
    if (agentName != null) result.agentName = agentName;
    if (reasoningModelName != null)
      result.reasoningModelName = reasoningModelName;
    if (mcpClientName != null) result.mcpClientName = mcpClientName;
    if (questions != null) result.questions.addAll(questions);
    return result;
  }

  McpAskQuestionRequest._();

  factory McpAskQuestionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory McpAskQuestionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'McpAskQuestionRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ProjectDirectory',
        protoName: 'ProjectDirectory')
    ..aOS(2, _omitFieldNames ? '' : 'Question', protoName: 'Question')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'Timeout', $pb.PbFieldType.O3,
        protoName: 'Timeout')
    ..aOS(4, _omitFieldNames ? '' : 'AgentName', protoName: 'AgentName')
    ..aOS(5, _omitFieldNames ? '' : 'ReasoningModelName',
        protoName: 'ReasoningModelName')
    ..aOS(6, _omitFieldNames ? '' : 'McpClientName', protoName: 'McpClientName')
    ..pc<Question>(7, _omitFieldNames ? '' : 'Questions', $pb.PbFieldType.PM,
        protoName: 'Questions', subBuilder: Question.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpAskQuestionRequest clone() =>
      McpAskQuestionRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpAskQuestionRequest copyWith(
          void Function(McpAskQuestionRequest) updates) =>
      super.copyWith((message) => updates(message as McpAskQuestionRequest))
          as McpAskQuestionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static McpAskQuestionRequest create() => McpAskQuestionRequest._();
  @$core.override
  McpAskQuestionRequest createEmptyInstance() => create();
  static $pb.PbList<McpAskQuestionRequest> createRepeated() =>
      $pb.PbList<McpAskQuestionRequest>();
  @$core.pragma('dart2js:noInline')
  static McpAskQuestionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<McpAskQuestionRequest>(create);
  static McpAskQuestionRequest? _defaultInstance;

  /// current project directory
  @$pb.TagNumber(1)
  $core.String get projectDirectory => $_getSZ(0);
  @$pb.TagNumber(1)
  set projectDirectory($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProjectDirectory() => $_has(0);
  @$pb.TagNumber(1)
  void clearProjectDirectory() => $_clearField(1);

  /// ai agent's question
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  $core.String get question => $_getSZ(1);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  set question($core.String value) => $_setString(1, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  $core.bool hasQuestion() => $_has(1);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  void clearQuestion() => $_clearField(2);

  /// timeout in seconds, default is 600s
  @$pb.TagNumber(3)
  $core.int get timeout => $_getIZ(2);
  @$pb.TagNumber(3)
  set timeout($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimeout() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimeout() => $_clearField(3);

  /// the AI agent/client name that is calling this tool (e.g., Antigravity,
  /// Cascade)
  @$pb.TagNumber(4)
  $core.String get agentName => $_getSZ(3);
  @$pb.TagNumber(4)
  set agentName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAgentName() => $_has(3);
  @$pb.TagNumber(4)
  void clearAgentName() => $_clearField(4);

  /// the actual LLM/inference model name being used (e.g., GPT-4, Gemini 3 Pro)
  @$pb.TagNumber(5)
  $core.String get reasoningModelName => $_getSZ(4);
  @$pb.TagNumber(5)
  set reasoningModelName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReasoningModelName() => $_has(4);
  @$pb.TagNumber(5)
  void clearReasoningModelName() => $_clearField(5);

  /// MCP client name from initialize.clientInfo.name (e.g., windsurf)
  @$pb.TagNumber(6)
  $core.String get mcpClientName => $_getSZ(5);
  @$pb.TagNumber(6)
  set mcpClientName($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMcpClientName() => $_has(5);
  @$pb.TagNumber(6)
  void clearMcpClientName() => $_clearField(6);

  /// ai agent's questions
  @$pb.TagNumber(7)
  $pb.PbList<Question> get questions => $_getList(6);
}

class AskQuestionRequest extends $pb.GeneratedMessage {
  factory AskQuestionRequest({
    $core.String? iD,
    $core.String? userToken,
    McpAskQuestionRequest? request,
    $fixnum.Int64? timestamp,
    $core.String? sessionId,
  }) {
    final result = create();
    if (iD != null) result.iD = iD;
    if (userToken != null) result.userToken = userToken;
    if (request != null) result.request = request;
    if (timestamp != null) result.timestamp = timestamp;
    if (sessionId != null) result.sessionId = sessionId;
    return result;
  }

  AskQuestionRequest._();

  factory AskQuestionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AskQuestionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AskQuestionRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ID', protoName: 'ID')
    ..aOS(2, _omitFieldNames ? '' : 'UserToken', protoName: 'UserToken')
    ..aOM<McpAskQuestionRequest>(3, _omitFieldNames ? '' : 'Request',
        protoName: 'Request', subBuilder: McpAskQuestionRequest.create)
    ..aInt64(4, _omitFieldNames ? '' : 'Timestamp', protoName: 'Timestamp')
    ..aOS(5, _omitFieldNames ? '' : 'SessionId', protoName: 'SessionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AskQuestionRequest clone() => AskQuestionRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AskQuestionRequest copyWith(void Function(AskQuestionRequest) updates) =>
      super.copyWith((message) => updates(message as AskQuestionRequest))
          as AskQuestionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AskQuestionRequest create() => AskQuestionRequest._();
  @$core.override
  AskQuestionRequest createEmptyInstance() => create();
  static $pb.PbList<AskQuestionRequest> createRepeated() =>
      $pb.PbList<AskQuestionRequest>();
  @$core.pragma('dart2js:noInline')
  static AskQuestionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AskQuestionRequest>(create);
  static AskQuestionRequest? _defaultInstance;

  /// request id
  @$pb.TagNumber(1)
  $core.String get iD => $_getSZ(0);
  @$pb.TagNumber(1)
  set iD($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasID() => $_has(0);
  @$pb.TagNumber(1)
  void clearID() => $_clearField(1);

  /// user token
  @$pb.TagNumber(2)
  $core.String get userToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set userToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserToken() => $_clearField(2);

  /// ai agent's question
  @$pb.TagNumber(3)
  McpAskQuestionRequest get request => $_getN(2);
  @$pb.TagNumber(3)
  set request(McpAskQuestionRequest value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasRequest() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequest() => $_clearField(3);
  @$pb.TagNumber(3)
  McpAskQuestionRequest ensureRequest() => $_ensure(2);

  /// timestamp (UTC)
  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);

  /// initiator (mcp process) session id, used for liveness tracking
  @$pb.TagNumber(5)
  $core.String get sessionId => $_getSZ(4);
  @$pb.TagNumber(5)
  set sessionId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSessionId() => $_has(4);
  @$pb.TagNumber(5)
  void clearSessionId() => $_clearField(5);
}

class AskQuestionResponse extends $pb.GeneratedMessage {
  factory AskQuestionResponse({
    $core.String? iD,
    $core.bool? isError,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? meta,
    $core.Iterable<McpResultContent>? contents,
  }) {
    final result = create();
    if (iD != null) result.iD = iD;
    if (isError != null) result.isError = isError;
    if (meta != null) result.meta.addEntries(meta);
    if (contents != null) result.contents.addAll(contents);
    return result;
  }

  AskQuestionResponse._();

  factory AskQuestionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AskQuestionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AskQuestionResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ID', protoName: 'ID')
    ..aOB(2, _omitFieldNames ? '' : 'IsError', protoName: 'IsError')
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'Meta',
        protoName: 'Meta',
        entryClassName: 'AskQuestionResponse.MetaEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('agentassistproto'))
    ..pc<McpResultContent>(
        4, _omitFieldNames ? '' : 'contents', $pb.PbFieldType.PM,
        subBuilder: McpResultContent.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AskQuestionResponse clone() => AskQuestionResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AskQuestionResponse copyWith(void Function(AskQuestionResponse) updates) =>
      super.copyWith((message) => updates(message as AskQuestionResponse))
          as AskQuestionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AskQuestionResponse create() => AskQuestionResponse._();
  @$core.override
  AskQuestionResponse createEmptyInstance() => create();
  static $pb.PbList<AskQuestionResponse> createRepeated() =>
      $pb.PbList<AskQuestionResponse>();
  @$core.pragma('dart2js:noInline')
  static AskQuestionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AskQuestionResponse>(create);
  static AskQuestionResponse? _defaultInstance;

  /// request id
  @$pb.TagNumber(1)
  $core.String get iD => $_getSZ(0);
  @$pb.TagNumber(1)
  set iD($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasID() => $_has(0);
  @$pb.TagNumber(1)
  void clearID() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isError => $_getBF(1);
  @$pb.TagNumber(2)
  set isError($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsError() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsError() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $core.String> get meta => $_getMap(2);

  @$pb.TagNumber(4)
  $pb.PbList<McpResultContent> get contents => $_getList(3);
}

class McpWorkReportRequest extends $pb.GeneratedMessage {
  factory McpWorkReportRequest({
    $core.String? projectDirectory,
    $core.String? summary,
    $core.int? timeout,
    $core.String? agentName,
    $core.String? reasoningModelName,
    $core.String? mcpClientName,
  }) {
    final result = create();
    if (projectDirectory != null) result.projectDirectory = projectDirectory;
    if (summary != null) result.summary = summary;
    if (timeout != null) result.timeout = timeout;
    if (agentName != null) result.agentName = agentName;
    if (reasoningModelName != null)
      result.reasoningModelName = reasoningModelName;
    if (mcpClientName != null) result.mcpClientName = mcpClientName;
    return result;
  }

  McpWorkReportRequest._();

  factory McpWorkReportRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory McpWorkReportRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'McpWorkReportRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ProjectDirectory',
        protoName: 'ProjectDirectory')
    ..aOS(2, _omitFieldNames ? '' : 'Summary', protoName: 'Summary')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'Timeout', $pb.PbFieldType.O3,
        protoName: 'Timeout')
    ..aOS(4, _omitFieldNames ? '' : 'AgentName', protoName: 'AgentName')
    ..aOS(5, _omitFieldNames ? '' : 'ReasoningModelName',
        protoName: 'ReasoningModelName')
    ..aOS(6, _omitFieldNames ? '' : 'McpClientName', protoName: 'McpClientName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpWorkReportRequest clone() =>
      McpWorkReportRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpWorkReportRequest copyWith(void Function(McpWorkReportRequest) updates) =>
      super.copyWith((message) => updates(message as McpWorkReportRequest))
          as McpWorkReportRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static McpWorkReportRequest create() => McpWorkReportRequest._();
  @$core.override
  McpWorkReportRequest createEmptyInstance() => create();
  static $pb.PbList<McpWorkReportRequest> createRepeated() =>
      $pb.PbList<McpWorkReportRequest>();
  @$core.pragma('dart2js:noInline')
  static McpWorkReportRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<McpWorkReportRequest>(create);
  static McpWorkReportRequest? _defaultInstance;

  /// current project directory
  @$pb.TagNumber(1)
  $core.String get projectDirectory => $_getSZ(0);
  @$pb.TagNumber(1)
  set projectDirectory($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProjectDirectory() => $_has(0);
  @$pb.TagNumber(1)
  void clearProjectDirectory() => $_clearField(1);

  /// ai agent's work report summary
  @$pb.TagNumber(2)
  $core.String get summary => $_getSZ(1);
  @$pb.TagNumber(2)
  set summary($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSummary() => $_has(1);
  @$pb.TagNumber(2)
  void clearSummary() => $_clearField(2);

  /// timeout in seconds, default is 600s
  @$pb.TagNumber(3)
  $core.int get timeout => $_getIZ(2);
  @$pb.TagNumber(3)
  set timeout($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimeout() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimeout() => $_clearField(3);

  /// the AI agent/client name that is calling this tool (e.g., Antigravity,
  /// Cascade)
  @$pb.TagNumber(4)
  $core.String get agentName => $_getSZ(3);
  @$pb.TagNumber(4)
  set agentName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAgentName() => $_has(3);
  @$pb.TagNumber(4)
  void clearAgentName() => $_clearField(4);

  /// the actual LLM/inference model name being used for this task (e.g., GPT-4,
  /// Gemini 3 Pro)
  @$pb.TagNumber(5)
  $core.String get reasoningModelName => $_getSZ(4);
  @$pb.TagNumber(5)
  set reasoningModelName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReasoningModelName() => $_has(4);
  @$pb.TagNumber(5)
  void clearReasoningModelName() => $_clearField(5);

  /// MCP client name from initialize.clientInfo.name (e.g., windsurf)
  @$pb.TagNumber(6)
  $core.String get mcpClientName => $_getSZ(5);
  @$pb.TagNumber(6)
  set mcpClientName($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMcpClientName() => $_has(5);
  @$pb.TagNumber(6)
  void clearMcpClientName() => $_clearField(6);
}

class WorkReportRequest extends $pb.GeneratedMessage {
  factory WorkReportRequest({
    $core.String? iD,
    $core.String? userToken,
    McpWorkReportRequest? request,
    $fixnum.Int64? timestamp,
    $core.String? sessionId,
  }) {
    final result = create();
    if (iD != null) result.iD = iD;
    if (userToken != null) result.userToken = userToken;
    if (request != null) result.request = request;
    if (timestamp != null) result.timestamp = timestamp;
    if (sessionId != null) result.sessionId = sessionId;
    return result;
  }

  WorkReportRequest._();

  factory WorkReportRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WorkReportRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkReportRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ID', protoName: 'ID')
    ..aOS(2, _omitFieldNames ? '' : 'UserToken', protoName: 'UserToken')
    ..aOM<McpWorkReportRequest>(3, _omitFieldNames ? '' : 'Request',
        protoName: 'Request', subBuilder: McpWorkReportRequest.create)
    ..aInt64(4, _omitFieldNames ? '' : 'Timestamp', protoName: 'Timestamp')
    ..aOS(5, _omitFieldNames ? '' : 'SessionId', protoName: 'SessionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkReportRequest clone() => WorkReportRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkReportRequest copyWith(void Function(WorkReportRequest) updates) =>
      super.copyWith((message) => updates(message as WorkReportRequest))
          as WorkReportRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WorkReportRequest create() => WorkReportRequest._();
  @$core.override
  WorkReportRequest createEmptyInstance() => create();
  static $pb.PbList<WorkReportRequest> createRepeated() =>
      $pb.PbList<WorkReportRequest>();
  @$core.pragma('dart2js:noInline')
  static WorkReportRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkReportRequest>(create);
  static WorkReportRequest? _defaultInstance;

  /// request id
  @$pb.TagNumber(1)
  $core.String get iD => $_getSZ(0);
  @$pb.TagNumber(1)
  set iD($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasID() => $_has(0);
  @$pb.TagNumber(1)
  void clearID() => $_clearField(1);

  /// user token
  @$pb.TagNumber(2)
  $core.String get userToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set userToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserToken() => $_clearField(2);

  /// ai agent's work report summary
  @$pb.TagNumber(3)
  McpWorkReportRequest get request => $_getN(2);
  @$pb.TagNumber(3)
  set request(McpWorkReportRequest value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasRequest() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequest() => $_clearField(3);
  @$pb.TagNumber(3)
  McpWorkReportRequest ensureRequest() => $_ensure(2);

  /// timestamp (UTC)
  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);

  /// initiator (mcp process) session id, used for liveness tracking
  @$pb.TagNumber(5)
  $core.String get sessionId => $_getSZ(4);
  @$pb.TagNumber(5)
  set sessionId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSessionId() => $_has(4);
  @$pb.TagNumber(5)
  void clearSessionId() => $_clearField(5);
}

class WorkReportResponse extends $pb.GeneratedMessage {
  factory WorkReportResponse({
    $core.String? iD,
    $core.bool? isError,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? meta,
    $core.Iterable<McpResultContent>? contents,
  }) {
    final result = create();
    if (iD != null) result.iD = iD;
    if (isError != null) result.isError = isError;
    if (meta != null) result.meta.addEntries(meta);
    if (contents != null) result.contents.addAll(contents);
    return result;
  }

  WorkReportResponse._();

  factory WorkReportResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WorkReportResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkReportResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ID', protoName: 'ID')
    ..aOB(2, _omitFieldNames ? '' : 'IsError', protoName: 'IsError')
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'Meta',
        protoName: 'Meta',
        entryClassName: 'WorkReportResponse.MetaEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('agentassistproto'))
    ..pc<McpResultContent>(
        4, _omitFieldNames ? '' : 'contents', $pb.PbFieldType.PM,
        subBuilder: McpResultContent.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkReportResponse clone() => WorkReportResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkReportResponse copyWith(void Function(WorkReportResponse) updates) =>
      super.copyWith((message) => updates(message as WorkReportResponse))
          as WorkReportResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WorkReportResponse create() => WorkReportResponse._();
  @$core.override
  WorkReportResponse createEmptyInstance() => create();
  static $pb.PbList<WorkReportResponse> createRepeated() =>
      $pb.PbList<WorkReportResponse>();
  @$core.pragma('dart2js:noInline')
  static WorkReportResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkReportResponse>(create);
  static WorkReportResponse? _defaultInstance;

  /// request id
  @$pb.TagNumber(1)
  $core.String get iD => $_getSZ(0);
  @$pb.TagNumber(1)
  set iD($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasID() => $_has(0);
  @$pb.TagNumber(1)
  void clearID() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isError => $_getBF(1);
  @$pb.TagNumber(2)
  set isError($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsError() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsError() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $core.String> get meta => $_getMap(2);

  @$pb.TagNumber(4)
  $pb.PbList<McpResultContent> get contents => $_getList(3);
}

class McpClientInfoData extends $pb.GeneratedMessage {
  factory McpClientInfoData({
    $core.String? protocolVersion,
    $core.String? capabilitiesJson,
    $core.String? clientName,
    $core.String? clientVersion,
  }) {
    final result = create();
    if (protocolVersion != null) result.protocolVersion = protocolVersion;
    if (capabilitiesJson != null) result.capabilitiesJson = capabilitiesJson;
    if (clientName != null) result.clientName = clientName;
    if (clientVersion != null) result.clientVersion = clientVersion;
    return result;
  }

  McpClientInfoData._();

  factory McpClientInfoData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory McpClientInfoData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'McpClientInfoData',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ProtocolVersion',
        protoName: 'ProtocolVersion')
    ..aOS(2, _omitFieldNames ? '' : 'CapabilitiesJson',
        protoName: 'CapabilitiesJson')
    ..aOS(3, _omitFieldNames ? '' : 'ClientName', protoName: 'ClientName')
    ..aOS(4, _omitFieldNames ? '' : 'ClientVersion', protoName: 'ClientVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpClientInfoData clone() => McpClientInfoData()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpClientInfoData copyWith(void Function(McpClientInfoData) updates) =>
      super.copyWith((message) => updates(message as McpClientInfoData))
          as McpClientInfoData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static McpClientInfoData create() => McpClientInfoData._();
  @$core.override
  McpClientInfoData createEmptyInstance() => create();
  static $pb.PbList<McpClientInfoData> createRepeated() =>
      $pb.PbList<McpClientInfoData>();
  @$core.pragma('dart2js:noInline')
  static McpClientInfoData getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<McpClientInfoData>(create);
  static McpClientInfoData? _defaultInstance;

  /// MCP protocol version requested by client
  @$pb.TagNumber(1)
  $core.String get protocolVersion => $_getSZ(0);
  @$pb.TagNumber(1)
  set protocolVersion($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProtocolVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearProtocolVersion() => $_clearField(1);

  /// Raw JSON describing client capabilities (mcp.InitializeParams.capabilities)
  @$pb.TagNumber(2)
  $core.String get capabilitiesJson => $_getSZ(1);
  @$pb.TagNumber(2)
  set capabilitiesJson($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCapabilitiesJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearCapabilitiesJson() => $_clearField(2);

  /// MCP client implementation name
  @$pb.TagNumber(3)
  $core.String get clientName => $_getSZ(2);
  @$pb.TagNumber(3)
  set clientName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasClientName() => $_has(2);
  @$pb.TagNumber(3)
  void clearClientName() => $_clearField(3);

  /// MCP client implementation version
  @$pb.TagNumber(4)
  $core.String get clientVersion => $_getSZ(3);
  @$pb.TagNumber(4)
  set clientVersion($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasClientVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearClientVersion() => $_clearField(4);
}

class McpClientInfoRequest extends $pb.GeneratedMessage {
  factory McpClientInfoRequest({
    $core.String? iD,
    $core.String? userToken,
    McpClientInfoData? request,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (iD != null) result.iD = iD;
    if (userToken != null) result.userToken = userToken;
    if (request != null) result.request = request;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  McpClientInfoRequest._();

  factory McpClientInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory McpClientInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'McpClientInfoRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ID', protoName: 'ID')
    ..aOS(2, _omitFieldNames ? '' : 'UserToken', protoName: 'UserToken')
    ..aOM<McpClientInfoData>(3, _omitFieldNames ? '' : 'Request',
        protoName: 'Request', subBuilder: McpClientInfoData.create)
    ..aInt64(4, _omitFieldNames ? '' : 'Timestamp', protoName: 'Timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpClientInfoRequest clone() =>
      McpClientInfoRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpClientInfoRequest copyWith(void Function(McpClientInfoRequest) updates) =>
      super.copyWith((message) => updates(message as McpClientInfoRequest))
          as McpClientInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static McpClientInfoRequest create() => McpClientInfoRequest._();
  @$core.override
  McpClientInfoRequest createEmptyInstance() => create();
  static $pb.PbList<McpClientInfoRequest> createRepeated() =>
      $pb.PbList<McpClientInfoRequest>();
  @$core.pragma('dart2js:noInline')
  static McpClientInfoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<McpClientInfoRequest>(create);
  static McpClientInfoRequest? _defaultInstance;

  /// request id
  @$pb.TagNumber(1)
  $core.String get iD => $_getSZ(0);
  @$pb.TagNumber(1)
  set iD($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasID() => $_has(0);
  @$pb.TagNumber(1)
  void clearID() => $_clearField(1);

  /// user token
  @$pb.TagNumber(2)
  $core.String get userToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set userToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserToken() => $_clearField(2);

  /// initialize request payload
  @$pb.TagNumber(3)
  McpClientInfoData get request => $_getN(2);
  @$pb.TagNumber(3)
  set request(McpClientInfoData value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasRequest() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequest() => $_clearField(3);
  @$pb.TagNumber(3)
  McpClientInfoData ensureRequest() => $_ensure(2);

  /// timestamp (UTC)
  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
}

class McpClientInfoResponse extends $pb.GeneratedMessage {
  factory McpClientInfoResponse({
    $core.bool? success,
  }) {
    final result = create();
    if (success != null) result.success = success;
    return result;
  }

  McpClientInfoResponse._();

  factory McpClientInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory McpClientInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'McpClientInfoResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'Success', protoName: 'Success')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpClientInfoResponse clone() =>
      McpClientInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpClientInfoResponse copyWith(
          void Function(McpClientInfoResponse) updates) =>
      super.copyWith((message) => updates(message as McpClientInfoResponse))
          as McpClientInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static McpClientInfoResponse create() => McpClientInfoResponse._();
  @$core.override
  McpClientInfoResponse createEmptyInstance() => create();
  static $pb.PbList<McpClientInfoResponse> createRepeated() =>
      $pb.PbList<McpClientInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static McpClientInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<McpClientInfoResponse>(create);
  static McpClientInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
}

class CheckMessageValidityRequest extends $pb.GeneratedMessage {
  factory CheckMessageValidityRequest({
    $core.Iterable<$core.String>? requestIds,
  }) {
    final result = create();
    if (requestIds != null) result.requestIds.addAll(requestIds);
    return result;
  }

  CheckMessageValidityRequest._();

  factory CheckMessageValidityRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CheckMessageValidityRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckMessageValidityRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'requestIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckMessageValidityRequest clone() =>
      CheckMessageValidityRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckMessageValidityRequest copyWith(
          void Function(CheckMessageValidityRequest) updates) =>
      super.copyWith(
              (message) => updates(message as CheckMessageValidityRequest))
          as CheckMessageValidityRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckMessageValidityRequest create() =>
      CheckMessageValidityRequest._();
  @$core.override
  CheckMessageValidityRequest createEmptyInstance() => create();
  static $pb.PbList<CheckMessageValidityRequest> createRepeated() =>
      $pb.PbList<CheckMessageValidityRequest>();
  @$core.pragma('dart2js:noInline')
  static CheckMessageValidityRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckMessageValidityRequest>(create);
  static CheckMessageValidityRequest? _defaultInstance;

  /// list of request IDs to check
  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get requestIds => $_getList(0);
}

class CheckMessageValidityResponse extends $pb.GeneratedMessage {
  factory CheckMessageValidityResponse({
    $core.Iterable<$core.MapEntry<$core.String, $core.bool>>? validity,
  }) {
    final result = create();
    if (validity != null) result.validity.addEntries(validity);
    return result;
  }

  CheckMessageValidityResponse._();

  factory CheckMessageValidityResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CheckMessageValidityResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckMessageValidityResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..m<$core.String, $core.bool>(1, _omitFieldNames ? '' : 'validity',
        entryClassName: 'CheckMessageValidityResponse.ValidityEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OB,
        packageName: const $pb.PackageName('agentassistproto'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckMessageValidityResponse clone() =>
      CheckMessageValidityResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckMessageValidityResponse copyWith(
          void Function(CheckMessageValidityResponse) updates) =>
      super.copyWith(
              (message) => updates(message as CheckMessageValidityResponse))
          as CheckMessageValidityResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckMessageValidityResponse create() =>
      CheckMessageValidityResponse._();
  @$core.override
  CheckMessageValidityResponse createEmptyInstance() => create();
  static $pb.PbList<CheckMessageValidityResponse> createRepeated() =>
      $pb.PbList<CheckMessageValidityResponse>();
  @$core.pragma('dart2js:noInline')
  static CheckMessageValidityResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckMessageValidityResponse>(create);
  static CheckMessageValidityResponse? _defaultInstance;

  /// map of request ID to validity status
  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, $core.bool> get validity => $_getMap(0);
}

/// GetPendingMessagesRequest represents a request to get all pending messages
/// for a user
class GetPendingMessagesRequest extends $pb.GeneratedMessage {
  factory GetPendingMessagesRequest({
    $core.String? userToken,
  }) {
    final result = create();
    if (userToken != null) result.userToken = userToken;
    return result;
  }

  GetPendingMessagesRequest._();

  factory GetPendingMessagesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPendingMessagesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPendingMessagesRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPendingMessagesRequest clone() =>
      GetPendingMessagesRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPendingMessagesRequest copyWith(
          void Function(GetPendingMessagesRequest) updates) =>
      super.copyWith((message) => updates(message as GetPendingMessagesRequest))
          as GetPendingMessagesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPendingMessagesRequest create() => GetPendingMessagesRequest._();
  @$core.override
  GetPendingMessagesRequest createEmptyInstance() => create();
  static $pb.PbList<GetPendingMessagesRequest> createRepeated() =>
      $pb.PbList<GetPendingMessagesRequest>();
  @$core.pragma('dart2js:noInline')
  static GetPendingMessagesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPendingMessagesRequest>(create);
  static GetPendingMessagesRequest? _defaultInstance;

  /// user token to filter messages
  @$pb.TagNumber(1)
  $core.String get userToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set userToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserToken() => $_clearField(1);
}

/// PendingMessage represents a single pending message
class PendingMessage extends $pb.GeneratedMessage {
  factory PendingMessage({
    $core.String? messageType,
    AskQuestionRequest? askQuestionRequest,
    WorkReportRequest? workReportRequest,
    $fixnum.Int64? createdAt,
    $core.int? timeout,
  }) {
    final result = create();
    if (messageType != null) result.messageType = messageType;
    if (askQuestionRequest != null)
      result.askQuestionRequest = askQuestionRequest;
    if (workReportRequest != null) result.workReportRequest = workReportRequest;
    if (createdAt != null) result.createdAt = createdAt;
    if (timeout != null) result.timeout = timeout;
    return result;
  }

  PendingMessage._();

  factory PendingMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PendingMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PendingMessage',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageType')
    ..aOM<AskQuestionRequest>(2, _omitFieldNames ? '' : 'askQuestionRequest',
        subBuilder: AskQuestionRequest.create)
    ..aOM<WorkReportRequest>(3, _omitFieldNames ? '' : 'workReportRequest',
        subBuilder: WorkReportRequest.create)
    ..aInt64(4, _omitFieldNames ? '' : 'createdAt')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'timeout', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PendingMessage clone() => PendingMessage()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PendingMessage copyWith(void Function(PendingMessage) updates) =>
      super.copyWith((message) => updates(message as PendingMessage))
          as PendingMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PendingMessage create() => PendingMessage._();
  @$core.override
  PendingMessage createEmptyInstance() => create();
  static $pb.PbList<PendingMessage> createRepeated() =>
      $pb.PbList<PendingMessage>();
  @$core.pragma('dart2js:noInline')
  static PendingMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PendingMessage>(create);
  static PendingMessage? _defaultInstance;

  /// message type: "AskQuestion" or "WorkReport"
  @$pb.TagNumber(1)
  $core.String get messageType => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageType() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageType() => $_clearField(1);

  /// ask question request (if message_type is "AskQuestion")
  @$pb.TagNumber(2)
  AskQuestionRequest get askQuestionRequest => $_getN(1);
  @$pb.TagNumber(2)
  set askQuestionRequest(AskQuestionRequest value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAskQuestionRequest() => $_has(1);
  @$pb.TagNumber(2)
  void clearAskQuestionRequest() => $_clearField(2);
  @$pb.TagNumber(2)
  AskQuestionRequest ensureAskQuestionRequest() => $_ensure(1);

  /// work report request (if message_type is "WorkReport")
  @$pb.TagNumber(3)
  WorkReportRequest get workReportRequest => $_getN(2);
  @$pb.TagNumber(3)
  set workReportRequest(WorkReportRequest value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasWorkReportRequest() => $_has(2);
  @$pb.TagNumber(3)
  void clearWorkReportRequest() => $_clearField(3);
  @$pb.TagNumber(3)
  WorkReportRequest ensureWorkReportRequest() => $_ensure(2);

  /// timestamp when the message was created
  @$pb.TagNumber(4)
  $fixnum.Int64 get createdAt => $_getI64(3);
  @$pb.TagNumber(4)
  set createdAt($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCreatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatedAt() => $_clearField(4);

  /// timeout in seconds
  @$pb.TagNumber(5)
  $core.int get timeout => $_getIZ(4);
  @$pb.TagNumber(5)
  set timeout($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTimeout() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimeout() => $_clearField(5);
}

/// GetPendingMessagesResponse represents the response containing all pending
/// messages
class GetPendingMessagesResponse extends $pb.GeneratedMessage {
  factory GetPendingMessagesResponse({
    $core.Iterable<PendingMessage>? pendingMessages,
    $core.int? totalCount,
  }) {
    final result = create();
    if (pendingMessages != null) result.pendingMessages.addAll(pendingMessages);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  GetPendingMessagesResponse._();

  factory GetPendingMessagesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPendingMessagesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPendingMessagesResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..pc<PendingMessage>(
        1, _omitFieldNames ? '' : 'pendingMessages', $pb.PbFieldType.PM,
        subBuilder: PendingMessage.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'totalCount', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPendingMessagesResponse clone() =>
      GetPendingMessagesResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPendingMessagesResponse copyWith(
          void Function(GetPendingMessagesResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetPendingMessagesResponse))
          as GetPendingMessagesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPendingMessagesResponse create() => GetPendingMessagesResponse._();
  @$core.override
  GetPendingMessagesResponse createEmptyInstance() => create();
  static $pb.PbList<GetPendingMessagesResponse> createRepeated() =>
      $pb.PbList<GetPendingMessagesResponse>();
  @$core.pragma('dart2js:noInline')
  static GetPendingMessagesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPendingMessagesResponse>(create);
  static GetPendingMessagesResponse? _defaultInstance;

  /// list of pending messages
  @$pb.TagNumber(1)
  $pb.PbList<PendingMessage> get pendingMessages => $_getList(0);

  /// total count of pending messages
  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

/// RequestCancelledNotification represents a notification that a request has
/// been cancelled
class RequestCancelledNotification extends $pb.GeneratedMessage {
  factory RequestCancelledNotification({
    $core.String? requestId,
    $core.String? reason,
    $core.String? messageType,
    $core.String? reasonCode,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (reason != null) result.reason = reason;
    if (messageType != null) result.messageType = messageType;
    if (reasonCode != null) result.reasonCode = reasonCode;
    return result;
  }

  RequestCancelledNotification._();

  factory RequestCancelledNotification.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestCancelledNotification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestCancelledNotification',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..aOS(3, _omitFieldNames ? '' : 'messageType')
    ..aOS(4, _omitFieldNames ? '' : 'reasonCode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestCancelledNotification clone() =>
      RequestCancelledNotification()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestCancelledNotification copyWith(
          void Function(RequestCancelledNotification) updates) =>
      super.copyWith(
              (message) => updates(message as RequestCancelledNotification))
          as RequestCancelledNotification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestCancelledNotification create() =>
      RequestCancelledNotification._();
  @$core.override
  RequestCancelledNotification createEmptyInstance() => create();
  static $pb.PbList<RequestCancelledNotification> createRepeated() =>
      $pb.PbList<RequestCancelledNotification>();
  @$core.pragma('dart2js:noInline')
  static RequestCancelledNotification getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestCancelledNotification>(create);
  static RequestCancelledNotification? _defaultInstance;

  /// request id that was cancelled
  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  /// reason for cancellation
  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);

  /// message type: "AskQuestion" or "WorkReport"
  @$pb.TagNumber(3)
  $core.String get messageType => $_getSZ(2);
  @$pb.TagNumber(3)
  set messageType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessageType() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessageType() => $_clearField(3);

  /// machine-readable reason code, e.g. "timeout", "cancelled",
  /// "initiator_disconnected"
  @$pb.TagNumber(4)
  $core.String get reasonCode => $_getSZ(3);
  @$pb.TagNumber(4)
  set reasonCode($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReasonCode() => $_has(3);
  @$pb.TagNumber(4)
  void clearReasonCode() => $_clearField(4);
}

/// McpHeartbeatRequest represents a heartbeat sent by an MCP initiator process
/// to keep its pending requests alive. Each MCP process generates a unique
/// session id at startup and heartbeats it periodically while it is alive.
class McpHeartbeatRequest extends $pb.GeneratedMessage {
  factory McpHeartbeatRequest({
    $core.String? sessionId,
    $core.String? userToken,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (sessionId != null) result.sessionId = sessionId;
    if (userToken != null) result.userToken = userToken;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  McpHeartbeatRequest._();

  factory McpHeartbeatRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory McpHeartbeatRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'McpHeartbeatRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'SessionId', protoName: 'SessionId')
    ..aOS(2, _omitFieldNames ? '' : 'UserToken', protoName: 'UserToken')
    ..aInt64(3, _omitFieldNames ? '' : 'Timestamp', protoName: 'Timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpHeartbeatRequest clone() => McpHeartbeatRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpHeartbeatRequest copyWith(void Function(McpHeartbeatRequest) updates) =>
      super.copyWith((message) => updates(message as McpHeartbeatRequest))
          as McpHeartbeatRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static McpHeartbeatRequest create() => McpHeartbeatRequest._();
  @$core.override
  McpHeartbeatRequest createEmptyInstance() => create();
  static $pb.PbList<McpHeartbeatRequest> createRepeated() =>
      $pb.PbList<McpHeartbeatRequest>();
  @$core.pragma('dart2js:noInline')
  static McpHeartbeatRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<McpHeartbeatRequest>(create);
  static McpHeartbeatRequest? _defaultInstance;

  /// initiator (mcp process) session id
  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  /// user token
  @$pb.TagNumber(2)
  $core.String get userToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set userToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserToken() => $_clearField(2);

  /// timestamp (UTC)
  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);
}

class McpHeartbeatResponse extends $pb.GeneratedMessage {
  factory McpHeartbeatResponse({
    $core.bool? success,
  }) {
    final result = create();
    if (success != null) result.success = success;
    return result;
  }

  McpHeartbeatResponse._();

  factory McpHeartbeatResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory McpHeartbeatResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'McpHeartbeatResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'Success', protoName: 'Success')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpHeartbeatResponse clone() =>
      McpHeartbeatResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpHeartbeatResponse copyWith(void Function(McpHeartbeatResponse) updates) =>
      super.copyWith((message) => updates(message as McpHeartbeatResponse))
          as McpHeartbeatResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static McpHeartbeatResponse create() => McpHeartbeatResponse._();
  @$core.override
  McpHeartbeatResponse createEmptyInstance() => create();
  static $pb.PbList<McpHeartbeatResponse> createRepeated() =>
      $pb.PbList<McpHeartbeatResponse>();
  @$core.pragma('dart2js:noInline')
  static McpHeartbeatResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<McpHeartbeatResponse>(create);
  static McpHeartbeatResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
}

/// OnlineUser represents an online user with the same token
class OnlineUser extends $pb.GeneratedMessage {
  factory OnlineUser({
    $core.String? clientId,
    $core.String? nickname,
    $fixnum.Int64? connectedAt,
  }) {
    final result = create();
    if (clientId != null) result.clientId = clientId;
    if (nickname != null) result.nickname = nickname;
    if (connectedAt != null) result.connectedAt = connectedAt;
    return result;
  }

  OnlineUser._();

  factory OnlineUser.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory OnlineUser.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OnlineUser',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'clientId')
    ..aOS(2, _omitFieldNames ? '' : 'nickname')
    ..aInt64(3, _omitFieldNames ? '' : 'connectedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnlineUser clone() => OnlineUser()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnlineUser copyWith(void Function(OnlineUser) updates) =>
      super.copyWith((message) => updates(message as OnlineUser)) as OnlineUser;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OnlineUser create() => OnlineUser._();
  @$core.override
  OnlineUser createEmptyInstance() => create();
  static $pb.PbList<OnlineUser> createRepeated() => $pb.PbList<OnlineUser>();
  @$core.pragma('dart2js:noInline')
  static OnlineUser getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OnlineUser>(create);
  static OnlineUser? _defaultInstance;

  /// client id
  @$pb.TagNumber(1)
  $core.String get clientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientId() => $_clearField(1);

  /// user nickname
  @$pb.TagNumber(2)
  $core.String get nickname => $_getSZ(1);
  @$pb.TagNumber(2)
  set nickname($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNickname() => $_has(1);
  @$pb.TagNumber(2)
  void clearNickname() => $_clearField(2);

  /// connection timestamp
  @$pb.TagNumber(3)
  $fixnum.Int64 get connectedAt => $_getI64(2);
  @$pb.TagNumber(3)
  set connectedAt($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConnectedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearConnectedAt() => $_clearField(3);
}

/// GetOnlineUsersRequest represents a request to get online users with the same
/// token
class GetOnlineUsersRequest extends $pb.GeneratedMessage {
  factory GetOnlineUsersRequest({
    $core.String? userToken,
  }) {
    final result = create();
    if (userToken != null) result.userToken = userToken;
    return result;
  }

  GetOnlineUsersRequest._();

  factory GetOnlineUsersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetOnlineUsersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetOnlineUsersRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOnlineUsersRequest clone() =>
      GetOnlineUsersRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOnlineUsersRequest copyWith(
          void Function(GetOnlineUsersRequest) updates) =>
      super.copyWith((message) => updates(message as GetOnlineUsersRequest))
          as GetOnlineUsersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetOnlineUsersRequest create() => GetOnlineUsersRequest._();
  @$core.override
  GetOnlineUsersRequest createEmptyInstance() => create();
  static $pb.PbList<GetOnlineUsersRequest> createRepeated() =>
      $pb.PbList<GetOnlineUsersRequest>();
  @$core.pragma('dart2js:noInline')
  static GetOnlineUsersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetOnlineUsersRequest>(create);
  static GetOnlineUsersRequest? _defaultInstance;

  /// user token to filter users
  @$pb.TagNumber(1)
  $core.String get userToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set userToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserToken() => $_clearField(1);
}

/// GetOnlineUsersResponse represents the response containing online users
class GetOnlineUsersResponse extends $pb.GeneratedMessage {
  factory GetOnlineUsersResponse({
    $core.Iterable<OnlineUser>? onlineUsers,
    $core.int? totalCount,
  }) {
    final result = create();
    if (onlineUsers != null) result.onlineUsers.addAll(onlineUsers);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  GetOnlineUsersResponse._();

  factory GetOnlineUsersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetOnlineUsersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetOnlineUsersResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..pc<OnlineUser>(
        1, _omitFieldNames ? '' : 'onlineUsers', $pb.PbFieldType.PM,
        subBuilder: OnlineUser.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'totalCount', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOnlineUsersResponse clone() =>
      GetOnlineUsersResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOnlineUsersResponse copyWith(
          void Function(GetOnlineUsersResponse) updates) =>
      super.copyWith((message) => updates(message as GetOnlineUsersResponse))
          as GetOnlineUsersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetOnlineUsersResponse create() => GetOnlineUsersResponse._();
  @$core.override
  GetOnlineUsersResponse createEmptyInstance() => create();
  static $pb.PbList<GetOnlineUsersResponse> createRepeated() =>
      $pb.PbList<GetOnlineUsersResponse>();
  @$core.pragma('dart2js:noInline')
  static GetOnlineUsersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetOnlineUsersResponse>(create);
  static GetOnlineUsersResponse? _defaultInstance;

  /// list of online users
  @$pb.TagNumber(1)
  $pb.PbList<OnlineUser> get onlineUsers => $_getList(0);

  /// total count of online users
  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

/// ChatMessage represents a chat message between users
class ChatMessage extends $pb.GeneratedMessage {
  factory ChatMessage({
    $core.String? messageId,
    $core.String? senderClientId,
    $core.String? senderNickname,
    $core.String? receiverClientId,
    $core.String? receiverNickname,
    $core.String? content,
    $fixnum.Int64? sentAt,
    ForwardTarget? forwardTarget,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (senderClientId != null) result.senderClientId = senderClientId;
    if (senderNickname != null) result.senderNickname = senderNickname;
    if (receiverClientId != null) result.receiverClientId = receiverClientId;
    if (receiverNickname != null) result.receiverNickname = receiverNickname;
    if (content != null) result.content = content;
    if (sentAt != null) result.sentAt = sentAt;
    if (forwardTarget != null) result.forwardTarget = forwardTarget;
    return result;
  }

  ChatMessage._();

  factory ChatMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChatMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatMessage',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOS(2, _omitFieldNames ? '' : 'senderClientId')
    ..aOS(3, _omitFieldNames ? '' : 'senderNickname')
    ..aOS(4, _omitFieldNames ? '' : 'receiverClientId')
    ..aOS(5, _omitFieldNames ? '' : 'receiverNickname')
    ..aOS(6, _omitFieldNames ? '' : 'content')
    ..aInt64(7, _omitFieldNames ? '' : 'sentAt')
    ..aOM<ForwardTarget>(8, _omitFieldNames ? '' : 'forwardTarget',
        subBuilder: ForwardTarget.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage clone() => ChatMessage()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage copyWith(void Function(ChatMessage) updates) =>
      super.copyWith((message) => updates(message as ChatMessage))
          as ChatMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatMessage create() => ChatMessage._();
  @$core.override
  ChatMessage createEmptyInstance() => create();
  static $pb.PbList<ChatMessage> createRepeated() => $pb.PbList<ChatMessage>();
  @$core.pragma('dart2js:noInline')
  static ChatMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatMessage>(create);
  static ChatMessage? _defaultInstance;

  /// message id
  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  /// sender client id
  @$pb.TagNumber(2)
  $core.String get senderClientId => $_getSZ(1);
  @$pb.TagNumber(2)
  set senderClientId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSenderClientId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSenderClientId() => $_clearField(2);

  /// sender nickname
  @$pb.TagNumber(3)
  $core.String get senderNickname => $_getSZ(2);
  @$pb.TagNumber(3)
  set senderNickname($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSenderNickname() => $_has(2);
  @$pb.TagNumber(3)
  void clearSenderNickname() => $_clearField(3);

  /// receiver client id
  @$pb.TagNumber(4)
  $core.String get receiverClientId => $_getSZ(3);
  @$pb.TagNumber(4)
  set receiverClientId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReceiverClientId() => $_has(3);
  @$pb.TagNumber(4)
  void clearReceiverClientId() => $_clearField(4);

  /// receiver nickname
  @$pb.TagNumber(5)
  $core.String get receiverNickname => $_getSZ(4);
  @$pb.TagNumber(5)
  set receiverNickname($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReceiverNickname() => $_has(4);
  @$pb.TagNumber(5)
  void clearReceiverNickname() => $_clearField(5);

  /// message content
  @$pb.TagNumber(6)
  $core.String get content => $_getSZ(5);
  @$pb.TagNumber(6)
  set content($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasContent() => $_has(5);
  @$pb.TagNumber(6)
  void clearContent() => $_clearField(6);

  /// timestamp when the message was sent
  @$pb.TagNumber(7)
  $fixnum.Int64 get sentAt => $_getI64(6);
  @$pb.TagNumber(7)
  set sentAt($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSentAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearSentAt() => $_clearField(7);

  /// forward target selected by sender (optional)
  @$pb.TagNumber(8)
  ForwardTarget get forwardTarget => $_getN(7);
  @$pb.TagNumber(8)
  set forwardTarget(ForwardTarget value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasForwardTarget() => $_has(7);
  @$pb.TagNumber(8)
  void clearForwardTarget() => $_clearField(8);
  @$pb.TagNumber(8)
  ForwardTarget ensureForwardTarget() => $_ensure(7);
}

/// ForwardTarget describes how receiver should forward content to system input
class ForwardTarget extends $pb.GeneratedMessage {
  factory ForwardTarget({
    ForwardTarget_Mode? mode,
    $core.String? windowId,
  }) {
    final result = create();
    if (mode != null) result.mode = mode;
    if (windowId != null) result.windowId = windowId;
    return result;
  }

  ForwardTarget._();

  factory ForwardTarget.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ForwardTarget.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ForwardTarget',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..e<ForwardTarget_Mode>(
        1, _omitFieldNames ? '' : 'mode', $pb.PbFieldType.OE,
        defaultOrMaker: ForwardTarget_Mode.MODE_UNSPECIFIED,
        valueOf: ForwardTarget_Mode.valueOf,
        enumValues: ForwardTarget_Mode.values)
    ..aOS(2, _omitFieldNames ? '' : 'windowId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardTarget clone() => ForwardTarget()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardTarget copyWith(void Function(ForwardTarget) updates) =>
      super.copyWith((message) => updates(message as ForwardTarget))
          as ForwardTarget;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ForwardTarget create() => ForwardTarget._();
  @$core.override
  ForwardTarget createEmptyInstance() => create();
  static $pb.PbList<ForwardTarget> createRepeated() =>
      $pb.PbList<ForwardTarget>();
  @$core.pragma('dart2js:noInline')
  static ForwardTarget getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ForwardTarget>(create);
  static ForwardTarget? _defaultInstance;

  /// forwarding mode
  @$pb.TagNumber(1)
  ForwardTarget_Mode get mode => $_getN(0);
  @$pb.TagNumber(1)
  set mode(ForwardTarget_Mode value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearMode() => $_clearField(1);

  /// target window id when mode is SPECIFIC_WINDOW
  @$pb.TagNumber(2)
  $core.String get windowId => $_getSZ(1);
  @$pb.TagNumber(2)
  set windowId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWindowId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWindowId() => $_clearField(2);
}

/// ForwardWindowItem describes one forwardable system window
class ForwardWindowItem extends $pb.GeneratedMessage {
  factory ForwardWindowItem({
    $core.String? windowId,
    $core.String? title,
  }) {
    final result = create();
    if (windowId != null) result.windowId = windowId;
    if (title != null) result.title = title;
    return result;
  }

  ForwardWindowItem._();

  factory ForwardWindowItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ForwardWindowItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ForwardWindowItem',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'windowId')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardWindowItem clone() => ForwardWindowItem()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardWindowItem copyWith(void Function(ForwardWindowItem) updates) =>
      super.copyWith((message) => updates(message as ForwardWindowItem))
          as ForwardWindowItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ForwardWindowItem create() => ForwardWindowItem._();
  @$core.override
  ForwardWindowItem createEmptyInstance() => create();
  static $pb.PbList<ForwardWindowItem> createRepeated() =>
      $pb.PbList<ForwardWindowItem>();
  @$core.pragma('dart2js:noInline')
  static ForwardWindowItem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ForwardWindowItem>(create);
  static ForwardWindowItem? _defaultInstance;

  /// stable window id
  @$pb.TagNumber(1)
  $core.String get windowId => $_getSZ(0);
  @$pb.TagNumber(1)
  set windowId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWindowId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWindowId() => $_clearField(1);

  /// display title
  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);
}

/// SendChatMessageRequest represents a request to send a chat message
class SendChatMessageRequest extends $pb.GeneratedMessage {
  factory SendChatMessageRequest({
    $core.String? receiverClientId,
    $core.String? content,
    ForwardTarget? forwardTarget,
  }) {
    final result = create();
    if (receiverClientId != null) result.receiverClientId = receiverClientId;
    if (content != null) result.content = content;
    if (forwardTarget != null) result.forwardTarget = forwardTarget;
    return result;
  }

  SendChatMessageRequest._();

  factory SendChatMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendChatMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendChatMessageRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'receiverClientId')
    ..aOS(2, _omitFieldNames ? '' : 'content')
    ..aOM<ForwardTarget>(3, _omitFieldNames ? '' : 'forwardTarget',
        subBuilder: ForwardTarget.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendChatMessageRequest clone() =>
      SendChatMessageRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendChatMessageRequest copyWith(
          void Function(SendChatMessageRequest) updates) =>
      super.copyWith((message) => updates(message as SendChatMessageRequest))
          as SendChatMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendChatMessageRequest create() => SendChatMessageRequest._();
  @$core.override
  SendChatMessageRequest createEmptyInstance() => create();
  static $pb.PbList<SendChatMessageRequest> createRepeated() =>
      $pb.PbList<SendChatMessageRequest>();
  @$core.pragma('dart2js:noInline')
  static SendChatMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendChatMessageRequest>(create);
  static SendChatMessageRequest? _defaultInstance;

  /// receiver client id
  @$pb.TagNumber(1)
  $core.String get receiverClientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set receiverClientId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasReceiverClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearReceiverClientId() => $_clearField(1);

  /// message content
  @$pb.TagNumber(2)
  $core.String get content => $_getSZ(1);
  @$pb.TagNumber(2)
  set content($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => $_clearField(2);

  /// optional forward target to be used by receiver
  @$pb.TagNumber(3)
  ForwardTarget get forwardTarget => $_getN(2);
  @$pb.TagNumber(3)
  set forwardTarget(ForwardTarget value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasForwardTarget() => $_has(2);
  @$pb.TagNumber(3)
  void clearForwardTarget() => $_clearField(3);
  @$pb.TagNumber(3)
  ForwardTarget ensureForwardTarget() => $_ensure(2);
}

/// ChatMessageNotification represents a notification of a new chat message
class ChatMessageNotification extends $pb.GeneratedMessage {
  factory ChatMessageNotification({
    ChatMessage? chatMessage,
  }) {
    final result = create();
    if (chatMessage != null) result.chatMessage = chatMessage;
    return result;
  }

  ChatMessageNotification._();

  factory ChatMessageNotification.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChatMessageNotification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatMessageNotification',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOM<ChatMessage>(1, _omitFieldNames ? '' : 'chatMessage',
        subBuilder: ChatMessage.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessageNotification clone() =>
      ChatMessageNotification()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessageNotification copyWith(
          void Function(ChatMessageNotification) updates) =>
      super.copyWith((message) => updates(message as ChatMessageNotification))
          as ChatMessageNotification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatMessageNotification create() => ChatMessageNotification._();
  @$core.override
  ChatMessageNotification createEmptyInstance() => create();
  static $pb.PbList<ChatMessageNotification> createRepeated() =>
      $pb.PbList<ChatMessageNotification>();
  @$core.pragma('dart2js:noInline')
  static ChatMessageNotification getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatMessageNotification>(create);
  static ChatMessageNotification? _defaultInstance;

  /// the chat message
  @$pb.TagNumber(1)
  ChatMessage get chatMessage => $_getN(0);
  @$pb.TagNumber(1)
  set chatMessage(ChatMessage value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasChatMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatMessage() => $_clearField(1);
  @$pb.TagNumber(1)
  ChatMessage ensureChatMessage() => $_ensure(0);
}

/// ForwardStateQueryRequest asks target client to report forward capability and windows
class ForwardStateQueryRequest extends $pb.GeneratedMessage {
  factory ForwardStateQueryRequest({
    $core.String? requestId,
    $core.String? targetClientId,
    $core.String? requesterClientId,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (targetClientId != null) result.targetClientId = targetClientId;
    if (requesterClientId != null) result.requesterClientId = requesterClientId;
    return result;
  }

  ForwardStateQueryRequest._();

  factory ForwardStateQueryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ForwardStateQueryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ForwardStateQueryRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOS(2, _omitFieldNames ? '' : 'targetClientId')
    ..aOS(3, _omitFieldNames ? '' : 'requesterClientId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardStateQueryRequest clone() =>
      ForwardStateQueryRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardStateQueryRequest copyWith(
          void Function(ForwardStateQueryRequest) updates) =>
      super.copyWith((message) => updates(message as ForwardStateQueryRequest))
          as ForwardStateQueryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ForwardStateQueryRequest create() => ForwardStateQueryRequest._();
  @$core.override
  ForwardStateQueryRequest createEmptyInstance() => create();
  static $pb.PbList<ForwardStateQueryRequest> createRepeated() =>
      $pb.PbList<ForwardStateQueryRequest>();
  @$core.pragma('dart2js:noInline')
  static ForwardStateQueryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ForwardStateQueryRequest>(create);
  static ForwardStateQueryRequest? _defaultInstance;

  /// request id for matching response
  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  /// query target client id
  @$pb.TagNumber(2)
  $core.String get targetClientId => $_getSZ(1);
  @$pb.TagNumber(2)
  set targetClientId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTargetClientId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTargetClientId() => $_clearField(2);

  /// requester client id (filled by server)
  @$pb.TagNumber(3)
  $core.String get requesterClientId => $_getSZ(2);
  @$pb.TagNumber(3)
  set requesterClientId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRequesterClientId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequesterClientId() => $_clearField(3);
}

/// ForwardStateQueryResponse returns forward capability and window list
class ForwardStateQueryResponse extends $pb.GeneratedMessage {
  factory ForwardStateQueryResponse({
    $core.String? requestId,
    $core.String? targetClientId,
    $core.String? responderClientId,
    $core.bool? forwardEnabled,
    $core.Iterable<ForwardWindowItem>? windows,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (targetClientId != null) result.targetClientId = targetClientId;
    if (responderClientId != null) result.responderClientId = responderClientId;
    if (forwardEnabled != null) result.forwardEnabled = forwardEnabled;
    if (windows != null) result.windows.addAll(windows);
    return result;
  }

  ForwardStateQueryResponse._();

  factory ForwardStateQueryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ForwardStateQueryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ForwardStateQueryResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOS(2, _omitFieldNames ? '' : 'targetClientId')
    ..aOS(3, _omitFieldNames ? '' : 'responderClientId')
    ..aOB(4, _omitFieldNames ? '' : 'forwardEnabled')
    ..pc<ForwardWindowItem>(
        5, _omitFieldNames ? '' : 'windows', $pb.PbFieldType.PM,
        subBuilder: ForwardWindowItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardStateQueryResponse clone() =>
      ForwardStateQueryResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardStateQueryResponse copyWith(
          void Function(ForwardStateQueryResponse) updates) =>
      super.copyWith((message) => updates(message as ForwardStateQueryResponse))
          as ForwardStateQueryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ForwardStateQueryResponse create() => ForwardStateQueryResponse._();
  @$core.override
  ForwardStateQueryResponse createEmptyInstance() => create();
  static $pb.PbList<ForwardStateQueryResponse> createRepeated() =>
      $pb.PbList<ForwardStateQueryResponse>();
  @$core.pragma('dart2js:noInline')
  static ForwardStateQueryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ForwardStateQueryResponse>(create);
  static ForwardStateQueryResponse? _defaultInstance;

  /// request id from ForwardStateQueryRequest
  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  /// response target client id (who should receive this response)
  @$pb.TagNumber(2)
  $core.String get targetClientId => $_getSZ(1);
  @$pb.TagNumber(2)
  set targetClientId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTargetClientId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTargetClientId() => $_clearField(2);

  /// responder client id
  @$pb.TagNumber(3)
  $core.String get responderClientId => $_getSZ(2);
  @$pb.TagNumber(3)
  set responderClientId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasResponderClientId() => $_has(2);
  @$pb.TagNumber(3)
  void clearResponderClientId() => $_clearField(3);

  /// whether responder has enabled auto forward to system input
  @$pb.TagNumber(4)
  $core.bool get forwardEnabled => $_getBF(3);
  @$pb.TagNumber(4)
  set forwardEnabled($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasForwardEnabled() => $_has(3);
  @$pb.TagNumber(4)
  void clearForwardEnabled() => $_clearField(4);

  /// current forwardable windows
  @$pb.TagNumber(5)
  $pb.PbList<ForwardWindowItem> get windows => $_getList(4);
}

/// ForwardStateChangedNotification notifies peers that sender's forward state changed
class ForwardStateChangedNotification extends $pb.GeneratedMessage {
  factory ForwardStateChangedNotification({
    $core.String? sourceClientId,
    $core.bool? forwardEnabled,
    $core.Iterable<ForwardWindowItem>? windows,
  }) {
    final result = create();
    if (sourceClientId != null) result.sourceClientId = sourceClientId;
    if (forwardEnabled != null) result.forwardEnabled = forwardEnabled;
    if (windows != null) result.windows.addAll(windows);
    return result;
  }

  ForwardStateChangedNotification._();

  factory ForwardStateChangedNotification.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ForwardStateChangedNotification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ForwardStateChangedNotification',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sourceClientId')
    ..aOB(2, _omitFieldNames ? '' : 'forwardEnabled')
    ..pc<ForwardWindowItem>(
        3, _omitFieldNames ? '' : 'windows', $pb.PbFieldType.PM,
        subBuilder: ForwardWindowItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardStateChangedNotification clone() =>
      ForwardStateChangedNotification()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardStateChangedNotification copyWith(
          void Function(ForwardStateChangedNotification) updates) =>
      super.copyWith(
              (message) => updates(message as ForwardStateChangedNotification))
          as ForwardStateChangedNotification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ForwardStateChangedNotification create() =>
      ForwardStateChangedNotification._();
  @$core.override
  ForwardStateChangedNotification createEmptyInstance() => create();
  static $pb.PbList<ForwardStateChangedNotification> createRepeated() =>
      $pb.PbList<ForwardStateChangedNotification>();
  @$core.pragma('dart2js:noInline')
  static ForwardStateChangedNotification getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ForwardStateChangedNotification>(
          create);
  static ForwardStateChangedNotification? _defaultInstance;

  /// source client id whose state changed
  @$pb.TagNumber(1)
  $core.String get sourceClientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sourceClientId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSourceClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSourceClientId() => $_clearField(1);

  /// whether source has enabled auto forward
  @$pb.TagNumber(2)
  $core.bool get forwardEnabled => $_getBF(1);
  @$pb.TagNumber(2)
  set forwardEnabled($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasForwardEnabled() => $_has(1);
  @$pb.TagNumber(2)
  void clearForwardEnabled() => $_clearField(2);

  /// current forwardable windows snapshot
  @$pb.TagNumber(3)
  $pb.PbList<ForwardWindowItem> get windows => $_getList(2);
}

/// ForwardDeliveryErrorNotification reports receiver could not forward to selected window
class ForwardDeliveryErrorNotification extends $pb.GeneratedMessage {
  factory ForwardDeliveryErrorNotification({
    $core.String? targetClientId,
    $core.String? peerClientId,
    $core.String? invalidWindowId,
    $core.String? reason,
  }) {
    final result = create();
    if (targetClientId != null) result.targetClientId = targetClientId;
    if (peerClientId != null) result.peerClientId = peerClientId;
    if (invalidWindowId != null) result.invalidWindowId = invalidWindowId;
    if (reason != null) result.reason = reason;
    return result;
  }

  ForwardDeliveryErrorNotification._();

  factory ForwardDeliveryErrorNotification.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ForwardDeliveryErrorNotification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ForwardDeliveryErrorNotification',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'targetClientId')
    ..aOS(2, _omitFieldNames ? '' : 'peerClientId')
    ..aOS(3, _omitFieldNames ? '' : 'invalidWindowId')
    ..aOS(4, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardDeliveryErrorNotification clone() =>
      ForwardDeliveryErrorNotification()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardDeliveryErrorNotification copyWith(
          void Function(ForwardDeliveryErrorNotification) updates) =>
      super.copyWith(
              (message) => updates(message as ForwardDeliveryErrorNotification))
          as ForwardDeliveryErrorNotification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ForwardDeliveryErrorNotification create() =>
      ForwardDeliveryErrorNotification._();
  @$core.override
  ForwardDeliveryErrorNotification createEmptyInstance() => create();
  static $pb.PbList<ForwardDeliveryErrorNotification> createRepeated() =>
      $pb.PbList<ForwardDeliveryErrorNotification>();
  @$core.pragma('dart2js:noInline')
  static ForwardDeliveryErrorNotification getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ForwardDeliveryErrorNotification>(
          create);
  static ForwardDeliveryErrorNotification? _defaultInstance;

  /// receiver of this error (usually original sender of chat message)
  @$pb.TagNumber(1)
  $core.String get targetClientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set targetClientId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTargetClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTargetClientId() => $_clearField(1);

  /// peer client id where forwarding failed
  @$pb.TagNumber(2)
  $core.String get peerClientId => $_getSZ(1);
  @$pb.TagNumber(2)
  set peerClientId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPeerClientId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPeerClientId() => $_clearField(2);

  /// invalid window id
  @$pb.TagNumber(3)
  $core.String get invalidWindowId => $_getSZ(2);
  @$pb.TagNumber(3)
  set invalidWindowId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasInvalidWindowId() => $_has(2);
  @$pb.TagNumber(3)
  void clearInvalidWindowId() => $_clearField(3);

  /// error reason
  @$pb.TagNumber(4)
  $core.String get reason => $_getSZ(3);
  @$pb.TagNumber(4)
  set reason($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReason() => $_has(3);
  @$pb.TagNumber(4)
  void clearReason() => $_clearField(4);
}

/// UserLoginResponse represents the response to a user login
class UserLoginResponse extends $pb.GeneratedMessage {
  factory UserLoginResponse({
    $core.String? clientId,
    $core.bool? success,
    $core.String? errorMessage,
  }) {
    final result = create();
    if (clientId != null) result.clientId = clientId;
    if (success != null) result.success = success;
    if (errorMessage != null) result.errorMessage = errorMessage;
    return result;
  }

  UserLoginResponse._();

  factory UserLoginResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserLoginResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserLoginResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'clientId')
    ..aOB(2, _omitFieldNames ? '' : 'success')
    ..aOS(3, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserLoginResponse clone() => UserLoginResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserLoginResponse copyWith(void Function(UserLoginResponse) updates) =>
      super.copyWith((message) => updates(message as UserLoginResponse))
          as UserLoginResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserLoginResponse create() => UserLoginResponse._();
  @$core.override
  UserLoginResponse createEmptyInstance() => create();
  static $pb.PbList<UserLoginResponse> createRepeated() =>
      $pb.PbList<UserLoginResponse>();
  @$core.pragma('dart2js:noInline')
  static UserLoginResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserLoginResponse>(create);
  static UserLoginResponse? _defaultInstance;

  /// client id assigned by server
  @$pb.TagNumber(1)
  $core.String get clientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientId() => $_clearField(1);

  /// success status
  @$pb.TagNumber(2)
  $core.bool get success => $_getBF(1);
  @$pb.TagNumber(2)
  set success($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSuccess() => $_has(1);
  @$pb.TagNumber(2)
  void clearSuccess() => $_clearField(2);

  /// error message if login failed
  @$pb.TagNumber(3)
  $core.String get errorMessage => $_getSZ(2);
  @$pb.TagNumber(3)
  set errorMessage($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasErrorMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearErrorMessage() => $_clearField(3);
}

/// UserConnectionStatusNotification represents a notification when a user
/// connects or disconnects
class UserConnectionStatusNotification extends $pb.GeneratedMessage {
  factory UserConnectionStatusNotification({
    OnlineUser? user,
    $core.String? status,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (user != null) result.user = user;
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  UserConnectionStatusNotification._();

  factory UserConnectionStatusNotification.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserConnectionStatusNotification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserConnectionStatusNotification',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOM<OnlineUser>(1, _omitFieldNames ? '' : 'user',
        subBuilder: OnlineUser.create)
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..aInt64(3, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserConnectionStatusNotification clone() =>
      UserConnectionStatusNotification()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserConnectionStatusNotification copyWith(
          void Function(UserConnectionStatusNotification) updates) =>
      super.copyWith(
              (message) => updates(message as UserConnectionStatusNotification))
          as UserConnectionStatusNotification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserConnectionStatusNotification create() =>
      UserConnectionStatusNotification._();
  @$core.override
  UserConnectionStatusNotification createEmptyInstance() => create();
  static $pb.PbList<UserConnectionStatusNotification> createRepeated() =>
      $pb.PbList<UserConnectionStatusNotification>();
  @$core.pragma('dart2js:noInline')
  static UserConnectionStatusNotification getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserConnectionStatusNotification>(
          create);
  static UserConnectionStatusNotification? _defaultInstance;

  /// the user who connected/disconnected
  @$pb.TagNumber(1)
  OnlineUser get user => $_getN(0);
  @$pb.TagNumber(1)
  set user(OnlineUser value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasUser() => $_has(0);
  @$pb.TagNumber(1)
  void clearUser() => $_clearField(1);
  @$pb.TagNumber(1)
  OnlineUser ensureUser() => $_ensure(0);

  /// connection status: "connected" or "disconnected"
  @$pb.TagNumber(2)
  $core.String get status => $_getSZ(1);
  @$pb.TagNumber(2)
  set status($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  /// timestamp of the status change
  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);
}

class WebsocketMessage extends $pb.GeneratedMessage {
  factory WebsocketMessage({
    $core.String? cmd,
    AskQuestionRequest? askQuestionRequest,
    WorkReportRequest? workReportRequest,
    AskQuestionResponse? askQuestionResponse,
    WorkReportResponse? workReportResponse,
    $core.String? strParam,
    CheckMessageValidityRequest? checkMessageValidityRequest,
    CheckMessageValidityResponse? checkMessageValidityResponse,
    GetPendingMessagesRequest? getPendingMessagesRequest,
    GetPendingMessagesResponse? getPendingMessagesResponse,
    RequestCancelledNotification? requestCancelledNotification,
    $core.String? nickname,
    GetOnlineUsersRequest? getOnlineUsersRequest,
    GetOnlineUsersResponse? getOnlineUsersResponse,
    SendChatMessageRequest? sendChatMessageRequest,
    ChatMessageNotification? chatMessageNotification,
    UserLoginResponse? userLoginResponse,
    UserConnectionStatusNotification? userConnectionStatusNotification,
    ForwardStateQueryRequest? forwardStateQueryRequest,
    ForwardStateQueryResponse? forwardStateQueryResponse,
    ForwardStateChangedNotification? forwardStateChangedNotification,
    ForwardDeliveryErrorNotification? forwardDeliveryErrorNotification,
  }) {
    final result = create();
    if (cmd != null) result.cmd = cmd;
    if (askQuestionRequest != null)
      result.askQuestionRequest = askQuestionRequest;
    if (workReportRequest != null) result.workReportRequest = workReportRequest;
    if (askQuestionResponse != null)
      result.askQuestionResponse = askQuestionResponse;
    if (workReportResponse != null)
      result.workReportResponse = workReportResponse;
    if (strParam != null) result.strParam = strParam;
    if (checkMessageValidityRequest != null)
      result.checkMessageValidityRequest = checkMessageValidityRequest;
    if (checkMessageValidityResponse != null)
      result.checkMessageValidityResponse = checkMessageValidityResponse;
    if (getPendingMessagesRequest != null)
      result.getPendingMessagesRequest = getPendingMessagesRequest;
    if (getPendingMessagesResponse != null)
      result.getPendingMessagesResponse = getPendingMessagesResponse;
    if (requestCancelledNotification != null)
      result.requestCancelledNotification = requestCancelledNotification;
    if (nickname != null) result.nickname = nickname;
    if (getOnlineUsersRequest != null)
      result.getOnlineUsersRequest = getOnlineUsersRequest;
    if (getOnlineUsersResponse != null)
      result.getOnlineUsersResponse = getOnlineUsersResponse;
    if (sendChatMessageRequest != null)
      result.sendChatMessageRequest = sendChatMessageRequest;
    if (chatMessageNotification != null)
      result.chatMessageNotification = chatMessageNotification;
    if (userLoginResponse != null) result.userLoginResponse = userLoginResponse;
    if (userConnectionStatusNotification != null)
      result.userConnectionStatusNotification =
          userConnectionStatusNotification;
    if (forwardStateQueryRequest != null)
      result.forwardStateQueryRequest = forwardStateQueryRequest;
    if (forwardStateQueryResponse != null)
      result.forwardStateQueryResponse = forwardStateQueryResponse;
    if (forwardStateChangedNotification != null)
      result.forwardStateChangedNotification = forwardStateChangedNotification;
    if (forwardDeliveryErrorNotification != null)
      result.forwardDeliveryErrorNotification =
          forwardDeliveryErrorNotification;
    return result;
  }

  WebsocketMessage._();

  factory WebsocketMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WebsocketMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WebsocketMessage',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'Cmd', protoName: 'Cmd')
    ..aOM<AskQuestionRequest>(2, _omitFieldNames ? '' : 'AskQuestionRequest',
        protoName: 'AskQuestionRequest', subBuilder: AskQuestionRequest.create)
    ..aOM<WorkReportRequest>(3, _omitFieldNames ? '' : 'WorkReportRequest',
        protoName: 'WorkReportRequest', subBuilder: WorkReportRequest.create)
    ..aOM<AskQuestionResponse>(4, _omitFieldNames ? '' : 'AskQuestionResponse',
        protoName: 'AskQuestionResponse',
        subBuilder: AskQuestionResponse.create)
    ..aOM<WorkReportResponse>(5, _omitFieldNames ? '' : 'WorkReportResponse',
        protoName: 'WorkReportResponse', subBuilder: WorkReportResponse.create)
    ..aOS(12, _omitFieldNames ? '' : 'StrParam', protoName: 'StrParam')
    ..aOM<CheckMessageValidityRequest>(
        13, _omitFieldNames ? '' : 'CheckMessageValidityRequest',
        protoName: 'CheckMessageValidityRequest',
        subBuilder: CheckMessageValidityRequest.create)
    ..aOM<CheckMessageValidityResponse>(
        14, _omitFieldNames ? '' : 'CheckMessageValidityResponse',
        protoName: 'CheckMessageValidityResponse',
        subBuilder: CheckMessageValidityResponse.create)
    ..aOM<GetPendingMessagesRequest>(
        15, _omitFieldNames ? '' : 'GetPendingMessagesRequest',
        protoName: 'GetPendingMessagesRequest',
        subBuilder: GetPendingMessagesRequest.create)
    ..aOM<GetPendingMessagesResponse>(
        16, _omitFieldNames ? '' : 'GetPendingMessagesResponse',
        protoName: 'GetPendingMessagesResponse',
        subBuilder: GetPendingMessagesResponse.create)
    ..aOM<RequestCancelledNotification>(
        17, _omitFieldNames ? '' : 'RequestCancelledNotification',
        protoName: 'RequestCancelledNotification',
        subBuilder: RequestCancelledNotification.create)
    ..aOS(18, _omitFieldNames ? '' : 'Nickname', protoName: 'Nickname')
    ..aOM<GetOnlineUsersRequest>(
        19, _omitFieldNames ? '' : 'GetOnlineUsersRequest',
        protoName: 'GetOnlineUsersRequest',
        subBuilder: GetOnlineUsersRequest.create)
    ..aOM<GetOnlineUsersResponse>(
        20, _omitFieldNames ? '' : 'GetOnlineUsersResponse',
        protoName: 'GetOnlineUsersResponse',
        subBuilder: GetOnlineUsersResponse.create)
    ..aOM<SendChatMessageRequest>(
        21, _omitFieldNames ? '' : 'SendChatMessageRequest',
        protoName: 'SendChatMessageRequest',
        subBuilder: SendChatMessageRequest.create)
    ..aOM<ChatMessageNotification>(
        22, _omitFieldNames ? '' : 'ChatMessageNotification',
        protoName: 'ChatMessageNotification',
        subBuilder: ChatMessageNotification.create)
    ..aOM<UserLoginResponse>(23, _omitFieldNames ? '' : 'UserLoginResponse',
        protoName: 'UserLoginResponse', subBuilder: UserLoginResponse.create)
    ..aOM<UserConnectionStatusNotification>(
        24, _omitFieldNames ? '' : 'UserConnectionStatusNotification',
        protoName: 'UserConnectionStatusNotification',
        subBuilder: UserConnectionStatusNotification.create)
    ..aOM<ForwardStateQueryRequest>(
        25, _omitFieldNames ? '' : 'ForwardStateQueryRequest',
        protoName: 'ForwardStateQueryRequest',
        subBuilder: ForwardStateQueryRequest.create)
    ..aOM<ForwardStateQueryResponse>(
        26, _omitFieldNames ? '' : 'ForwardStateQueryResponse',
        protoName: 'ForwardStateQueryResponse',
        subBuilder: ForwardStateQueryResponse.create)
    ..aOM<ForwardStateChangedNotification>(
        27, _omitFieldNames ? '' : 'ForwardStateChangedNotification',
        protoName: 'ForwardStateChangedNotification',
        subBuilder: ForwardStateChangedNotification.create)
    ..aOM<ForwardDeliveryErrorNotification>(
        28, _omitFieldNames ? '' : 'ForwardDeliveryErrorNotification',
        protoName: 'ForwardDeliveryErrorNotification',
        subBuilder: ForwardDeliveryErrorNotification.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WebsocketMessage clone() => WebsocketMessage()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WebsocketMessage copyWith(void Function(WebsocketMessage) updates) =>
      super.copyWith((message) => updates(message as WebsocketMessage))
          as WebsocketMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WebsocketMessage create() => WebsocketMessage._();
  @$core.override
  WebsocketMessage createEmptyInstance() => create();
  static $pb.PbList<WebsocketMessage> createRepeated() =>
      $pb.PbList<WebsocketMessage>();
  @$core.pragma('dart2js:noInline')
  static WebsocketMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WebsocketMessage>(create);
  static WebsocketMessage? _defaultInstance;

  /// WebsocketMessage cmd
  /// AskQuestion: mcp ask_question
  /// WorkReport: mcp work_report
  /// AskQuestionReply: user ask_question reply
  /// WorkReportReply: user work_report reply
  /// UserLogin: user login, str param is user token, nickname is user nickname
  /// AskQuestionReplyNotification: notification of an AskQuestionReply
  /// WorkReportReplyNotification: notification of a WorkReportReply
  /// CheckMessageValidity: check if messages are still valid
  /// GetPendingMessages: get all pending messages for a user
  /// RequestCancelled: notification that a request has been cancelled
  /// GetOnlineUsers: get online users with the same token
  /// SendChatMessage: send a chat message to another user
  /// ChatMessageNotification: notification of a new chat message
  /// ForwardStateQuery: query peer forward capability and windows
  /// ForwardStateQueryResponse: response for ForwardStateQuery
  /// ForwardStateChanged: notify peers that forward state changed
  /// ForwardDeliveryError: notify sender that selected target window is invalid
  @$pb.TagNumber(1)
  $core.String get cmd => $_getSZ(0);
  @$pb.TagNumber(1)
  set cmd($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCmd() => $_has(0);
  @$pb.TagNumber(1)
  void clearCmd() => $_clearField(1);

  /// ask question
  @$pb.TagNumber(2)
  AskQuestionRequest get askQuestionRequest => $_getN(1);
  @$pb.TagNumber(2)
  set askQuestionRequest(AskQuestionRequest value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAskQuestionRequest() => $_has(1);
  @$pb.TagNumber(2)
  void clearAskQuestionRequest() => $_clearField(2);
  @$pb.TagNumber(2)
  AskQuestionRequest ensureAskQuestionRequest() => $_ensure(1);

  /// work report
  @$pb.TagNumber(3)
  WorkReportRequest get workReportRequest => $_getN(2);
  @$pb.TagNumber(3)
  set workReportRequest(WorkReportRequest value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasWorkReportRequest() => $_has(2);
  @$pb.TagNumber(3)
  void clearWorkReportRequest() => $_clearField(3);
  @$pb.TagNumber(3)
  WorkReportRequest ensureWorkReportRequest() => $_ensure(2);

  /// ask question reply
  @$pb.TagNumber(4)
  AskQuestionResponse get askQuestionResponse => $_getN(3);
  @$pb.TagNumber(4)
  set askQuestionResponse(AskQuestionResponse value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasAskQuestionResponse() => $_has(3);
  @$pb.TagNumber(4)
  void clearAskQuestionResponse() => $_clearField(4);
  @$pb.TagNumber(4)
  AskQuestionResponse ensureAskQuestionResponse() => $_ensure(3);

  /// work report reply
  @$pb.TagNumber(5)
  WorkReportResponse get workReportResponse => $_getN(4);
  @$pb.TagNumber(5)
  set workReportResponse(WorkReportResponse value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasWorkReportResponse() => $_has(4);
  @$pb.TagNumber(5)
  void clearWorkReportResponse() => $_clearField(5);
  @$pb.TagNumber(5)
  WorkReportResponse ensureWorkReportResponse() => $_ensure(4);

  /// str param
  @$pb.TagNumber(12)
  $core.String get strParam => $_getSZ(5);
  @$pb.TagNumber(12)
  set strParam($core.String value) => $_setString(5, value);
  @$pb.TagNumber(12)
  $core.bool hasStrParam() => $_has(5);
  @$pb.TagNumber(12)
  void clearStrParam() => $_clearField(12);

  /// check message validity
  @$pb.TagNumber(13)
  CheckMessageValidityRequest get checkMessageValidityRequest => $_getN(6);
  @$pb.TagNumber(13)
  set checkMessageValidityRequest(CheckMessageValidityRequest value) =>
      $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasCheckMessageValidityRequest() => $_has(6);
  @$pb.TagNumber(13)
  void clearCheckMessageValidityRequest() => $_clearField(13);
  @$pb.TagNumber(13)
  CheckMessageValidityRequest ensureCheckMessageValidityRequest() =>
      $_ensure(6);

  /// check message validity response
  @$pb.TagNumber(14)
  CheckMessageValidityResponse get checkMessageValidityResponse => $_getN(7);
  @$pb.TagNumber(14)
  set checkMessageValidityResponse(CheckMessageValidityResponse value) =>
      $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasCheckMessageValidityResponse() => $_has(7);
  @$pb.TagNumber(14)
  void clearCheckMessageValidityResponse() => $_clearField(14);
  @$pb.TagNumber(14)
  CheckMessageValidityResponse ensureCheckMessageValidityResponse() =>
      $_ensure(7);

  /// get pending messages request
  @$pb.TagNumber(15)
  GetPendingMessagesRequest get getPendingMessagesRequest => $_getN(8);
  @$pb.TagNumber(15)
  set getPendingMessagesRequest(GetPendingMessagesRequest value) =>
      $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasGetPendingMessagesRequest() => $_has(8);
  @$pb.TagNumber(15)
  void clearGetPendingMessagesRequest() => $_clearField(15);
  @$pb.TagNumber(15)
  GetPendingMessagesRequest ensureGetPendingMessagesRequest() => $_ensure(8);

  /// get pending messages response
  @$pb.TagNumber(16)
  GetPendingMessagesResponse get getPendingMessagesResponse => $_getN(9);
  @$pb.TagNumber(16)
  set getPendingMessagesResponse(GetPendingMessagesResponse value) =>
      $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasGetPendingMessagesResponse() => $_has(9);
  @$pb.TagNumber(16)
  void clearGetPendingMessagesResponse() => $_clearField(16);
  @$pb.TagNumber(16)
  GetPendingMessagesResponse ensureGetPendingMessagesResponse() => $_ensure(9);

  /// request cancelled notification
  @$pb.TagNumber(17)
  RequestCancelledNotification get requestCancelledNotification => $_getN(10);
  @$pb.TagNumber(17)
  set requestCancelledNotification(RequestCancelledNotification value) =>
      $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasRequestCancelledNotification() => $_has(10);
  @$pb.TagNumber(17)
  void clearRequestCancelledNotification() => $_clearField(17);
  @$pb.TagNumber(17)
  RequestCancelledNotification ensureRequestCancelledNotification() =>
      $_ensure(10);

  /// user nickname (for UserLogin and notifications)
  @$pb.TagNumber(18)
  $core.String get nickname => $_getSZ(11);
  @$pb.TagNumber(18)
  set nickname($core.String value) => $_setString(11, value);
  @$pb.TagNumber(18)
  $core.bool hasNickname() => $_has(11);
  @$pb.TagNumber(18)
  void clearNickname() => $_clearField(18);

  /// get online users request
  @$pb.TagNumber(19)
  GetOnlineUsersRequest get getOnlineUsersRequest => $_getN(12);
  @$pb.TagNumber(19)
  set getOnlineUsersRequest(GetOnlineUsersRequest value) =>
      $_setField(19, value);
  @$pb.TagNumber(19)
  $core.bool hasGetOnlineUsersRequest() => $_has(12);
  @$pb.TagNumber(19)
  void clearGetOnlineUsersRequest() => $_clearField(19);
  @$pb.TagNumber(19)
  GetOnlineUsersRequest ensureGetOnlineUsersRequest() => $_ensure(12);

  /// get online users response
  @$pb.TagNumber(20)
  GetOnlineUsersResponse get getOnlineUsersResponse => $_getN(13);
  @$pb.TagNumber(20)
  set getOnlineUsersResponse(GetOnlineUsersResponse value) =>
      $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasGetOnlineUsersResponse() => $_has(13);
  @$pb.TagNumber(20)
  void clearGetOnlineUsersResponse() => $_clearField(20);
  @$pb.TagNumber(20)
  GetOnlineUsersResponse ensureGetOnlineUsersResponse() => $_ensure(13);

  /// send chat message request
  @$pb.TagNumber(21)
  SendChatMessageRequest get sendChatMessageRequest => $_getN(14);
  @$pb.TagNumber(21)
  set sendChatMessageRequest(SendChatMessageRequest value) =>
      $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasSendChatMessageRequest() => $_has(14);
  @$pb.TagNumber(21)
  void clearSendChatMessageRequest() => $_clearField(21);
  @$pb.TagNumber(21)
  SendChatMessageRequest ensureSendChatMessageRequest() => $_ensure(14);

  /// chat message notification
  @$pb.TagNumber(22)
  ChatMessageNotification get chatMessageNotification => $_getN(15);
  @$pb.TagNumber(22)
  set chatMessageNotification(ChatMessageNotification value) =>
      $_setField(22, value);
  @$pb.TagNumber(22)
  $core.bool hasChatMessageNotification() => $_has(15);
  @$pb.TagNumber(22)
  void clearChatMessageNotification() => $_clearField(22);
  @$pb.TagNumber(22)
  ChatMessageNotification ensureChatMessageNotification() => $_ensure(15);

  /// user login response
  @$pb.TagNumber(23)
  UserLoginResponse get userLoginResponse => $_getN(16);
  @$pb.TagNumber(23)
  set userLoginResponse(UserLoginResponse value) => $_setField(23, value);
  @$pb.TagNumber(23)
  $core.bool hasUserLoginResponse() => $_has(16);
  @$pb.TagNumber(23)
  void clearUserLoginResponse() => $_clearField(23);
  @$pb.TagNumber(23)
  UserLoginResponse ensureUserLoginResponse() => $_ensure(16);

  /// user connection status notification
  @$pb.TagNumber(24)
  UserConnectionStatusNotification get userConnectionStatusNotification =>
      $_getN(17);
  @$pb.TagNumber(24)
  set userConnectionStatusNotification(
          UserConnectionStatusNotification value) =>
      $_setField(24, value);
  @$pb.TagNumber(24)
  $core.bool hasUserConnectionStatusNotification() => $_has(17);
  @$pb.TagNumber(24)
  void clearUserConnectionStatusNotification() => $_clearField(24);
  @$pb.TagNumber(24)
  UserConnectionStatusNotification ensureUserConnectionStatusNotification() =>
      $_ensure(17);

  /// forward state query request
  @$pb.TagNumber(25)
  ForwardStateQueryRequest get forwardStateQueryRequest => $_getN(18);
  @$pb.TagNumber(25)
  set forwardStateQueryRequest(ForwardStateQueryRequest value) =>
      $_setField(25, value);
  @$pb.TagNumber(25)
  $core.bool hasForwardStateQueryRequest() => $_has(18);
  @$pb.TagNumber(25)
  void clearForwardStateQueryRequest() => $_clearField(25);
  @$pb.TagNumber(25)
  ForwardStateQueryRequest ensureForwardStateQueryRequest() => $_ensure(18);

  /// forward state query response
  @$pb.TagNumber(26)
  ForwardStateQueryResponse get forwardStateQueryResponse => $_getN(19);
  @$pb.TagNumber(26)
  set forwardStateQueryResponse(ForwardStateQueryResponse value) =>
      $_setField(26, value);
  @$pb.TagNumber(26)
  $core.bool hasForwardStateQueryResponse() => $_has(19);
  @$pb.TagNumber(26)
  void clearForwardStateQueryResponse() => $_clearField(26);
  @$pb.TagNumber(26)
  ForwardStateQueryResponse ensureForwardStateQueryResponse() => $_ensure(19);

  /// forward state changed notification
  @$pb.TagNumber(27)
  ForwardStateChangedNotification get forwardStateChangedNotification =>
      $_getN(20);
  @$pb.TagNumber(27)
  set forwardStateChangedNotification(ForwardStateChangedNotification value) =>
      $_setField(27, value);
  @$pb.TagNumber(27)
  $core.bool hasForwardStateChangedNotification() => $_has(20);
  @$pb.TagNumber(27)
  void clearForwardStateChangedNotification() => $_clearField(27);
  @$pb.TagNumber(27)
  ForwardStateChangedNotification ensureForwardStateChangedNotification() =>
      $_ensure(20);

  /// forward delivery error notification
  @$pb.TagNumber(28)
  ForwardDeliveryErrorNotification get forwardDeliveryErrorNotification =>
      $_getN(21);
  @$pb.TagNumber(28)
  set forwardDeliveryErrorNotification(
          ForwardDeliveryErrorNotification value) =>
      $_setField(28, value);
  @$pb.TagNumber(28)
  $core.bool hasForwardDeliveryErrorNotification() => $_has(21);
  @$pb.TagNumber(28)
  void clearForwardDeliveryErrorNotification() => $_clearField(28);
  @$pb.TagNumber(28)
  ForwardDeliveryErrorNotification ensureForwardDeliveryErrorNotification() =>
      $_ensure(21);
}

class SrvAgentAssistApi {
  final $pb.RpcClient _client;

  SrvAgentAssistApi(this._client);

  $async.Future<AskQuestionResponse> askQuestion(
          $pb.ClientContext? ctx, AskQuestionRequest request) =>
      _client.invoke<AskQuestionResponse>(
          ctx, 'SrvAgentAssist', 'AskQuestion', request, AskQuestionResponse());
  $async.Future<WorkReportResponse> workReport(
          $pb.ClientContext? ctx, WorkReportRequest request) =>
      _client.invoke<WorkReportResponse>(
          ctx, 'SrvAgentAssist', 'WorkReport', request, WorkReportResponse());
  $async.Future<McpClientInfoResponse> sendMcpClientInfo(
          $pb.ClientContext? ctx, McpClientInfoRequest request) =>
      _client.invoke<McpClientInfoResponse>(ctx, 'SrvAgentAssist',
          'SendMcpClientInfo', request, McpClientInfoResponse());
  $async.Future<McpHeartbeatResponse> heartbeat(
          $pb.ClientContext? ctx, McpHeartbeatRequest request) =>
      _client.invoke<McpHeartbeatResponse>(
          ctx, 'SrvAgentAssist', 'Heartbeat', request, McpHeartbeatResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
