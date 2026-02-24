//
//  Generated code. Do not modify.
//  source: agentassist.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ForwardTarget_Mode extends $pb.ProtobufEnum {
  static const ForwardTarget_Mode MODE_UNSPECIFIED = ForwardTarget_Mode._(0, _omitEnumNames ? '' : 'MODE_UNSPECIFIED');
  static const ForwardTarget_Mode FOCUSED_WINDOW = ForwardTarget_Mode._(1, _omitEnumNames ? '' : 'FOCUSED_WINDOW');
  static const ForwardTarget_Mode SPECIFIC_WINDOW = ForwardTarget_Mode._(2, _omitEnumNames ? '' : 'SPECIFIC_WINDOW');

  static const $core.List<ForwardTarget_Mode> values = <ForwardTarget_Mode> [
    MODE_UNSPECIFIED,
    FOCUSED_WINDOW,
    SPECIFIC_WINDOW,
  ];

  static final $core.Map<$core.int, ForwardTarget_Mode> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ForwardTarget_Mode? valueOf($core.int value) => _byValue[value];

  const ForwardTarget_Mode._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
