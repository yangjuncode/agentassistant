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

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use textContentDescriptor instead')
const TextContent$json = {
  '1': 'TextContent',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    {'1': 'text', '3': 2, '4': 1, '5': 9, '10': 'text'},
  ],
};

/// Descriptor for `TextContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List textContentDescriptor = $convert.base64Decode(
    'CgtUZXh0Q29udGVudBISCgR0eXBlGAEgASgJUgR0eXBlEhIKBHRleHQYAiABKAlSBHRleHQ=');

@$core.Deprecated('Use imageContentDescriptor instead')
const ImageContent$json = {
  '1': 'ImageContent',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    {'1': 'data', '3': 2, '4': 1, '5': 9, '10': 'data'},
    {'1': 'mime_type', '3': 3, '4': 1, '5': 9, '10': 'mimeType'},
  ],
};

/// Descriptor for `ImageContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imageContentDescriptor = $convert.base64Decode(
    'CgxJbWFnZUNvbnRlbnQSEgoEdHlwZRgBIAEoCVIEdHlwZRISCgRkYXRhGAIgASgJUgRkYXRhEh'
    'sKCW1pbWVfdHlwZRgDIAEoCVIIbWltZVR5cGU=');

@$core.Deprecated('Use audioContentDescriptor instead')
const AudioContent$json = {
  '1': 'AudioContent',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    {'1': 'data', '3': 2, '4': 1, '5': 9, '10': 'data'},
    {'1': 'mime_type', '3': 3, '4': 1, '5': 9, '10': 'mimeType'},
  ],
};

/// Descriptor for `AudioContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List audioContentDescriptor = $convert.base64Decode(
    'CgxBdWRpb0NvbnRlbnQSEgoEdHlwZRgBIAEoCVIEdHlwZRISCgRkYXRhGAIgASgJUgRkYXRhEh'
    'sKCW1pbWVfdHlwZRgDIAEoCVIIbWltZVR5cGU=');

@$core.Deprecated('Use embeddedResourceDescriptor instead')
const EmbeddedResource$json = {
  '1': 'EmbeddedResource',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    {'1': 'uri', '3': 2, '4': 1, '5': 9, '10': 'uri'},
    {'1': 'mime_type', '3': 3, '4': 1, '5': 9, '10': 'mimeType'},
    {'1': 'data', '3': 4, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `EmbeddedResource`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List embeddedResourceDescriptor = $convert.base64Decode(
    'ChBFbWJlZGRlZFJlc291cmNlEhIKBHR5cGUYASABKAlSBHR5cGUSEAoDdXJpGAIgASgJUgN1cm'
    'kSGwoJbWltZV90eXBlGAMgASgJUghtaW1lVHlwZRISCgRkYXRhGAQgASgMUgRkYXRh');

@$core.Deprecated('Use mcpResultContentDescriptor instead')
const McpResultContent$json = {
  '1': 'McpResultContent',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'text', '3': 2, '4': 1, '5': 11, '6': '.agentassistproto.TextContent', '10': 'text'},
    {'1': 'image', '3': 3, '4': 1, '5': 11, '6': '.agentassistproto.ImageContent', '10': 'image'},
    {'1': 'audio', '3': 4, '4': 1, '5': 11, '6': '.agentassistproto.AudioContent', '10': 'audio'},
    {'1': 'embedded_resource', '3': 5, '4': 1, '5': 11, '6': '.agentassistproto.EmbeddedResource', '10': 'embeddedResource'},
  ],
};

/// Descriptor for `McpResultContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mcpResultContentDescriptor = $convert.base64Decode(
    'ChBNY3BSZXN1bHRDb250ZW50EhIKBHR5cGUYASABKAVSBHR5cGUSMQoEdGV4dBgCIAEoCzIdLm'
    'FnZW50YXNzaXN0cHJvdG8uVGV4dENvbnRlbnRSBHRleHQSNAoFaW1hZ2UYAyABKAsyHi5hZ2Vu'
    'dGFzc2lzdHByb3RvLkltYWdlQ29udGVudFIFaW1hZ2USNAoFYXVkaW8YBCABKAsyHi5hZ2VudG'
    'Fzc2lzdHByb3RvLkF1ZGlvQ29udGVudFIFYXVkaW8STwoRZW1iZWRkZWRfcmVzb3VyY2UYBSAB'
    'KAsyIi5hZ2VudGFzc2lzdHByb3RvLkVtYmVkZGVkUmVzb3VyY2VSEGVtYmVkZGVkUmVzb3VyY2'
    'U=');

