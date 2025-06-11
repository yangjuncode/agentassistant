//
//  Generated code. Do not modify.
//  source: agentassist.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

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

  factory TextContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory TextContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TextContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TextContent clone() => TextContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TextContent copyWith(void Function(TextContent) updates) => super.copyWith((message) => updates(message as TextContent)) as TextContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TextContent create() => TextContent._();
  @$core.override
  TextContent createEmptyInstance() => create();
  static $pb.PbList<TextContent> createRepeated() => $pb.PbList<TextContent>();
  @$core.pragma('dart2js:noInline')
  static TextContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TextContent>(create);
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

  factory ImageContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ImageContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImageContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'data')
    ..aOS(3, _omitFieldNames ? '' : 'mimeType')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageContent clone() => ImageContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageContent copyWith(void Function(ImageContent) updates) => super.copyWith((message) => updates(message as ImageContent)) as ImageContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImageContent create() => ImageContent._();
  @$core.override
  ImageContent createEmptyInstance() => create();
  static $pb.PbList<ImageContent> createRepeated() => $pb.PbList<ImageContent>();
  @$core.pragma('dart2js:noInline')
  static ImageContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImageContent>(create);
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

  factory AudioContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AudioContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AudioContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'data')
    ..aOS(3, _omitFieldNames ? '' : 'mimeType')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AudioContent clone() => AudioContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AudioContent copyWith(void Function(AudioContent) updates) => super.copyWith((message) => updates(message as AudioContent)) as AudioContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AudioContent create() => AudioContent._();
  @$core.override
  AudioContent createEmptyInstance() => create();
  static $pb.PbList<AudioContent> createRepeated() => $pb.PbList<AudioContent>();
  @$core.pragma('dart2js:noInline')
  static AudioContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AudioContent>(create);
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

  factory EmbeddedResource.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory EmbeddedResource.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EmbeddedResource', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'uri')
    ..aOS(3, _omitFieldNames ? '' : 'mimeType')
    ..a<$core.List<$core.int>>(4, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EmbeddedResource clone() => EmbeddedResource()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EmbeddedResource copyWith(void Function(EmbeddedResource) updates) => super.copyWith((message) => updates(message as EmbeddedResource)) as EmbeddedResource;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EmbeddedResource create() => EmbeddedResource._();
  @$core.override
  EmbeddedResource createEmptyInstance() => create();
  static $pb.PbList<EmbeddedResource> createRepeated() => $pb.PbList<EmbeddedResource>();
  @$core.pragma('dart2js:noInline')
  static EmbeddedResource getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EmbeddedResource>(create);
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

  factory McpResultContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory McpResultContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'McpResultContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.O3)
    ..aOM<TextContent>(2, _omitFieldNames ? '' : 'text', subBuilder: TextContent.create)
    ..aOM<ImageContent>(3, _omitFieldNames ? '' : 'image', subBuilder: ImageContent.create)
    ..aOM<AudioContent>(4, _omitFieldNames ? '' : 'audio', subBuilder: AudioContent.create)
    ..aOM<EmbeddedResource>(5, _omitFieldNames ? '' : 'embeddedResource', subBuilder: EmbeddedResource.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpResultContent clone() => McpResultContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpResultContent copyWith(void Function(McpResultContent) updates) => super.copyWith((message) => updates(message as McpResultContent)) as McpResultContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static McpResultContent create() => McpResultContent._();
  @$core.override
  McpResultContent createEmptyInstance() => create();
  static $pb.PbList<McpResultContent> createRepeated() => $pb.PbList<McpResultContent>();
  @$core.pragma('dart2js:noInline')
  static McpResultContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<McpResultContent>(create);
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

  factory MsgEmpty.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory MsgEmpty.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MsgEmpty', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MsgEmpty clone() => MsgEmpty()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MsgEmpty copyWith(void Function(MsgEmpty) updates) => super.copyWith((message) => updates(message as MsgEmpty)) as MsgEmpty;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MsgEmpty create() => MsgEmpty._();
  @$core.override
  MsgEmpty createEmptyInstance() => create();
  static $pb.PbList<MsgEmpty> createRepeated() => $pb.PbList<MsgEmpty>();
  @$core.pragma('dart2js:noInline')
  static MsgEmpty getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgEmpty>(create);
  static MsgEmpty? _defaultInstance;
}

class McpAskQuestionRequest extends $pb.GeneratedMessage {
  factory McpAskQuestionRequest({
    $core.String? projectDirectory,
    $core.String? question,
    $core.int? timeout,
  }) {
    final result = create();
    if (projectDirectory != null) result.projectDirectory = projectDirectory;
    if (question != null) result.question = question;
    if (timeout != null) result.timeout = timeout;
    return result;
  }

  McpAskQuestionRequest._();

  factory McpAskQuestionRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory McpAskQuestionRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'McpAskQuestionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ProjectDirectory', protoName: 'ProjectDirectory')
    ..aOS(2, _omitFieldNames ? '' : 'Question', protoName: 'Question')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'Timeout', $pb.PbFieldType.O3, protoName: 'Timeout')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpAskQuestionRequest clone() => McpAskQuestionRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpAskQuestionRequest copyWith(void Function(McpAskQuestionRequest) updates) => super.copyWith((message) => updates(message as McpAskQuestionRequest)) as McpAskQuestionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static McpAskQuestionRequest create() => McpAskQuestionRequest._();
  @$core.override
  McpAskQuestionRequest createEmptyInstance() => create();
  static $pb.PbList<McpAskQuestionRequest> createRepeated() => $pb.PbList<McpAskQuestionRequest>();
  @$core.pragma('dart2js:noInline')
  static McpAskQuestionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<McpAskQuestionRequest>(create);
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
  @$pb.TagNumber(2)
  $core.String get question => $_getSZ(1);
  @$pb.TagNumber(2)
  set question($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQuestion() => $_has(1);
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
}

