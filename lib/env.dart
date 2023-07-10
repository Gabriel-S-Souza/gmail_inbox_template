sealed class Env {
  const Env._();
  // gmail api
  static const idAndroidClientGCP = String.fromEnvironment('idAndroidClientIdGCP');
  static const androidKeyGCP = String.fromEnvironment('androidKeyGCP');

  // android
  static const androidApiKey = String.fromEnvironment('androidApiKey');
  static const androidAppId = String.fromEnvironment('androidAppId');
  static const androidMessagingSenderId = String.fromEnvironment('androidMessagingSenderId');
  static const androidProjectId = String.fromEnvironment('androidProjectId');
  static const androidStorageBucket = String.fromEnvironment('androidStorageBucket');

  // ios
  static const iosApiKey = String.fromEnvironment('iosApiKey');
  static const iosAppId = String.fromEnvironment('iosAppId');
  static const iosMessagingSenderId = String.fromEnvironment('iosMessagingSenderId');
  static const iosProjectId = String.fromEnvironment('iosProjectId');
  static const iosStorageBucket = String.fromEnvironment('iosStorageBucket');
  static const iosClientId = String.fromEnvironment('iosClientId');
  static const iosBundleId = String.fromEnvironment('iosBundleId');

  // web
  static const webApiKey = String.fromEnvironment('webApiKey');
  static const webAppId = String.fromEnvironment('webAppId');
  static const webMessagingSenderId = String.fromEnvironment('webMessagingSenderId');
  static const webProjectId = String.fromEnvironment('webProjectId');
  static const webStorageBucket = String.fromEnvironment('webStorageBucket');
  static const webAuthDomain = String.fromEnvironment('webAuthDomain');

  // macos
  static const macosApiKey = String.fromEnvironment('macosApiKey');
  static const macosAppId = String.fromEnvironment('macosAppId');
  static const macosMessagingSenderId = String.fromEnvironment('macosMessagingSenderId');
  static const macosProjectId = String.fromEnvironment('macosProjectId');
  static const macosStorageBucket = String.fromEnvironment('macosStorageBucket');
  static const macosClientId = String.fromEnvironment('macosIosClientId');
  static const macosBundleId = String.fromEnvironment('macosIosBundleId');
}
