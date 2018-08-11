import '../../services/platform/permissions.dart';
import 'category.dart';
import 'mindset.dart';
import 'notification.dart';
import 'onboarding.dart';
import 'question_set.dart';
import 'score.dart';

/// Build runner wants to convert DateTime objects to Strings for
/// storage, but Firebase accepts pure DateTime objects, so we'll
/// leave them as such.
DateTime dateTimeFromJson(dateTime) => dateTime as DateTime;

/// Build runner wants to convert DateTime objects to Strings for
/// storage, but Firebase accepts pure DateTime objects, so we'll
/// leave them as such.
DateTime dateTimeToJson(dateTime) => dateTime;

Map<Category, double> categoryValuesFromJson(Map json) {
  json = json.map((key, val) => MapEntry<String, dynamic>(key as String, val));
  return Map<Category, double>.fromIterables(
    json.keys.map((key) => Category.values
            .singleWhere((el) => el.toString() == 'Category.$key', orElse: () {
          print('Bad category: $key');
        })),
    json.values.map((val) => (val as num).toDouble()),
  );
}

Map<String, double> categoryValuesToJson(
    Map<Category, double> categoryWeights) {
  return Map<String, double>.fromIterables(
    categoryWeights.keys.map((key) => key.toString().split('.')[1]),
    categoryWeights.values,
  );
}

Map<Mindsets, double> mindsetWeightedFromJson(Map json) {
  Map<String, dynamic> jsonMap = jsonMapFromMap(json);
  return Map<Mindsets, double>.fromIterable(
      jsonMap.keys
          .map((key) => Mindsets.values.firstWhere(
                (q) =>
                    q.toString().split('.')[1].toLowerCase() ==
                    key.toLowerCase(),
                orElse: () => null,
              ))
          .where((key) => key != null),
      key: (key) => key,
      value: (key) =>
          (jsonMap[key.toString().split('.')[1]] as num).toDouble());
}

Map<String, double> mindsetWeightedToJson(
    Map<Mindsets, double> mindsetWeighted) {
  return Map<String, double>.fromIterables(
    mindsetWeighted.keys.map((key) => key.toString().split('.')[1]),
    mindsetWeighted.values,
  );
}

Map<QuestionSet, double> questionSetWeightedFromJson(Map json) {
  Map<String, dynamic> jsonMap = jsonMapFromMap(json);
  return Map<QuestionSet, double>.fromIterables(
      jsonMap.keys.map((key) => QuestionSet.values
          .firstWhere((q) => q.toString().split('.')[1] == key)),
      jsonMap.values.map((val) => (val as num).toDouble()));
}

Map<String, double> questionSetWeightedToJson(
    Map<QuestionSet, double> questionSetWeighted) {
  return Map<String, double>.fromIterables(
      questionSetWeighted.keys.map((key) => key.toString().split('.')[1]),
      questionSetWeighted.values);
}

Map<Mindsets, bool> privacySettingsFromJson(Map json) {
  Map<String, dynamic> jsonMap = jsonMapFromMap(json);
  return Map<Mindsets, bool>.fromIterables(
      jsonMap.keys.map((key) =>
          Mindsets.values.firstWhere((q) => q.toString().split('.')[1] == key)),
      jsonMap.values.map((val) => val as bool));
}

Map<String, bool> privacySettingsToJson(Map<Mindsets, bool> privacySettings) {
  return Map<String, bool>.fromIterables(
      privacySettings.keys.map((key) => key.toString().split('.')[1]),
      privacySettings.values);
}

/* user.dart */
const defaultRoles = {
  'test': false,
  'private': false,
};

Map<String, bool> rolesFromJson(dynamic json) {
  if (json is List) {
    if (json.length == 0) {
      return defaultRoles;
    }
    return Map<String, bool>.fromIterable(json,
        key: (el) => el as String, value: (_) => true);
  } else {
    Map jsonMap = json as Map;
    if (jsonMap.keys.length == 0) {
      return defaultRoles;
    }
    return Map<String, bool>.from(jsonMap);
  }
}

Map<String, dynamic> scoresToJson(Score scores) {
  return scores.toJson();
}

Map<QuestionSet, bool> testTakenFromJson(dynamic json) {
  if (json is bool) {
    return Map.fromIterable(QuestionSet.values, value: (_) => false);
  }
  Map map = json as Map;
  Map<String, dynamic> newMap =
      map.map((key, val) => MapEntry<String, dynamic>(key as String, val));
  return Map<QuestionSet, bool>.fromIterables(
    newMap.keys.map((key) => QuestionSet.values
        .singleWhere((el) => el.toString() == 'QuestionSet.$key')),
    newMap.values.map((val) => val as bool),
  );
}

Map<String, bool> testTakenToJson(Map<QuestionSet, bool> testTaken) {
  return Map<String, bool>.fromIterables(
    testTaken.keys.map((key) => key.toString().split('.')[1]),
    testTaken.values,
  );
}

Map<String, dynamic> onboardingToJson(Onboarding onboarding) {
  return onboarding.toJson();
}

Map<String, dynamic> jsonMapFromMap(Map json) {
  return Map<String, dynamic>.fromIterable(json.keys,
      key: (key) => key as String, value: (key) => json[key]);
}

NotificationBody notificationBodyFromJson(Map json) {
  return NotificationBody.fromJson(jsonMapFromMap(json));
}

NotificationData notificationDataFromJson(Map json) {
  return NotificationData.fromJson(jsonMapFromMap(json));
}

// *** device_info.dart *** //
Map<PermissionType, PermissionState> permissionsFromJson(
    Map<dynamic, dynamic> permissionsJson) {
  return permissionsJson.map((type, state) {
    return MapEntry(
        PermissionType.values.firstWhere(
            (el) => el.toString().split('.')[1] == (type as String)),
        PermissionState.values.firstWhere(
            (el) => el.toString().split('.')[1] == (state as String)));
  });
}

Map<String, String> permissionsToJson(
    Map<PermissionType, PermissionState> permissionsMap) {
  return permissionsMap.map((PermissionType type, PermissionState state) {
    return MapEntry(
        type.toString().split('.')[1], state.toString().split('.')[1]);
  });
}
