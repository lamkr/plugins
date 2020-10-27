// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

const MethodChannel _kChannel =
    MethodChannel('plugins.flutter.io/package_info');

/// Application metadata. Provides application bundle information on iOS and
/// application package information on Android.
///
/// ```dart
/// PackageInfo packageInfo = await PackageInfo.fromPlatform()
/// print("Version is: ${packageInfo.version}");
/// ```
class PackageInfo {
  static PackageInfo invalid = PackageInfo(buildNumber: '', packageName: '', appName: '', version: '');

  /// Constructs an instance with the given values for testing. [PackageInfo]
  /// instances constructed this way won't actually reflect any real information
  /// from the platform, just whatever was passed in at construction time.
  ///
  /// See [fromPlatform] for the right API to get a [PackageInfo] that's
  /// actually populated with real data.
  PackageInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
  });

  static PackageInfo _fromPlatform = PackageInfo.invalid;

  /// Retrieves package information from the platform.
  /// The result is cached.
  static Future<PackageInfo> fromPlatform() async {
    if( _fromPlatform != invalid ) {
      return _fromPlatform;
    }

    final map =
        await _kChannel.invokeMapMethod<String, dynamic>('getAll');
    if( map == null ) {
      throw Exception('Failure getting plataform informations.');
    }
    _fromPlatform = PackageInfo(
      appName: map['appName'],
      packageName: map['packageName'],
      version: map['version'],
      buildNumber: map['buildNumber'],
    );
    return _fromPlatform;
  }

  /// The app name. `CFBundleDisplayName` on iOS, `application/label` on Android.
  final String appName;

  /// The package name. `bundleIdentifier` on iOS, `getPackageName` on Android.
  final String packageName;

  /// The package version. `CFBundleShortVersionString` on iOS, `versionName` on Android.
  final String version;

  /// The build number. `CFBundleVersion` on iOS, `versionCode` on Android.
  final String buildNumber;

  @override
  bool operator ==(Object arg) {
    if (identical(this, arg)) {
      return true;
    }
    if (arg is! PackageInfo) {
      return false;
    }
    var other = arg;
    return other.appName == appName
      && other.buildNumber == buildNumber
      && other.packageName == packageName
      && other.version == version;
  }

  @override
  int get hashCode => _finish(_combine(
      _combine(_combine(_combine(0, appName.hashCode), buildNumber.hashCode), packageName.hashCode),
      version.hashCode));

  int _combine(int hash, int value) {
    hash = 0x1fffffff & (hash + value);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  int _finish(int hash) {
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }

}