class AskQuestionRequest extends $pb.GeneratedMessage {
  factory AskQuestionRequest({
    $core.String? iD,
    $core.String? userToken,
    McpAskQuestionRequest? request,
  }) {
    final result = create();
    if (iD != null) result.iD = iD;
    if (userToken != null) result.userToken = userToken;
    if (request != null) result.request = request;
    return result;
  }

  AskQuestionRequest._();

  factory AskQuestionRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AskQuestionRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AskQuestionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ID', protoName: 'ID')
    ..aOS(2, _omitFieldNames ? '' : 'UserToken', protoName: 'UserToken')
    ..aOM<McpAskQuestionRequest>(3, _omitFieldNames ? '' : 'Request', protoName: 'Request', subBuilder: McpAskQuestionRequest.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AskQuestionRequest clone() => AskQuestionRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AskQuestionRequest copyWith(void Function(AskQuestionRequest) updates) => super.copyWith((message) => updates(message as AskQuestionRequest)) as AskQuestionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AskQuestionRequest create() => AskQuestionRequest._();
  @$core.override
  AskQuestionRequest createEmptyInstance() => create();
  static $pb.PbList<AskQuestionRequest> createRepeated() => $pb.PbList<AskQuestionRequest>();
  @$core.pragma('dart2js:noInline')
  static AskQuestionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AskQuestionRequest>(create);
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

  factory AskQuestionResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AskQuestionResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AskQuestionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ID', protoName: 'ID')
    ..aOB(2, _omitFieldNames ? '' : 'IsError', protoName: 'IsError')
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'Meta', protoName: 'Meta', entryClassName: 'AskQuestionResponse.MetaEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('agentassistproto'))
    ..pc<McpResultContent>(4, _omitFieldNames ? '' : 'contents', $pb.PbFieldType.PM, subBuilder: McpResultContent.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AskQuestionResponse clone() => AskQuestionResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AskQuestionResponse copyWith(void Function(AskQuestionResponse) updates) => super.copyWith((message) => updates(message as AskQuestionResponse)) as AskQuestionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AskQuestionResponse create() => AskQuestionResponse._();
  @$core.override
  AskQuestionResponse createEmptyInstance() => create();
  static $pb.PbList<AskQuestionResponse> createRepeated() => $pb.PbList<AskQuestionResponse>();
  @$core.pragma('dart2js:noInline')
  static AskQuestionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AskQuestionResponse>(create);
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

class McpTaskFinishRequest extends $pb.GeneratedMessage {
  factory McpTaskFinishRequest({
    $core.String? projectDirectory,
    $core.String? summary,
    $core.int? timeout,
  }) {
    final result = create();
    if (projectDirectory != null) result.projectDirectory = projectDirectory;
    if (summary != null) result.summary = summary;
    if (timeout != null) result.timeout = timeout;
    return result;
  }

  McpTaskFinishRequest._();

  factory McpTaskFinishRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory McpTaskFinishRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'McpTaskFinishRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ProjectDirectory', protoName: 'ProjectDirectory')
    ..aOS(2, _omitFieldNames ? '' : 'Summary', protoName: 'Summary')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'Timeout', $pb.PbFieldType.O3, protoName: 'Timeout')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpTaskFinishRequest clone() => McpTaskFinishRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpTaskFinishRequest copyWith(void Function(McpTaskFinishRequest) updates) => super.copyWith((message) => updates(message as McpTaskFinishRequest)) as McpTaskFinishRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static McpTaskFinishRequest create() => McpTaskFinishRequest._();
  @$core.override
  McpTaskFinishRequest createEmptyInstance() => create();
  static $pb.PbList<McpTaskFinishRequest> createRepeated() => $pb.PbList<McpTaskFinishRequest>();
  @$core.pragma('dart2js:noInline')
  static McpTaskFinishRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<McpTaskFinishRequest>(create);
  static McpTaskFinishRequest? _defaultInstance;

  /// current project directory
  @$pb.TagNumber(1)
  $core.String get projectDirectory => $_getSZ(0);
  @$pb.TagNumber(1)
  set projectDirectory($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProjectDirectory() => $_has(0);
  @$pb.TagNumber(1)
  void clearProjectDirectory() => $_clearField(1);

  /// ai agent's summary
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
}

class TaskFinishRequest extends $pb.GeneratedMessage {
  factory TaskFinishRequest({
    $core.String? iD,
    $core.String? userToken,
    McpTaskFinishRequest? request,
  }) {
    final result = create();
    if (iD != null) result.iD = iD;
    if (userToken != null) result.userToken = userToken;
    if (request != null) result.request = request;
    return result;
  }

  TaskFinishRequest._();

  factory TaskFinishRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory TaskFinishRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TaskFinishRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ID', protoName: 'ID')
    ..aOS(2, _omitFieldNames ? '' : 'UserToken', protoName: 'UserToken')
    ..aOM<McpTaskFinishRequest>(3, _omitFieldNames ? '' : 'Request', protoName: 'Request', subBuilder: McpTaskFinishRequest.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskFinishRequest clone() => TaskFinishRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskFinishRequest copyWith(void Function(TaskFinishRequest) updates) => super.copyWith((message) => updates(message as TaskFinishRequest)) as TaskFinishRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TaskFinishRequest create() => TaskFinishRequest._();
  @$core.override
  TaskFinishRequest createEmptyInstance() => create();
  static $pb.PbList<TaskFinishRequest> createRepeated() => $pb.PbList<TaskFinishRequest>();
  @$core.pragma('dart2js:noInline')
  static TaskFinishRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskFinishRequest>(create);
  static TaskFinishRequest? _defaultInstance;

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

  /// ai agent's summary
  @$pb.TagNumber(3)
  McpTaskFinishRequest get request => $_getN(2);
  @$pb.TagNumber(3)
  set request(McpTaskFinishRequest value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasRequest() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequest() => $_clearField(3);
  @$pb.TagNumber(3)
  McpTaskFinishRequest ensureRequest() => $_ensure(2);
}

class TaskFinishResponse extends $pb.GeneratedMessage {
  factory TaskFinishResponse({
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

  TaskFinishResponse._();

  factory TaskFinishResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory TaskFinishResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TaskFinishResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ID', protoName: 'ID')
    ..aOB(2, _omitFieldNames ? '' : 'IsError', protoName: 'IsError')
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'Meta', protoName: 'Meta', entryClassName: 'TaskFinishResponse.MetaEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('agentassistproto'))
    ..pc<McpResultContent>(4, _omitFieldNames ? '' : 'contents', $pb.PbFieldType.PM, subBuilder: McpResultContent.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskFinishResponse clone() => TaskFinishResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskFinishResponse copyWith(void Function(TaskFinishResponse) updates) => super.copyWith((message) => updates(message as TaskFinishResponse)) as TaskFinishResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TaskFinishResponse create() => TaskFinishResponse._();
  @$core.override
  TaskFinishResponse createEmptyInstance() => create();
  static $pb.PbList<TaskFinishResponse> createRepeated() => $pb.PbList<TaskFinishResponse>();
  @$core.pragma('dart2js:noInline')
  static TaskFinishResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskFinishResponse>(create);
  static TaskFinishResponse? _defaultInstance;

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

class CheckMessageValidityRequest extends $pb.GeneratedMessage {
  factory CheckMessageValidityRequest({
    $core.Iterable<$core.String>? requestIds,
  }) {
    final result = create();
    if (requestIds != null) result.requestIds.addAll(requestIds);
    return result;
  }

  CheckMessageValidityRequest._();

  factory CheckMessageValidityRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CheckMessageValidityRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CheckMessageValidityRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'requestIds')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckMessageValidityRequest clone() => CheckMessageValidityRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckMessageValidityRequest copyWith(void Function(CheckMessageValidityRequest) updates) => super.copyWith((message) => updates(message as CheckMessageValidityRequest)) as CheckMessageValidityRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckMessageValidityRequest create() => CheckMessageValidityRequest._();
  @$core.override
  CheckMessageValidityRequest createEmptyInstance() => create();
  static $pb.PbList<CheckMessageValidityRequest> createRepeated() => $pb.PbList<CheckMessageValidityRequest>();
  @$core.pragma('dart2js:noInline')
  static CheckMessageValidityRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CheckMessageValidityRequest>(create);
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

  factory CheckMessageValidityResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CheckMessageValidityResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CheckMessageValidityResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..m<$core.String, $core.bool>(1, _omitFieldNames ? '' : 'validity', entryClassName: 'CheckMessageValidityResponse.ValidityEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OB, packageName: const $pb.PackageName('agentassistproto'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckMessageValidityResponse clone() => CheckMessageValidityResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckMessageValidityResponse copyWith(void Function(CheckMessageValidityResponse) updates) => super.copyWith((message) => updates(message as CheckMessageValidityResponse)) as CheckMessageValidityResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckMessageValidityResponse create() => CheckMessageValidityResponse._();
  @$core.override
  CheckMessageValidityResponse createEmptyInstance() => create();
  static $pb.PbList<CheckMessageValidityResponse> createRepeated() => $pb.PbList<CheckMessageValidityResponse>();
  @$core.pragma('dart2js:noInline')
  static CheckMessageValidityResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CheckMessageValidityResponse>(create);
  static CheckMessageValidityResponse? _defaultInstance;

  /// map of request ID to validity status
  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, $core.bool> get validity => $_getMap(0);
}

class WebsocketMessage extends $pb.GeneratedMessage {
  factory WebsocketMessage({
    $core.String? cmd,
    AskQuestionRequest? askQuestionRequest,
    TaskFinishRequest? taskFinishRequest,
    AskQuestionResponse? askQuestionResponse,
    TaskFinishResponse? taskFinishResponse,
    $core.String? strParam,
    CheckMessageValidityRequest? checkMessageValidityRequest,
    CheckMessageValidityResponse? checkMessageValidityResponse,
  }) {
    final result = create();
    if (cmd != null) result.cmd = cmd;
    if (askQuestionRequest != null) result.askQuestionRequest = askQuestionRequest;
    if (taskFinishRequest != null) result.taskFinishRequest = taskFinishRequest;
    if (askQuestionResponse != null) result.askQuestionResponse = askQuestionResponse;
    if (taskFinishResponse != null) result.taskFinishResponse = taskFinishResponse;
    if (strParam != null) result.strParam = strParam;
    if (checkMessageValidityRequest != null) result.checkMessageValidityRequest = checkMessageValidityRequest;
    if (checkMessageValidityResponse != null) result.checkMessageValidityResponse = checkMessageValidityResponse;
    return result;
  }

  WebsocketMessage._();

  factory WebsocketMessage.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory WebsocketMessage.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WebsocketMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'Cmd', protoName: 'Cmd')
    ..aOM<AskQuestionRequest>(2, _omitFieldNames ? '' : 'AskQuestionRequest', protoName: 'AskQuestionRequest', subBuilder: AskQuestionRequest.create)
    ..aOM<TaskFinishRequest>(3, _omitFieldNames ? '' : 'TaskFinishRequest', protoName: 'TaskFinishRequest', subBuilder: TaskFinishRequest.create)
    ..aOM<AskQuestionResponse>(4, _omitFieldNames ? '' : 'AskQuestionResponse', protoName: 'AskQuestionResponse', subBuilder: AskQuestionResponse.create)
    ..aOM<TaskFinishResponse>(5, _omitFieldNames ? '' : 'TaskFinishResponse', protoName: 'TaskFinishResponse', subBuilder: TaskFinishResponse.create)
    ..aOS(12, _omitFieldNames ? '' : 'StrParam', protoName: 'StrParam')
    ..aOM<CheckMessageValidityRequest>(13, _omitFieldNames ? '' : 'CheckMessageValidityRequest', protoName: 'CheckMessageValidityRequest', subBuilder: CheckMessageValidityRequest.create)
    ..aOM<CheckMessageValidityResponse>(14, _omitFieldNames ? '' : 'CheckMessageValidityResponse', protoName: 'CheckMessageValidityResponse', subBuilder: CheckMessageValidityResponse.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WebsocketMessage clone() => WebsocketMessage()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WebsocketMessage copyWith(void Function(WebsocketMessage) updates) => super.copyWith((message) => updates(message as WebsocketMessage)) as WebsocketMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WebsocketMessage create() => WebsocketMessage._();
  @$core.override
  WebsocketMessage createEmptyInstance() => create();
  static $pb.PbList<WebsocketMessage> createRepeated() => $pb.PbList<WebsocketMessage>();
  @$core.pragma('dart2js:noInline')
  static WebsocketMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WebsocketMessage>(create);
  static WebsocketMessage? _defaultInstance;

  /// WebsocketMessage cmd
  /// AskQuestion: mcp ask_question
  /// TaskFinish: mcp task_finish
  /// AskQuestionReply: user ask_question reply
  /// TaskFinishReply: user task_finish reply
  /// UserLogin: user login, str param is user token
  /// AskQuestionReplyNotification: notification of an AskQuestionReply
  /// TaskFinishReplyNotification: notification of a TaskFinishReply
  /// CheckMessageValidity: check if messages are still valid
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

  /// task finish
  @$pb.TagNumber(3)
  TaskFinishRequest get taskFinishRequest => $_getN(2);
  @$pb.TagNumber(3)
  set taskFinishRequest(TaskFinishRequest value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTaskFinishRequest() => $_has(2);
  @$pb.TagNumber(3)
  void clearTaskFinishRequest() => $_clearField(3);
  @$pb.TagNumber(3)
  TaskFinishRequest ensureTaskFinishRequest() => $_ensure(2);

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

  /// task finish reply
  @$pb.TagNumber(5)
  TaskFinishResponse get taskFinishResponse => $_getN(4);
  @$pb.TagNumber(5)
  set taskFinishResponse(TaskFinishResponse value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasTaskFinishResponse() => $_has(4);
  @$pb.TagNumber(5)
  void clearTaskFinishResponse() => $_clearField(5);
  @$pb.TagNumber(5)
  TaskFinishResponse ensureTaskFinishResponse() => $_ensure(4);

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
  set checkMessageValidityRequest(CheckMessageValidityRequest value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasCheckMessageValidityRequest() => $_has(6);
  @$pb.TagNumber(13)
  void clearCheckMessageValidityRequest() => $_clearField(13);
  @$pb.TagNumber(13)
  CheckMessageValidityRequest ensureCheckMessageValidityRequest() => $_ensure(6);

  /// check message validity response
  @$pb.TagNumber(14)
  CheckMessageValidityResponse get checkMessageValidityResponse => $_getN(7);
  @$pb.TagNumber(14)
  set checkMessageValidityResponse(CheckMessageValidityResponse value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasCheckMessageValidityResponse() => $_has(7);
  @$pb.TagNumber(14)
  void clearCheckMessageValidityResponse() => $_clearField(14);
  @$pb.TagNumber(14)
  CheckMessageValidityResponse ensureCheckMessageValidityResponse() => $_ensure(7);
}

class SrvAgentAssistApi {
  final $pb.RpcClient _client;

  SrvAgentAssistApi(this._client);

  $async.Future<AskQuestionResponse> askQuestion($pb.ClientContext? ctx, AskQuestionRequest request) =>
    _client.invoke<AskQuestionResponse>(ctx, 'SrvAgentAssist', 'AskQuestion', request, AskQuestionResponse())
  ;
  $async.Future<TaskFinishResponse> taskFinish($pb.ClientContext? ctx, TaskFinishRequest request) =>
    _client.invoke<TaskFinishResponse>(ctx, 'SrvAgentAssist', 'TaskFinish', request, TaskFinishResponse())
  ;
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
