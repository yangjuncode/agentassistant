# protobuf-lite 生成类：MessageSchema 运行时按字段名反射（如 cmd_），混淆后会抛
# "Field xxx for ... not found"。保留整个生成包不混淆。
-keep class code.agentassistant.flutter.flutterclient.proto.** { *; }

# protobuf 运行时本身（GeneratedMessageLite 的 MethodToInvoke 分派、序列化代理等）
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.protobuf.**
