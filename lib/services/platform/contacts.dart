import 'dart:async';

import 'package:flutter/services.dart';

import 'permissions.dart';

class Contact {
  final String displayName;

  final List<String> numbers;

  const Contact(this.displayName, this.numbers);
}

class Contacts {
  static final Future<PermissionState> contactsPermission =
      Permissions.getPermissionState(PermissionType.contacts);

  static Future<List<Contact>> getContactsWithMobileNumber() async {
    List<Contact> contacts = List<Contact>();

    try {
      final List<dynamic> result =
          await Permissions.methodChannel.invokeMethod('getContacts');
      if (result != null) {
        for (var contact in result) {
          contacts.add(Contact(
            contact['NAME'],
            [contact["MAIN"], contact['MOBILE'], contact["IPHONE"]]
                .map((number) {
                  String phoneNumber = number as String;
                  if (phoneNumber == null || phoneNumber == '') {
                    return null;
                  }
                  return phoneNumber;
                })
                .where((number) => number != null)
                .toList(),
          ));
        }
      } else {
        return Future.error('Contacts could not be retrieved');
      }
    } on PlatformException catch (e) {
      print('Exception ' + e.toString());
    } catch (e) {
      print('Exception ' + e.toString());
    }
    return contacts;
  }
}
