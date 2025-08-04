# Agent Assistant Flutter 客户端构建指南

## 环境要求

### 必需软件

1. **Flutter SDK** (>= 3.5.0)

   ```bash
   # 检查 Flutter 版本
   flutter --version
   
   # 检查环境
   flutter doctor
   ```

2. **Dart SDK** (包含在 Flutter 中)

3. **Protocol Buffers 编译器**

   ```bash
   # macOS
   brew install protobuf
   
   # Ubuntu/Debian
   sudo apt-get install protobuf-compiler
   
   # Windows
   # 从 https://github.com/protocolbuffers/protobuf/releases 下载
   ```

4. **protoc-gen-dart 插件**

   ```bash
   dart pub global activate protoc_plugin
   ```

### 开发环境

- **Android Studio** 或 **VS Code**
- **Android SDK** (用于 Android 构建)
- **Xcode** (用于 iOS 构建，仅 macOS)

## 项目设置

### 1. 克隆项目

```bash
cd agentassistant/flutterclient
```

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 生成 Protobuf 文件

```bash
# 使用提供的脚本
./generate_proto.sh

# 或手动生成
protoc --proto_path=../proto --dart_out=lib/proto ../proto/agentassist.proto
```

### 4. 验证设置

```bash
# 检查代码
flutter analyze

# 运行测试
flutter test
```

## 构建流程

### 开发构建

```bash
# 调试模式运行
flutter run

# 指定设备
flutter run -d <device_id>

# 热重载开发
# 在运行时按 'r' 进行热重载
# 按 'R' 进行热重启
```

### 生产构建

#### Android APK

```bash
# 构建调试 APK
flutter build apk --debug

# 构建发布 APK
flutter build apk --release

# 构建 App Bundle (推荐用于 Google Play)
flutter build appbundle --release
```

#### iOS IPA

```bash
# 构建 iOS (仅 macOS)
flutter build ios --release

# 构建 IPA
flutter build ipa --release
```

#### Web 版本

```bash
# 构建 Web 版本
flutter build web --release
```

## 配置选项

### 应用配置

编辑 `lib/config/app_config.dart`:

```dart
class AppConfig {
  // 默认服务器配置
  static const String defaultWebSocketHost = 'your-server.com';
  static const int defaultWebSocketPort = 8080;
  
  // 连接设置
  static const int maxReconnectAttempts = 5;
  static const int reconnectDelayMs = 1000;
}
```

### Android 配置

编辑 `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.example.agentassistant"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

### iOS 配置

编辑 `ios/Runner/Info.plist`:

```xml
<key>CFBundleDisplayName</key>
<string>Agent Assistant</string>
<key>CFBundleIdentifier</key>
<string>com.example.agentassistant</string>
```

## 签名和发布

### Android 签名

1. **生成密钥库**

   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **配置签名**
   创建 `android/key.properties`:

   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=<path-to-upload-keystore.jks>
   ```

3. **更新 build.gradle**

   ```gradle
   signingConfigs {
       release {
           keyAlias keystoreProperties['keyAlias']
           keyPassword keystoreProperties['keyPassword']
           storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
           storePassword keystoreProperties['storePassword']
       }
   }
   ```

### iOS 签名

1. **配置开发者账号**
   - 在 Xcode 中配置 Apple Developer 账号
   - 设置 Bundle Identifier
   - 配置 Provisioning Profile

2. **构建和上传**

   ```bash
   flutter build ipa --release
   ```

## 持续集成

### GitHub Actions 示例

创建 `.github/workflows/build.yml`:

```yaml
name: Build Flutter App

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.5.0'
    
    - name: Install dependencies
      run: |
        cd flutterclient
        flutter pub get
    
    - name: Generate protobuf
      run: |
        cd flutterclient
        ./generate_proto.sh
    
    - name: Analyze code
      run: |
        cd flutterclient
        flutter analyze
    
    - name: Run tests
      run: |
        cd flutterclient
        flutter test
    
    - name: Build APK
      run: |
        cd flutterclient
        flutter build apk --release
```

## 性能优化

### 构建优化

```bash
# 启用混淆 (Android)
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# 减小包大小
flutter build apk --release --split-per-abi
```

### 代码优化

1. **移除未使用的代码**

   ```bash
   flutter analyze --no-fatal-infos
   ```

2. **优化图片资源**
   - 使用 WebP 格式
   - 提供多分辨率版本

3. **延迟加载**
   - 使用 `lazy` 加载大型组件
   - 实现虚拟滚动

## 调试和测试

### 调试工具

```bash
# 启动调试模式
flutter run --debug

# 性能分析
flutter run --profile

# 查看日志
flutter logs
```

### 测试策略

1. **单元测试**

   ```bash
   flutter test test/unit/
   ```

2. **集成测试**

   ```bash
   flutter drive --target=test_driver/app.dart
   ```

3. **设备测试**

   ```bash
   # 列出可用设备
   flutter devices
   
   # 在特定设备上测试
   flutter run -d <device_id>
   ```

## 故障排除

### 常见构建问题

1. **Gradle 构建失败**

   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   ```

2. **iOS 构建失败**

   ```bash
   cd ios
   rm -rf Pods
   rm Podfile.lock
   pod install
   cd ..
   flutter clean
   flutter pub get
   ```

3. **Protobuf 生成失败**

   ```bash
   dart pub global activate protoc_plugin
   export PATH="$PATH:$HOME/.pub-cache/bin"
   ./generate_proto.sh
   ```

### 性能问题

1. **启动时间优化**
   - 减少启动时的初始化工作
   - 使用 splash screen

2. **内存使用优化**
   - 及时释放资源
   - 使用对象池

3. **网络优化**
   - 实现请求缓存
   - 使用连接池

## 发布清单

### 发布前检查

- [ ] 代码分析通过 (`flutter analyze`)
- [ ] 所有测试通过 (`flutter test`)
- [ ] 性能测试完成
- [ ] 多设备兼容性测试
- [ ] 网络异常处理测试
- [ ] 用户界面测试
- [ ] 安全性检查

### 发布步骤

1. **更新版本号**
   - 更新 `pubspec.yaml` 中的版本
   - 更新平台特定的版本配置

2. **构建发布版本**

   ```bash
   flutter build apk --release
   flutter build appbundle --release  # Android
   flutter build ipa --release        # iOS
   ```

3. **测试发布版本**
   - 在真实设备上测试
   - 验证所有功能正常

4. **上传到应用商店**
   - Google Play Console (Android)
   - App Store Connect (iOS)

## 维护和更新

### 依赖更新

```bash
# 检查过时的依赖
flutter pub outdated

# 更新依赖
flutter pub upgrade
```

### 安全更新

- 定期更新 Flutter SDK
- 更新第三方依赖
- 检查安全漏洞

### 监控和分析

- 集成崩溃报告 (Firebase Crashlytics)
- 性能监控
- 用户行为分析

通过遵循这个构建指南，您可以成功构建和部署 Agent Assistant Flutter 客户端应用。
