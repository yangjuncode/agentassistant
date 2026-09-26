// This is a generated file - do not edit.
//
// Generated from agentassist.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ForwardTarget_Mode extends $pb.ProtobufEnum {
  static const ForwardTarget_Mode MODE_UNSPECIFIED =
      ForwardTarget_Mode._(0, _omitEnumNames ? '' : 'MODE_UNSPECIFIED');

  /// forward to current focused window
  static const ForwardTarget_Mode FOCUSED_WINDOW =
      ForwardTarget_Mode._(1, _omitEnumNames ? '' : 'FOCUSED_WINDOW');

  /// forward to the specific window id
  static const ForwardTarget_Mode SPECIFIC_WINDOW =
      ForwardTarget_Mode._(2, _omitEnumNames ? '' : 'SPECIFIC_WINDOW');

  static const $core.List<ForwardTarget_Mode> values = <ForwardTarget_Mode>[
    MODE_UNSPECIFIED,
    FOCUSED_WINDOW,
    SPECIFIC_WINDOW,
  ];

  static final $core.List<ForwardTarget_Mode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ForwardTarget_Mode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ForwardTarget_Mode._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