@$core.Deprecated('Use msgEmptyDescriptor instead')
const MsgEmpty$json = {
  '1': 'MsgEmpty',
};

/// Descriptor for `MsgEmpty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgEmptyDescriptor = $convert.base64Decode(
    'CghNc2dFbXB0eQ==');

@$core.Deprecated('Use mcpAskQuestionRequestDescriptor instead')
const McpAskQuestionRequest$json = {
  '1': 'McpAskQuestionRequest',
  '2': [
    {'1': 'ProjectDirectory', '3': 1, '4': 1, '5': 9, '10': 'ProjectDirectory'},
    {'1': 'Question', '3': 2, '4': 1, '5': 9, '10': 'Question'},
    {'1': 'Timeout', '3': 3, '4': 1, '5': 5, '10': 'Timeout'},
  ],
};

/// Descriptor for `McpAskQuestionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mcpAskQuestionRequestDescriptor = $convert.base64Decode(
    'ChVNY3BBc2tRdWVzdGlvblJlcXVlc3QSKgoQUHJvamVjdERpcmVjdG9yeRgBIAEoCVIQUHJvam'
    'VjdERpcmVjdG9yeRIaCghRdWVzdGlvbhgCIAEoCVIIUXVlc3Rpb24SGAoHVGltZW91dBgDIAEo'
    'BVIHVGltZW91dA==');

@$core.Deprecated('Use askQuestionRequestDescriptor instead')
const AskQuestionRequest$json = {
  '1': 'AskQuestionRequest',
  '2': [
    {'1': 'ID', '3': 1, '4': 1, '5': 9, '10': 'ID'},
    {'1': 'UserToken', '3': 2, '4': 1, '5': 9, '10': 'UserToken'},
    {'1': 'Request', '3': 3, '4': 1, '5': 11, '6': '.agentassistproto.McpAskQuestionRequest', '10': 'Request'},
  ],
};

/// Descriptor for `AskQuestionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List askQuestionRequestDescriptor = $convert.base64Decode(
    'ChJBc2tRdWVzdGlvblJlcXVlc3QSDgoCSUQYASABKAlSAklEEhwKCVVzZXJUb2tlbhgCIAEoCV'
    'IJVXNlclRva2VuEkEKB1JlcXVlc3QYAyABKAsyJy5hZ2VudGFzc2lzdHByb3RvLk1jcEFza1F1'
    'ZXN0aW9uUmVxdWVzdFIHUmVxdWVzdA==');

@$core.Deprecated('Use askQuestionResponseDescriptor instead')
const AskQuestionResponse$json = {
  '1': 'AskQuestionResponse',
  '2': [
    {'1': 'ID', '3': 1, '4': 1, '5': 9, '10': 'ID'},
    {'1': 'IsError', '3': 2, '4': 1, '5': 8, '10': 'IsError'},
    {'1': 'Meta', '3': 3, '4': 3, '5': 11, '6': '.agentassistproto.AskQuestionResponse.MetaEntry', '10': 'Meta'},
    {'1': 'contents', '3': 4, '4': 3, '5': 11, '6': '.agentassistproto.McpResultContent', '10': 'contents'},
  ],
  '3': [AskQuestionResponse_MetaEntry$json],
};

@$core.Deprecated('Use askQuestionResponseDescriptor instead')
const AskQuestionResponse_MetaEntry$json = {
  '1': 'MetaEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `AskQuestionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List askQuestionResponseDescriptor = $convert.base64Decode(
    'ChNBc2tRdWVzdGlvblJlc3BvbnNlEg4KAklEGAEgASgJUgJJRBIYCgdJc0Vycm9yGAIgASgIUg'
    'dJc0Vycm9yEkMKBE1ldGEYAyADKAsyLy5hZ2VudGFzc2lzdHByb3RvLkFza1F1ZXN0aW9uUmVz'
    'cG9uc2UuTWV0YUVudHJ5UgRNZXRhEj4KCGNvbnRlbnRzGAQgAygLMiIuYWdlbnRhc3Npc3Rwcm'
    '90by5NY3BSZXN1bHRDb250ZW50Ughjb250ZW50cxo3CglNZXRhRW50cnkSEAoDa2V5GAEgASgJ'
    'UgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use mcpTaskFinishRequestDescriptor instead')
