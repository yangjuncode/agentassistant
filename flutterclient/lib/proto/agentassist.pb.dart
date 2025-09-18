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

import 'package:fixnum/fixnum.dart' as $fixnum;
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

class McpWorkReportRequest extends $pb.GeneratedMessage {
  factory McpWorkReportRequest({
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

  McpWorkReportRequest._();

  factory McpWorkReportRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory McpWorkReportRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'McpWorkReportRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ProjectDirectory', protoName: 'ProjectDirectory')
    ..aOS(2, _omitFieldNames ? '' : 'Summary', protoName: 'Summary')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'Timeout', $pb.PbFieldType.O3, protoName: 'Timeout')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpWorkReportRequest clone() => McpWorkReportRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  McpWorkReportRequest copyWith(void Function(McpWorkReportRequest) updates) => super.copyWith((message) => updates(message as McpWorkReportRequest)) as McpWorkReportRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static McpWorkReportRequest create() => McpWorkReportRequest._();
  @$core.override
  McpWorkReportRequest createEmptyInstance() => create();
  static $pb.PbList<McpWorkReportRequest> createRepeated() => $pb.PbList<McpWorkReportRequest>();
  @$core.pragma('dart2js:noInline')
  static McpWorkReportRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<McpWorkReportRequest>(create);
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
}

class WorkReportRequest extends $pb.GeneratedMessage {
  factory WorkReportRequest({
    $core.String? iD,
    $core.String? userToken,
    McpWorkReportRequest? request,
  }) {
    final result = create();
    if (iD != null) result.iD = iD;
    if (userToken != null) result.userToken = userToken;
    if (request != null) result.request = request;
    return result;
  }

  WorkReportRequest._();

