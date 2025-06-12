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

@$core.Deprecated('Use getPendingMessagesRequestDescriptor instead')
const GetPendingMessagesRequest$json = {
  '1': 'GetPendingMessagesRequest',
  '2': [
    {'1': 'user_token', '3': 1, '4': 1, '5': 9, '10': 'userToken'},
  ],
};

/// Descriptor for `GetPendingMessagesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPendingMessagesRequestDescriptor = $convert.base64Decode(
    'ChlHZXRQZW5kaW5nTWVzc2FnZXNSZXF1ZXN0Eh0KCnVzZXJfdG9rZW4YASABKAlSCXVzZXJUb2'
    'tlbg==');

@$core.Deprecated('Use pendingMessageDescriptor instead')
const PendingMessage$json = {
  '1': 'PendingMessage',
  '2': [
    {'1': 'message_type', '3': 1, '4': 1, '5': 9, '10': 'messageType'},
    {'1': 'ask_question_request', '3': 2, '4': 1, '5': 11, '6': '.agentassistproto.AskQuestionRequest', '10': 'askQuestionRequest'},
    {'1': 'task_finish_request', '3': 3, '4': 1, '5': 11, '6': '.agentassistproto.TaskFinishRequest', '10': 'taskFinishRequest'},
    {'1': 'created_at', '3': 4, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'timeout', '3': 5, '4': 1, '5': 5, '10': 'timeout'},
  ],
};

/// Descriptor for `PendingMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pendingMessageDescriptor = $convert.base64Decode(
    'Cg5QZW5kaW5nTWVzc2FnZRIhCgxtZXNzYWdlX3R5cGUYASABKAlSC21lc3NhZ2VUeXBlElYKFG'
    'Fza19xdWVzdGlvbl9yZXF1ZXN0GAIgASgLMiQuYWdlbnRhc3Npc3Rwcm90by5Bc2tRdWVzdGlv'
    'blJlcXVlc3RSEmFza1F1ZXN0aW9uUmVxdWVzdBJTChN0YXNrX2ZpbmlzaF9yZXF1ZXN0GAMgAS'
    'gLMiMuYWdlbnRhc3Npc3Rwcm90by5UYXNrRmluaXNoUmVxdWVzdFIRdGFza0ZpbmlzaFJlcXVl'
    'c3QSHQoKY3JlYXRlZF9hdBgEIAEoA1IJY3JlYXRlZEF0EhgKB3RpbWVvdXQYBSABKAVSB3RpbW'
    'VvdXQ=');

@$core.Deprecated('Use getPendingMessagesResponseDescriptor instead')
const GetPendingMessagesResponse$json = {
  '1': 'GetPendingMessagesResponse',
  '2': [
    {'1': 'pending_messages', '3': 1, '4': 3, '5': 11, '6': '.agentassistproto.PendingMessage', '10': 'pendingMessages'},
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `GetPendingMessagesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPendingMessagesResponseDescriptor = $convert.base64Decode(
    'ChpHZXRQZW5kaW5nTWVzc2FnZXNSZXNwb25zZRJLChBwZW5kaW5nX21lc3NhZ2VzGAEgAygLMi'
    'AuYWdlbnRhc3Npc3Rwcm90by5QZW5kaW5nTWVzc2FnZVIPcGVuZGluZ01lc3NhZ2VzEh8KC3Rv'
    'dGFsX2NvdW50GAIgASgFUgp0b3RhbENvdW50');

@$core.Deprecated('Use requestCancelledNotificationDescriptor instead')
const RequestCancelledNotification$json = {
  '1': 'RequestCancelledNotification',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
    {'1': 'message_type', '3': 3, '4': 1, '5': 9, '10': 'messageType'},
  ],
};

/// Descriptor for `RequestCancelledNotification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestCancelledNotificationDescriptor = $convert.base64Decode(
    'ChxSZXF1ZXN0Q2FuY2VsbGVkTm90aWZpY2F0aW9uEh0KCnJlcXVlc3RfaWQYASABKAlSCXJlcX'
    'Vlc3RJZBIWCgZyZWFzb24YAiABKAlSBnJlYXNvbhIhCgxtZXNzYWdlX3R5cGUYAyABKAlSC21l'
    'c3NhZ2VUeXBl');

@$core.Deprecated('Use onlineUserDescriptor instead')
const OnlineUser$json = {
  '1': 'OnlineUser',
  '2': [
    {'1': 'client_id', '3': 1, '4': 1, '5': 9, '10': 'clientId'},
    {'1': 'nickname', '3': 2, '4': 1, '5': 9, '10': 'nickname'},
    {'1': 'connected_at', '3': 3, '4': 1, '5': 3, '10': 'connectedAt'},
  ],
};

/// Descriptor for `OnlineUser`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List onlineUserDescriptor = $convert.base64Decode(
    'CgpPbmxpbmVVc2VyEhsKCWNsaWVudF9pZBgBIAEoCVIIY2xpZW50SWQSGgoIbmlja25hbWUYAi'
    'ABKAlSCG5pY2tuYW1lEiEKDGNvbm5lY3RlZF9hdBgDIAEoA1ILY29ubmVjdGVkQXQ=');

@$core.Deprecated('Use getOnlineUsersRequestDescriptor instead')
const GetOnlineUsersRequest$json = {
  '1': 'GetOnlineUsersRequest',
  '2': [
    {'1': 'user_token', '3': 1, '4': 1, '5': 9, '10': 'userToken'},
  ],
};

/// Descriptor for `GetOnlineUsersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getOnlineUsersRequestDescriptor = $convert.base64Decode(
    'ChVHZXRPbmxpbmVVc2Vyc1JlcXVlc3QSHQoKdXNlcl90b2tlbhgBIAEoCVIJdXNlclRva2Vu');