const McpTaskFinishRequest$json = {
  '1': 'McpTaskFinishRequest',
  '2': [
    {'1': 'ProjectDirectory', '3': 1, '4': 1, '5': 9, '10': 'ProjectDirectory'},
    {'1': 'Summary', '3': 2, '4': 1, '5': 9, '10': 'Summary'},
    {'1': 'Timeout', '3': 3, '4': 1, '5': 5, '10': 'Timeout'},
  ],
};

/// Descriptor for `McpTaskFinishRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mcpTaskFinishRequestDescriptor = $convert.base64Decode(
    'ChRNY3BUYXNrRmluaXNoUmVxdWVzdBIqChBQcm9qZWN0RGlyZWN0b3J5GAEgASgJUhBQcm9qZW'
    'N0RGlyZWN0b3J5EhgKB1N1bW1hcnkYAiABKAlSB1N1bW1hcnkSGAoHVGltZW91dBgDIAEoBVIH'
    'VGltZW91dA==');

@$core.Deprecated('Use taskFinishRequestDescriptor instead')
const TaskFinishRequest$json = {
  '1': 'TaskFinishRequest',
  '2': [
    {'1': 'ID', '3': 1, '4': 1, '5': 9, '10': 'ID'},
    {'1': 'UserToken', '3': 2, '4': 1, '5': 9, '10': 'UserToken'},
    {'1': 'Request', '3': 3, '4': 1, '5': 11, '6': '.agentassistproto.McpTaskFinishRequest', '10': 'Request'},
  ],
};

/// Descriptor for `TaskFinishRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskFinishRequestDescriptor = $convert.base64Decode(
    'ChFUYXNrRmluaXNoUmVxdWVzdBIOCgJJRBgBIAEoCVICSUQSHAoJVXNlclRva2VuGAIgASgJUg'
    'lVc2VyVG9rZW4SQAoHUmVxdWVzdBgDIAEoCzImLmFnZW50YXNzaXN0cHJvdG8uTWNwVGFza0Zp'
    'bmlzaFJlcXVlc3RSB1JlcXVlc3Q=');

@$core.Deprecated('Use taskFinishResponseDescriptor instead')
const TaskFinishResponse$json = {
  '1': 'TaskFinishResponse',
  '2': [
    {'1': 'ID', '3': 1, '4': 1, '5': 9, '10': 'ID'},
    {'1': 'IsError', '3': 2, '4': 1, '5': 8, '10': 'IsError'},
    {'1': 'Meta', '3': 3, '4': 3, '5': 11, '6': '.agentassistproto.TaskFinishResponse.MetaEntry', '10': 'Meta'},
    {'1': 'contents', '3': 4, '4': 3, '5': 11, '6': '.agentassistproto.McpResultContent', '10': 'contents'},
  ],
  '3': [TaskFinishResponse_MetaEntry$json],
};

@$core.Deprecated('Use taskFinishResponseDescriptor instead')
const TaskFinishResponse_MetaEntry$json = {
  '1': 'MetaEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `TaskFinishResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskFinishResponseDescriptor = $convert.base64Decode(
    'ChJUYXNrRmluaXNoUmVzcG9uc2USDgoCSUQYASABKAlSAklEEhgKB0lzRXJyb3IYAiABKAhSB0'
    'lzRXJyb3ISQgoETWV0YRgDIAMoCzIuLmFnZW50YXNzaXN0cHJvdG8uVGFza0ZpbmlzaFJlc3Bv'
    'bnNlLk1ldGFFbnRyeVIETWV0YRI+Cghjb250ZW50cxgEIAMoCzIiLmFnZW50YXNzaXN0cHJvdG'
    '8uTWNwUmVzdWx0Q29udGVudFIIY29udGVudHMaNwoJTWV0YUVudHJ5EhAKA2tleRgBIAEoCVID'
    'a2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use checkMessageValidityRequestDescriptor instead')
