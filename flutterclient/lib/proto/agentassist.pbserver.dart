//
//  Generated code. Do not modify.
//  source: agentassist.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'agentassist.pb.dart' as $0;
import 'agentassist.pbjson.dart';

export 'agentassist.pb.dart';

abstract class SrvAgentAssistServiceBase extends $pb.GeneratedService {
  $async.Future<$0.AskQuestionResponse> askQuestion($pb.ServerContext ctx, $0.AskQuestionRequest request);
  $async.Future<$0.WorkReportResponse> workReport($pb.ServerContext ctx, $0.WorkReportRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'AskQuestion': return $0.AskQuestionRequest();
      case 'WorkReport': return $0.WorkReportRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'AskQuestion': return this.askQuestion(ctx, request as $0.AskQuestionRequest);
      case 'WorkReport': return this.workReport(ctx, request as $0.WorkReportRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => SrvAgentAssistServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => SrvAgentAssistServiceBase$messageJson;
}