@$core.Deprecated('Use getOnlineUsersResponseDescriptor instead')
const GetOnlineUsersResponse$json = {
  '1': 'GetOnlineUsersResponse',
  '2': [
    {'1': 'online_users', '3': 1, '4': 3, '5': 11, '6': '.agentassistproto.OnlineUser', '10': 'onlineUsers'},
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `GetOnlineUsersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getOnlineUsersResponseDescriptor = $convert.base64Decode(
    'ChZHZXRPbmxpbmVVc2Vyc1Jlc3BvbnNlEj8KDG9ubGluZV91c2VycxgBIAMoCzIcLmFnZW50YX'
    'NzaXN0cHJvdG8uT25saW5lVXNlclILb25saW5lVXNlcnMSHwoLdG90YWxfY291bnQYAiABKAVS'
    'CnRvdGFsQ291bnQ=');

@$core.Deprecated('Use chatMessageDescriptor instead')
const ChatMessage$json = {
  '1': 'ChatMessage',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'sender_client_id', '3': 2, '4': 1, '5': 9, '10': 'senderClientId'},
    {'1': 'sender_nickname', '3': 3, '4': 1, '5': 9, '10': 'senderNickname'},
    {'1': 'receiver_client_id', '3': 4, '4': 1, '5': 9, '10': 'receiverClientId'},
    {'1': 'receiver_nickname', '3': 5, '4': 1, '5': 9, '10': 'receiverNickname'},
    {'1': 'content', '3': 6, '4': 1, '5': 9, '10': 'content'},
    {'1': 'sent_at', '3': 7, '4': 1, '5': 3, '10': 'sentAt'},
  ],
};

/// Descriptor for `ChatMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatMessageDescriptor = $convert.base64Decode(
    'CgtDaGF0TWVzc2FnZRIdCgptZXNzYWdlX2lkGAEgASgJUgltZXNzYWdlSWQSKAoQc2VuZGVyX2'
    'NsaWVudF9pZBgCIAEoCVIOc2VuZGVyQ2xpZW50SWQSJwoPc2VuZGVyX25pY2tuYW1lGAMgASgJ'
    'Ug5zZW5kZXJOaWNrbmFtZRIsChJyZWNlaXZlcl9jbGllbnRfaWQYBCABKAlSEHJlY2VpdmVyQ2'
    'xpZW50SWQSKwoRcmVjZWl2ZXJfbmlja25hbWUYBSABKAlSEHJlY2VpdmVyTmlja25hbWUSGAoH'
    'Y29udGVudBgGIAEoCVIHY29udGVudBIXCgdzZW50X2F0GAcgASgDUgZzZW50QXQ=');

@$core.Deprecated('Use sendChatMessageRequestDescriptor instead')
const SendChatMessageRequest$json = {
  '1': 'SendChatMessageRequest',
  '2': [
    {'1': 'receiver_client_id', '3': 1, '4': 1, '5': 9, '10': 'receiverClientId'},
    {'1': 'content', '3': 2, '4': 1, '5': 9, '10': 'content'},
  ],
};

/// Descriptor for `SendChatMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendChatMessageRequestDescriptor = $convert.base64Decode(
    'ChZTZW5kQ2hhdE1lc3NhZ2VSZXF1ZXN0EiwKEnJlY2VpdmVyX2NsaWVudF9pZBgBIAEoCVIQcm'
    'VjZWl2ZXJDbGllbnRJZBIYCgdjb250ZW50GAIgASgJUgdjb250ZW50');

@$core.Deprecated('Use chatMessageNotificationDescriptor instead')
const ChatMessageNotification$json = {
  '1': 'ChatMessageNotification',
  '2': [
    {'1': 'chat_message', '3': 1, '4': 1, '5': 11, '6': '.agentassistproto.ChatMessage', '10': 'chatMessage'},
  ],
};

/// Descriptor for `ChatMessageNotification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatMessageNotificationDescriptor = $convert.base64Decode(
    'ChdDaGF0TWVzc2FnZU5vdGlmaWNhdGlvbhJACgxjaGF0X21lc3NhZ2UYASABKAsyHS5hZ2VudG'
    'Fzc2lzdHByb3RvLkNoYXRNZXNzYWdlUgtjaGF0TWVzc2FnZQ==');

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
    {'1': 'GetPendingMessagesRequest', '3': 15, '4': 1, '5': 11, '6': '.agentassistproto.GetPendingMessagesRequest', '10': 'GetPendingMessagesRequest'},
    {'1': 'GetPendingMessagesResponse', '3': 16, '4': 1, '5': 11, '6': '.agentassistproto.GetPendingMessagesResponse', '10': 'GetPendingMessagesResponse'},
    {'1': 'RequestCancelledNotification', '3': 17, '4': 1, '5': 11, '6': '.agentassistproto.RequestCancelledNotification', '10': 'RequestCancelledNotification'},
    {'1': 'GetOnlineUsersRequest', '3': 19, '4': 1, '5': 11, '6': '.agentassistproto.GetOnlineUsersRequest', '10': 'GetOnlineUsersRequest'},
    {'1': 'GetOnlineUsersResponse', '3': 20, '4': 1, '5': 11, '6': '.agentassistproto.GetOnlineUsersResponse', '10': 'GetOnlineUsersResponse'},
    {'1': 'SendChatMessageRequest', '3': 21, '4': 1, '5': 11, '6': '.agentassistproto.SendChatMessageRequest', '10': 'SendChatMessageRequest'},
    {'1': 'ChatMessageNotification', '3': 22, '4': 1, '5': 11, '6': '.agentassistproto.ChatMessageNotification', '10': 'ChatMessageNotification'},
    {'1': 'StrParam', '3': 12, '4': 1, '5': 9, '10': 'StrParam'},
    {'1': 'Nickname', '3': 18, '4': 1, '5': 9, '10': 'Nickname'},
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
    'a01lc3NhZ2VWYWxpZGl0eVJlc3BvbnNlUhxDaGVja01lc3NhZ2VWYWxpZGl0eVJlc3BvbnNlEm'
    'kKGUdldFBlbmRpbmdNZXNzYWdlc1JlcXVlc3QYDyABKAsyKy5hZ2VudGFzc2lzdHByb3RvLkdl'
    'dFBlbmRpbmdNZXNzYWdlc1JlcXVlc3RSGUdldFBlbmRpbmdNZXNzYWdlc1JlcXVlc3QSbAoaR2'
    'V0UGVuZGluZ01lc3NhZ2VzUmVzcG9uc2UYECABKAsyLC5hZ2VudGFzc2lzdHByb3RvLkdldFBl'
    'bmRpbmdNZXNzYWdlc1Jlc3BvbnNlUhpHZXRQZW5kaW5nTWVzc2FnZXNSZXNwb25zZRJyChxSZX'
    'F1ZXN0Q2FuY2VsbGVkTm90aWZpY2F0aW9uGBEgASgLMi4uYWdlbnRhc3Npc3Rwcm90by5SZXF1'
    'ZXN0Q2FuY2VsbGVkTm90aWZpY2F0aW9uUhxSZXF1ZXN0Q2FuY2VsbGVkTm90aWZpY2F0aW9uEl'
    '0KFUdldE9ubGluZVVzZXJzUmVxdWVzdBgTIAEoCzInLmFnZW50YXNzaXN0cHJvdG8uR2V0T25s'
    'aW5lVXNlcnNSZXF1ZXN0UhVHZXRPbmxpbmVVc2Vyc1JlcXVlc3QSYAoWR2V0T25saW5lVXNlcn'
    'NSZXNwb25zZRgUIAEoCzIoLmFnZW50YXNzaXN0cHJvdG8uR2V0T25saW5lVXNlcnNSZXNwb25z'
    'ZVIWR2V0T25saW5lVXNlcnNSZXNwb25zZRJgChZTZW5kQ2hhdE1lc3NhZ2VSZXF1ZXN0GBUgAS'
    'gLMiguYWdlbnRhc3Npc3Rwcm90by5TZW5kQ2hhdE1lc3NhZ2VSZXF1ZXN0UhZTZW5kQ2hhdE1l'
    'c3NhZ2VSZXF1ZXN0EmMKF0NoYXRNZXNzYWdlTm90aWZpY2F0aW9uGBYgASgLMikuYWdlbnRhc3'
    'Npc3Rwcm90by5DaGF0TWVzc2FnZU5vdGlmaWNhdGlvblIXQ2hhdE1lc3NhZ2VOb3RpZmljYXRp'
    'b24SGgoIU3RyUGFyYW0YDCABKAlSCFN0clBhcmFtEhoKCE5pY2tuYW1lGBIgASgJUghOaWNrbm'
    'FtZQ==');

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