  factory WorkReportRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory WorkReportRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WorkReportRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ID', protoName: 'ID')
    ..aOS(2, _omitFieldNames ? '' : 'UserToken', protoName: 'UserToken')
    ..aOM<McpWorkReportRequest>(3, _omitFieldNames ? '' : 'Request', protoName: 'Request', subBuilder: McpWorkReportRequest.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkReportRequest clone() => WorkReportRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkReportRequest copyWith(void Function(WorkReportRequest) updates) => super.copyWith((message) => updates(message as WorkReportRequest)) as WorkReportRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WorkReportRequest create() => WorkReportRequest._();
  @$core.override
  WorkReportRequest createEmptyInstance() => create();
  static $pb.PbList<WorkReportRequest> createRepeated() => $pb.PbList<WorkReportRequest>();
  @$core.pragma('dart2js:noInline')
  static WorkReportRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WorkReportRequest>(create);
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

  factory WorkReportResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory WorkReportResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WorkReportResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ID', protoName: 'ID')
    ..aOB(2, _omitFieldNames ? '' : 'IsError', protoName: 'IsError')
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'Meta', protoName: 'Meta', entryClassName: 'WorkReportResponse.MetaEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('agentassistproto'))
    ..pc<McpResultContent>(4, _omitFieldNames ? '' : 'contents', $pb.PbFieldType.PM, subBuilder: McpResultContent.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkReportResponse clone() => WorkReportResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkReportResponse copyWith(void Function(WorkReportResponse) updates) => super.copyWith((message) => updates(message as WorkReportResponse)) as WorkReportResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WorkReportResponse create() => WorkReportResponse._();
  @$core.override
  WorkReportResponse createEmptyInstance() => create();
  static $pb.PbList<WorkReportResponse> createRepeated() => $pb.PbList<WorkReportResponse>();
  @$core.pragma('dart2js:noInline')
  static WorkReportResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WorkReportResponse>(create);
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

/// GetPendingMessagesRequest represents a request to get all pending messages for a user
class GetPendingMessagesRequest extends $pb.GeneratedMessage {
  factory GetPendingMessagesRequest({
    $core.String? userToken,
  }) {
    final result = create();
    if (userToken != null) result.userToken = userToken;
    return result;
  }

  GetPendingMessagesRequest._();

  factory GetPendingMessagesRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GetPendingMessagesRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPendingMessagesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userToken')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPendingMessagesRequest clone() => GetPendingMessagesRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPendingMessagesRequest copyWith(void Function(GetPendingMessagesRequest) updates) => super.copyWith((message) => updates(message as GetPendingMessagesRequest)) as GetPendingMessagesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPendingMessagesRequest create() => GetPendingMessagesRequest._();
  @$core.override
  GetPendingMessagesRequest createEmptyInstance() => create();
  static $pb.PbList<GetPendingMessagesRequest> createRepeated() => $pb.PbList<GetPendingMessagesRequest>();
  @$core.pragma('dart2js:noInline')
  static GetPendingMessagesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetPendingMessagesRequest>(create);
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
    if (askQuestionRequest != null) result.askQuestionRequest = askQuestionRequest;
    if (workReportRequest != null) result.workReportRequest = workReportRequest;
    if (createdAt != null) result.createdAt = createdAt;
    if (timeout != null) result.timeout = timeout;
    return result;
  }

  PendingMessage._();

  factory PendingMessage.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory PendingMessage.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PendingMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageType')
    ..aOM<AskQuestionRequest>(2, _omitFieldNames ? '' : 'askQuestionRequest', subBuilder: AskQuestionRequest.create)
    ..aOM<WorkReportRequest>(3, _omitFieldNames ? '' : 'workReportRequest', subBuilder: WorkReportRequest.create)
    ..aInt64(4, _omitFieldNames ? '' : 'createdAt')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'timeout', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PendingMessage clone() => PendingMessage()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PendingMessage copyWith(void Function(PendingMessage) updates) => super.copyWith((message) => updates(message as PendingMessage)) as PendingMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PendingMessage create() => PendingMessage._();
  @$core.override
  PendingMessage createEmptyInstance() => create();
  static $pb.PbList<PendingMessage> createRepeated() => $pb.PbList<PendingMessage>();
  @$core.pragma('dart2js:noInline')
  static PendingMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PendingMessage>(create);
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

/// GetPendingMessagesResponse represents the response containing all pending messages
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

  factory GetPendingMessagesResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GetPendingMessagesResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPendingMessagesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..pc<PendingMessage>(1, _omitFieldNames ? '' : 'pendingMessages', $pb.PbFieldType.PM, subBuilder: PendingMessage.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'totalCount', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPendingMessagesResponse clone() => GetPendingMessagesResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPendingMessagesResponse copyWith(void Function(GetPendingMessagesResponse) updates) => super.copyWith((message) => updates(message as GetPendingMessagesResponse)) as GetPendingMessagesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPendingMessagesResponse create() => GetPendingMessagesResponse._();
  @$core.override
  GetPendingMessagesResponse createEmptyInstance() => create();
  static $pb.PbList<GetPendingMessagesResponse> createRepeated() => $pb.PbList<GetPendingMessagesResponse>();
  @$core.pragma('dart2js:noInline')
  static GetPendingMessagesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetPendingMessagesResponse>(create);
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

/// RequestCancelledNotification represents a notification that a request has been cancelled
class RequestCancelledNotification extends $pb.GeneratedMessage {
  factory RequestCancelledNotification({
    $core.String? requestId,
    $core.String? reason,
    $core.String? messageType,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (reason != null) result.reason = reason;
    if (messageType != null) result.messageType = messageType;
    return result;
  }

  RequestCancelledNotification._();

  factory RequestCancelledNotification.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory RequestCancelledNotification.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RequestCancelledNotification', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..aOS(3, _omitFieldNames ? '' : 'messageType')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestCancelledNotification clone() => RequestCancelledNotification()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestCancelledNotification copyWith(void Function(RequestCancelledNotification) updates) => super.copyWith((message) => updates(message as RequestCancelledNotification)) as RequestCancelledNotification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestCancelledNotification create() => RequestCancelledNotification._();
  @$core.override
  RequestCancelledNotification createEmptyInstance() => create();
  static $pb.PbList<RequestCancelledNotification> createRepeated() => $pb.PbList<RequestCancelledNotification>();
  @$core.pragma('dart2js:noInline')
  static RequestCancelledNotification getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RequestCancelledNotification>(create);
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

  factory OnlineUser.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory OnlineUser.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OnlineUser', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'clientId')
    ..aOS(2, _omitFieldNames ? '' : 'nickname')
    ..aInt64(3, _omitFieldNames ? '' : 'connectedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnlineUser clone() => OnlineUser()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnlineUser copyWith(void Function(OnlineUser) updates) => super.copyWith((message) => updates(message as OnlineUser)) as OnlineUser;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OnlineUser create() => OnlineUser._();
  @$core.override
  OnlineUser createEmptyInstance() => create();
  static $pb.PbList<OnlineUser> createRepeated() => $pb.PbList<OnlineUser>();
  @$core.pragma('dart2js:noInline')
  static OnlineUser getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OnlineUser>(create);
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

/// GetOnlineUsersRequest represents a request to get online users with the same token
class GetOnlineUsersRequest extends $pb.GeneratedMessage {
  factory GetOnlineUsersRequest({
    $core.String? userToken,
  }) {
    final result = create();
    if (userToken != null) result.userToken = userToken;
    return result;
  }

  GetOnlineUsersRequest._();

  factory GetOnlineUsersRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GetOnlineUsersRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetOnlineUsersRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userToken')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOnlineUsersRequest clone() => GetOnlineUsersRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOnlineUsersRequest copyWith(void Function(GetOnlineUsersRequest) updates) => super.copyWith((message) => updates(message as GetOnlineUsersRequest)) as GetOnlineUsersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetOnlineUsersRequest create() => GetOnlineUsersRequest._();
  @$core.override
  GetOnlineUsersRequest createEmptyInstance() => create();
  static $pb.PbList<GetOnlineUsersRequest> createRepeated() => $pb.PbList<GetOnlineUsersRequest>();
  @$core.pragma('dart2js:noInline')
  static GetOnlineUsersRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetOnlineUsersRequest>(create);
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

  factory GetOnlineUsersResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GetOnlineUsersResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetOnlineUsersResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..pc<OnlineUser>(1, _omitFieldNames ? '' : 'onlineUsers', $pb.PbFieldType.PM, subBuilder: OnlineUser.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'totalCount', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOnlineUsersResponse clone() => GetOnlineUsersResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOnlineUsersResponse copyWith(void Function(GetOnlineUsersResponse) updates) => super.copyWith((message) => updates(message as GetOnlineUsersResponse)) as GetOnlineUsersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetOnlineUsersResponse create() => GetOnlineUsersResponse._();
  @$core.override
  GetOnlineUsersResponse createEmptyInstance() => create();
  static $pb.PbList<GetOnlineUsersResponse> createRepeated() => $pb.PbList<GetOnlineUsersResponse>();
  @$core.pragma('dart2js:noInline')
  static GetOnlineUsersResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetOnlineUsersResponse>(create);
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
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (senderClientId != null) result.senderClientId = senderClientId;
    if (senderNickname != null) result.senderNickname = senderNickname;
    if (receiverClientId != null) result.receiverClientId = receiverClientId;
    if (receiverNickname != null) result.receiverNickname = receiverNickname;
    if (content != null) result.content = content;
    if (sentAt != null) result.sentAt = sentAt;
    return result;
  }

  ChatMessage._();

  factory ChatMessage.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ChatMessage.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChatMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOS(2, _omitFieldNames ? '' : 'senderClientId')
    ..aOS(3, _omitFieldNames ? '' : 'senderNickname')
    ..aOS(4, _omitFieldNames ? '' : 'receiverClientId')
    ..aOS(5, _omitFieldNames ? '' : 'receiverNickname')
    ..aOS(6, _omitFieldNames ? '' : 'content')
    ..aInt64(7, _omitFieldNames ? '' : 'sentAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage clone() => ChatMessage()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage copyWith(void Function(ChatMessage) updates) => super.copyWith((message) => updates(message as ChatMessage)) as ChatMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatMessage create() => ChatMessage._();
  @$core.override
  ChatMessage createEmptyInstance() => create();
  static $pb.PbList<ChatMessage> createRepeated() => $pb.PbList<ChatMessage>();
  @$core.pragma('dart2js:noInline')
  static ChatMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatMessage>(create);
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
}

/// SendChatMessageRequest represents a request to send a chat message
class SendChatMessageRequest extends $pb.GeneratedMessage {
  factory SendChatMessageRequest({
    $core.String? receiverClientId,
    $core.String? content,
  }) {
    final result = create();
    if (receiverClientId != null) result.receiverClientId = receiverClientId;
    if (content != null) result.content = content;
    return result;
  }

  SendChatMessageRequest._();

  factory SendChatMessageRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory SendChatMessageRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendChatMessageRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'receiverClientId')
    ..aOS(2, _omitFieldNames ? '' : 'content')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendChatMessageRequest clone() => SendChatMessageRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendChatMessageRequest copyWith(void Function(SendChatMessageRequest) updates) => super.copyWith((message) => updates(message as SendChatMessageRequest)) as SendChatMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendChatMessageRequest create() => SendChatMessageRequest._();
  @$core.override
  SendChatMessageRequest createEmptyInstance() => create();
  static $pb.PbList<SendChatMessageRequest> createRepeated() => $pb.PbList<SendChatMessageRequest>();
  @$core.pragma('dart2js:noInline')
  static SendChatMessageRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendChatMessageRequest>(create);
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

  factory ChatMessageNotification.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ChatMessageNotification.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChatMessageNotification', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOM<ChatMessage>(1, _omitFieldNames ? '' : 'chatMessage', subBuilder: ChatMessage.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessageNotification clone() => ChatMessageNotification()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessageNotification copyWith(void Function(ChatMessageNotification) updates) => super.copyWith((message) => updates(message as ChatMessageNotification)) as ChatMessageNotification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatMessageNotification create() => ChatMessageNotification._();
  @$core.override
  ChatMessageNotification createEmptyInstance() => create();
  static $pb.PbList<ChatMessageNotification> createRepeated() => $pb.PbList<ChatMessageNotification>();
  @$core.pragma('dart2js:noInline')
  static ChatMessageNotification getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatMessageNotification>(create);
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

  factory UserLoginResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory UserLoginResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserLoginResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'clientId')
    ..aOB(2, _omitFieldNames ? '' : 'success')
    ..aOS(3, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserLoginResponse clone() => UserLoginResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserLoginResponse copyWith(void Function(UserLoginResponse) updates) => super.copyWith((message) => updates(message as UserLoginResponse)) as UserLoginResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserLoginResponse create() => UserLoginResponse._();
  @$core.override
  UserLoginResponse createEmptyInstance() => create();
  static $pb.PbList<UserLoginResponse> createRepeated() => $pb.PbList<UserLoginResponse>();
  @$core.pragma('dart2js:noInline')
  static UserLoginResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserLoginResponse>(create);
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

/// UserConnectionStatusNotification represents a notification when a user connects or disconnects
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

  factory UserConnectionStatusNotification.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory UserConnectionStatusNotification.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserConnectionStatusNotification', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOM<OnlineUser>(1, _omitFieldNames ? '' : 'user', subBuilder: OnlineUser.create)
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..aInt64(3, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserConnectionStatusNotification clone() => UserConnectionStatusNotification()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserConnectionStatusNotification copyWith(void Function(UserConnectionStatusNotification) updates) => super.copyWith((message) => updates(message as UserConnectionStatusNotification)) as UserConnectionStatusNotification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserConnectionStatusNotification create() => UserConnectionStatusNotification._();
  @$core.override
  UserConnectionStatusNotification createEmptyInstance() => create();
  static $pb.PbList<UserConnectionStatusNotification> createRepeated() => $pb.PbList<UserConnectionStatusNotification>();
  @$core.pragma('dart2js:noInline')
  static UserConnectionStatusNotification getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserConnectionStatusNotification>(create);
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
  }) {
    final result = create();
    if (cmd != null) result.cmd = cmd;
    if (askQuestionRequest != null) result.askQuestionRequest = askQuestionRequest;
    if (workReportRequest != null) result.workReportRequest = workReportRequest;
    if (askQuestionResponse != null) result.askQuestionResponse = askQuestionResponse;
    if (workReportResponse != null) result.workReportResponse = workReportResponse;
    if (strParam != null) result.strParam = strParam;
    if (checkMessageValidityRequest != null) result.checkMessageValidityRequest = checkMessageValidityRequest;
    if (checkMessageValidityResponse != null) result.checkMessageValidityResponse = checkMessageValidityResponse;
    if (getPendingMessagesRequest != null) result.getPendingMessagesRequest = getPendingMessagesRequest;
    if (getPendingMessagesResponse != null) result.getPendingMessagesResponse = getPendingMessagesResponse;
    if (requestCancelledNotification != null) result.requestCancelledNotification = requestCancelledNotification;
    if (nickname != null) result.nickname = nickname;
    if (getOnlineUsersRequest != null) result.getOnlineUsersRequest = getOnlineUsersRequest;
    if (getOnlineUsersResponse != null) result.getOnlineUsersResponse = getOnlineUsersResponse;
    if (sendChatMessageRequest != null) result.sendChatMessageRequest = sendChatMessageRequest;
    if (chatMessageNotification != null) result.chatMessageNotification = chatMessageNotification;
    if (userLoginResponse != null) result.userLoginResponse = userLoginResponse;
    if (userConnectionStatusNotification != null) result.userConnectionStatusNotification = userConnectionStatusNotification;
    return result;
  }

  WebsocketMessage._();

  factory WebsocketMessage.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory WebsocketMessage.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WebsocketMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'agentassistproto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'Cmd', protoName: 'Cmd')
    ..aOM<AskQuestionRequest>(2, _omitFieldNames ? '' : 'AskQuestionRequest', protoName: 'AskQuestionRequest', subBuilder: AskQuestionRequest.create)
    ..aOM<WorkReportRequest>(3, _omitFieldNames ? '' : 'WorkReportRequest', protoName: 'WorkReportRequest', subBuilder: WorkReportRequest.create)
    ..aOM<AskQuestionResponse>(4, _omitFieldNames ? '' : 'AskQuestionResponse', protoName: 'AskQuestionResponse', subBuilder: AskQuestionResponse.create)
    ..aOM<WorkReportResponse>(5, _omitFieldNames ? '' : 'WorkReportResponse', protoName: 'WorkReportResponse', subBuilder: WorkReportResponse.create)
    ..aOS(12, _omitFieldNames ? '' : 'StrParam', protoName: 'StrParam')
    ..aOM<CheckMessageValidityRequest>(13, _omitFieldNames ? '' : 'CheckMessageValidityRequest', protoName: 'CheckMessageValidityRequest', subBuilder: CheckMessageValidityRequest.create)
    ..aOM<CheckMessageValidityResponse>(14, _omitFieldNames ? '' : 'CheckMessageValidityResponse', protoName: 'CheckMessageValidityResponse', subBuilder: CheckMessageValidityResponse.create)
    ..aOM<GetPendingMessagesRequest>(15, _omitFieldNames ? '' : 'GetPendingMessagesRequest', protoName: 'GetPendingMessagesRequest', subBuilder: GetPendingMessagesRequest.create)
    ..aOM<GetPendingMessagesResponse>(16, _omitFieldNames ? '' : 'GetPendingMessagesResponse', protoName: 'GetPendingMessagesResponse', subBuilder: GetPendingMessagesResponse.create)
    ..aOM<RequestCancelledNotification>(17, _omitFieldNames ? '' : 'RequestCancelledNotification', protoName: 'RequestCancelledNotification', subBuilder: RequestCancelledNotification.create)
    ..aOS(18, _omitFieldNames ? '' : 'Nickname', protoName: 'Nickname')
    ..aOM<GetOnlineUsersRequest>(19, _omitFieldNames ? '' : 'GetOnlineUsersRequest', protoName: 'GetOnlineUsersRequest', subBuilder: GetOnlineUsersRequest.create)
    ..aOM<GetOnlineUsersResponse>(20, _omitFieldNames ? '' : 'GetOnlineUsersResponse', protoName: 'GetOnlineUsersResponse', subBuilder: GetOnlineUsersResponse.create)
    ..aOM<SendChatMessageRequest>(21, _omitFieldNames ? '' : 'SendChatMessageRequest', protoName: 'SendChatMessageRequest', subBuilder: SendChatMessageRequest.create)
    ..aOM<ChatMessageNotification>(22, _omitFieldNames ? '' : 'ChatMessageNotification', protoName: 'ChatMessageNotification', subBuilder: ChatMessageNotification.create)
    ..aOM<UserLoginResponse>(23, _omitFieldNames ? '' : 'UserLoginResponse', protoName: 'UserLoginResponse', subBuilder: UserLoginResponse.create)
    ..aOM<UserConnectionStatusNotification>(24, _omitFieldNames ? '' : 'UserConnectionStatusNotification', protoName: 'UserConnectionStatusNotification', subBuilder: UserConnectionStatusNotification.create)
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

  /// get pending messages request
  @$pb.TagNumber(15)
  GetPendingMessagesRequest get getPendingMessagesRequest => $_getN(8);
  @$pb.TagNumber(15)
  set getPendingMessagesRequest(GetPendingMessagesRequest value) => $_setField(15, value);
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
  set getPendingMessagesResponse(GetPendingMessagesResponse value) => $_setField(16, value);
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
  set requestCancelledNotification(RequestCancelledNotification value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasRequestCancelledNotification() => $_has(10);
  @$pb.TagNumber(17)
  void clearRequestCancelledNotification() => $_clearField(17);
  @$pb.TagNumber(17)
  RequestCancelledNotification ensureRequestCancelledNotification() => $_ensure(10);

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
  set getOnlineUsersRequest(GetOnlineUsersRequest value) => $_setField(19, value);
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
  set getOnlineUsersResponse(GetOnlineUsersResponse value) => $_setField(20, value);
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
  set sendChatMessageRequest(SendChatMessageRequest value) => $_setField(21, value);
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
  set chatMessageNotification(ChatMessageNotification value) => $_setField(22, value);
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
  UserConnectionStatusNotification get userConnectionStatusNotification => $_getN(17);
  @$pb.TagNumber(24)
  set userConnectionStatusNotification(UserConnectionStatusNotification value) => $_setField(24, value);
  @$pb.TagNumber(24)
  $core.bool hasUserConnectionStatusNotification() => $_has(17);
  @$pb.TagNumber(24)
  void clearUserConnectionStatusNotification() => $_clearField(24);
  @$pb.TagNumber(24)
  UserConnectionStatusNotification ensureUserConnectionStatusNotification() => $_ensure(17);
}

class SrvAgentAssistApi {
  final $pb.RpcClient _client;

  SrvAgentAssistApi(this._client);

  $async.Future<AskQuestionResponse> askQuestion($pb.ClientContext? ctx, AskQuestionRequest request) =>
    _client.invoke<AskQuestionResponse>(ctx, 'SrvAgentAssist', 'AskQuestion', request, AskQuestionResponse())
  ;
  $async.Future<WorkReportResponse> workReport($pb.ClientContext? ctx, WorkReportRequest request) =>
    _client.invoke<WorkReportResponse>(ctx, 'SrvAgentAssist', 'WorkReport', request, WorkReportResponse())
  ;
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
