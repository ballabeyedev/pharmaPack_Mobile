import 'package:package_info_plus/package_info_plus.dart';

class AppVersion {
  static Future<String> getVersion() async {
    final info = await PackageInfo.fromPlatform();
    return 'v${info.version}+${info.buildNumber}';
  }
}