import '../theme.dart';

const String appStoreUrl = 'http://beta.humbleme.us';
const String googlePlayUrl =
    'https://play.google.com/apps/testing/com.humbleme.humblemeandroid';

class Invites {
  static String getInvite() {
    return 'Join me on HumbleMe! ${kIsAndroid ? googlePlayUrl : appStoreUrl}';
  }
}
