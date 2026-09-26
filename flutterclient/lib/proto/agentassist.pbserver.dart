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

import 'package:protobuf/protobuf.dart' as $pb;

import 'agentassist.pb.dart' as $0;
import 'agentassist.pbjson.dart';

export 'agentassist.pb.dart';

abstract class SrvAgentAssistServiceBase extends $pb.GeneratedService {
  $async.Future<$0.AskQuestionResponse> askQuestion(
      $pb.ServerContext ctx, $0.AskQuestionRequest request);
  $async.Future<$0.WorkReportResponse> workReport(
      $pb.ServerContext ctx, $0.WorkReportRequest request);
  $async.Future<$0.McpClientInfoResponse> sendMcpClientInfo(
      $pb.ServerContext ctx, $0.McpClientInfoRequest request);
  $async.Future<$0.McpHeartbeatResponse> heartbeat(
      $pb.ServerContext ctx, $0.McpHeartbeatRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'AskQuestion':
        return $0.AskQuestionRequest();
      case 'WorkReport':
        return $0.WorkReportRequest();
      case 'SendMcpClientInfo':
        return $0.McpClientInfoRequest();
      case 'Heartbeat':
        return $0.McpHeartbeatRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'AskQuestion':
        return askQuestion(ctx, request as $0.AskQuestionRequest);
      case 'WorkReport':
        return workReport(ctx, request as $0.WorkReportRequest);
      case 'SendMcpClientInfo':
        return sendMcpClientInfo(ctx, request as $0.McpClientInfoRequest);
      case 'Heartbeat':
        return heartbeat(ctx, request as $0.McpHeartbeatRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      SrvAgentAssistServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => SrvAgentAssistServiceBase$messageJson;
}