const CheckMessageValidityRequest$json = {
  '1': 'CheckMessageValidityRequest',
  '2': [
    {'1': 'request_ids', '3': 1, '4': 3, '5': 9, '10': 'requestIds'},
  ],
};

/// Descriptor for `CheckMessageValidityRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkMessageValidityRequestDescriptor = $convert.base64Decode(
    'ChtDaGVja01lc3NhZ2VWYWxpZGl0eVJlcXVlc3QSHwoLcmVxdWVzdF9pZHMYASADKAlSCnJlcX'
    'Vlc3RJZHM=');

@$core.Deprecated('Use checkMessageValidityResponseDescriptor instead')
const CheckMessageValidityResponse$json = {
  '1': 'CheckMessageValidityResponse',
  '2': [
    {'1': 'validity', '3': 1, '4': 3, '5': 11, '6': '.agentassistproto.CheckMessageValidityResponse.ValidityEntry', '10': 'validity'},
  ],
  '3': [CheckMessageValidityResponse_ValidityEntry$json],
};

@$core.Deprecated('Use checkMessageValidityResponseDescriptor instead')
const CheckMessageValidityResponse_ValidityEntry$json = {
  '1': 'ValidityEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 8, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `CheckMessageValidityResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkMessageValidityResponseDescriptor = $convert.base64Decode(
    'ChxDaGVja01lc3NhZ2VWYWxpZGl0eVJlc3BvbnNlElgKCHZhbGlkaXR5GAEgAygLMjwuYWdlbn'
    'Rhc3Npc3Rwcm90by5DaGVja01lc3NhZ2VWYWxpZGl0eVJlc3BvbnNlLlZhbGlkaXR5RW50cnlS'
    'CHZhbGlkaXR5GjsKDVZhbGlkaXR5RW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAi'
    'ABKAhSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use websocketMessageDescriptor instead')
const WebsocketMessage$json = {
  '1': 'WebsocketMessage',
  '2': [
    {'1': 'Cmd', '3': 1, '4': 1, '5': 9, '10': 'Cmd'},
    {'1': 'AskQuestionRequest', '3': 2, '4': 1, '5': 11, '6': '.agentassistproto.AskQuestionRequest', '10': 'AskQuestionRequest'},
    {'1': 'TaskFinishRequest', '3': 3, '4': 1, '5': 11, '6': '.agentassistproto.TaskFinishRequest', '10': 'TaskFinishRequest'},
    {'1': 'AskQuestionResponse', '3': 4, '4': 1, '5': 11, '6': '.agentassistproto.AskQuestionResponse', '10': 'AskQuestionResponse'},
    {'1': 'TaskFinishResponse', '3': 5, '4': 1, '5': 11, '6': '.agentassistproto.TaskFinishResponse', '10': 'TaskFinishResponse'},
    {'1': 'CheckMessageValidityRequest', '3': 13, '4': 1, '5': 11, '6': '.agentassistproto.CheckMessageValidityRequest', '10': 'CheckMessageValidityRequest'},
    {'1': 'CheckMessageValidityResponse', '3': 14, '4': 1, '5': 11, '6': '.agentassistproto.CheckMessageValidityResponse', '10': 'CheckMessageValidityResponse'},
    {'1': 'StrParam', '3': 12, '4': 1, '5': 9, '10': 'StrParam'},
  ],
};

