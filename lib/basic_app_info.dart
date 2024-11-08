import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

final class AppInfoException implements Exception {
  const AppInfoException(this.error);

  final Object error;

  @override
  String toString() {
    return 'AppInfoException: $error';
  }
}

enum System {
  android,
  ios;
}

final class AppInfo {
  const AppInfo._({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.system,
    required this.device,
    required this.isPhysicalDevice,
    this.installerStore,
  });

  /// The app name.
  ///
  /// - `CFBundleDisplayName` on iOS, falls back to `CFBundleName`.
  ///   Defined in the `info.plist` and/or product target in xcode.
  /// - `application/label` on Android.
  ///   Defined in `AndroidManifest.xml` or String resources.
  final String appName;

  /// The package name.
  ///
  /// - `bundleIdentifier` on iOS.
  ///   Defined in the product target in xcode.
  /// - `packageName` on Android.
  ///   Defined in `build.gradle` as `applicationId`.
  final String packageName;

  /// The package version.
  /// Generated from the version in `pubspec.yaml`.
  ///
  /// - `CFBundleShortVersionString` on iOS.
  /// - `versionName` on Android.
  final String version;

  /// The build number.
  /// Generated from the version in `pubspec.yaml`.
  ///
  /// - `CFBundleVersion` on iOS and macOs.
  /// - `versionCode` on Android.

  final String buildNumber;

  /// The installer store. Indicates through which store
  /// this application was installed.
  final String? installerStore;

  /// The system on which the app is running.
  /// Either [System.android] or [System.ios].
  final System system;

  /// The device on which the app is running.
  final String device;

  /// false if the application is running in an emulator, true otherwise.
  final bool isPhysicalDevice;

  static Future<AppInfo> get() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfoPlugin = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;

        return AppInfo._(
          appName: packageInfo.appName,
          packageName: packageInfo.packageName,
          version: packageInfo.version,
          buildNumber: packageInfo.buildNumber,
          installerStore: packageInfo.installerStore,
          system: System.android,
          device: androidInfo.model,
          isPhysicalDevice: androidInfo.isPhysicalDevice,
        );
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;

        return AppInfo._(
          appName: packageInfo.appName,
          packageName: packageInfo.packageName,
          version: packageInfo.version,
          buildNumber: packageInfo.buildNumber,
          installerStore: packageInfo.installerStore,
          system: System.ios,
          device: iosInfo.utsname.machine,
          isPhysicalDevice: iosInfo.isPhysicalDevice,
        );
      } else {
        throw const AppInfoException('Unsupported platform');
      }
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(AppInfoException(error), stackTrace);
    }
  }
}