/// Descriptor for `WebsocketMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List websocketMessageDescriptor = $convert.base64Decode(
    'ChBXZWJzb2NrZXRNZXNzYWdlEhAKA0NtZBgBIAEoCVIDQ21kElQKEkFza1F1ZXN0aW9uUmVxdW'
    'VzdBgCIAEoCzIkLmFnZW50YXNzaXN0cHJvdG8uQXNrUXVlc3Rpb25SZXF1ZXN0UhJBc2tRdWVz'
    'dGlvblJlcXVlc3QSUQoRVGFza0ZpbmlzaFJlcXVlc3QYAyABKAsyIy5hZ2VudGFzc2lzdHByb3'
    'RvLlRhc2tGaW5pc2hSZXF1ZXN0UhFUYXNrRmluaXNoUmVxdWVzdBJXChNBc2tRdWVzdGlvblJl'
    'c3BvbnNlGAQgASgLMiUuYWdlbnRhc3Npc3Rwcm90by5Bc2tRdWVzdGlvblJlc3BvbnNlUhNBc2'
    'tRdWVzdGlvblJlc3BvbnNlElQKElRhc2tGaW5pc2hSZXNwb25zZRgFIAEoCzIkLmFnZW50YXNz'
    'aXN0cHJvdG8uVGFza0ZpbmlzaFJlc3BvbnNlUhJUYXNrRmluaXNoUmVzcG9uc2USbwobQ2hlY2'
    'tNZXNzYWdlVmFsaWRpdHlSZXF1ZXN0GA0gASgLMi0uYWdlbnRhc3Npc3Rwcm90by5DaGVja01l'
    'c3NhZ2VWYWxpZGl0eVJlcXVlc3RSG0NoZWNrTWVzc2FnZVZhbGlkaXR5UmVxdWVzdBJyChxDaG'
    'Vja01lc3NhZ2VWYWxpZGl0eVJlc3BvbnNlGA4gASgLMi4uYWdlbnRhc3Npc3Rwcm90by5DaGVj'
    'a01lc3NhZ2VWYWxpZGl0eVJlc3BvbnNlUhxDaGVja01lc3NhZ2VWYWxpZGl0eVJlc3BvbnNlEh'
    'oKCFN0clBhcmFtGAwgASgJUghTdHJQYXJhbQ==');

const $core.Map<$core.String, $core.dynamic> SrvAgentAssistServiceBase$json = {
  '1': 'SrvAgentAssist',
  '2': [
    {'1': 'AskQuestion', '2': '.agentassistproto.AskQuestionRequest', '3': '.agentassistproto.AskQuestionResponse'},
    {'1': 'TaskFinish', '2': '.agentassistproto.TaskFinishRequest', '3': '.agentassistproto.TaskFinishResponse'},
  ],
};

@$core.Deprecated('Use srvAgentAssistServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> SrvAgentAssistServiceBase$messageJson = {
  '.agentassistproto.AskQuestionRequest': AskQuestionRequest$json,
  '.agentassistproto.McpAskQuestionRequest': McpAskQuestionRequest$json,
  '.agentassistproto.AskQuestionResponse': AskQuestionResponse$json,
  '.agentassistproto.AskQuestionResponse.MetaEntry': AskQuestionResponse_MetaEntry$json,
  '.agentassistproto.McpResultContent': McpResultContent$json,
  '.agentassistproto.TextContent': TextContent$json,
  '.agentassistproto.ImageContent': ImageContent$json,
  '.agentassistproto.AudioContent': AudioContent$json,
  '.agentassistproto.EmbeddedResource': EmbeddedResource$json,
  '.agentassistproto.TaskFinishRequest': TaskFinishRequest$json,
  '.agentassistproto.McpTaskFinishRequest': McpTaskFinishRequest$json,
  '.agentassistproto.TaskFinishResponse': TaskFinishResponse$json,
  '.agentassistproto.TaskFinishResponse.MetaEntry': TaskFinishResponse_MetaEntry$json,
};

/// Descriptor for `SrvAgentAssist`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List srvAgentAssistServiceDescriptor = $convert.base64Decode(
    'Cg5TcnZBZ2VudEFzc2lzdBJaCgtBc2tRdWVzdGlvbhIkLmFnZW50YXNzaXN0cHJvdG8uQXNrUX'
    'Vlc3Rpb25SZXF1ZXN0GiUuYWdlbnRhc3Npc3Rwcm90by5Bc2tRdWVzdGlvblJlc3BvbnNlElcK'
    'ClRhc2tGaW5pc2gSIy5hZ2VudGFzc2lzdHByb3RvLlRhc2tGaW5pc2hSZXF1ZXN0GiQuYWdlbn'
    'Rhc3Npc3Rwcm90by5UYXNrRmluaXNoUmVzcG9uc2U=');

