import '../../auth/models/public_user.dart';
import 'contacts.dart';
import 'permissions.dart';

class GetAllPermissionStates {
  GetAllPermissionStates();

  @override
  String toString() {
    return 'GetAllPermissionStates{}';
  }
}

class GetPermissionState {
  PermissionType permissionType;

  GetPermissionState(this.permissionType);

  @override
  String toString() {
    return 'GetPermissionState{type: $permissionType}';
  }
}

class GetPermissionStateResponse {
  PermissionType permissionType;
  PermissionState permissionState;

  GetPermissionStateResponse(this.permissionType, this.permissionState);

  @override
  String toString() {
    return 'GetPermissionStateResponse{type: $permissionType, state: $permissionState}';
  }
}

class RequestPermission {
  PermissionType permissionType;

  RequestPermission(this.permissionType);

  @override
  String toString() {
    return 'RequestPermission{type: $permissionType}';
  }
}

class RequestPermissionResponse {
  PermissionType permissionType;
  PermissionState permissionState;

  RequestPermissionResponse(this.permissionType, this.permissionState);

  @override
  String toString() {
    return 'RequestPermissionResponse{type: $permissionType, state: $permissionState}';
  }
}

class UpdatePermission {
  PermissionType permissionType;
  PermissionState permissionState;

  UpdatePermission(this.permissionType, this.permissionState);

  @override
  String toString() {
    return 'UpdatePermission{type: $permissionType, state: $permissionState}';
  }
}

class UpdatePermissions {
  List<MapEntry<PermissionType, PermissionState>> permissionUpdates;

  UpdatePermissions(this.permissionUpdates);

  @override
  String toString() {
    return 'UpdatePermissions{permissions: $permissionUpdates}';
  }
}

class SendPhoneNumberVerification {
  String phoneNumber;

  SendPhoneNumberVerification(this.phoneNumber);

  @override
  String toString() {
    return 'SendPhoneNumberVerification{phoneNumber: $phoneNumber}';
  }
}

class ResendPhoneNumberVerification {
  String phoneNumber;

  ResendPhoneNumberVerification(this.phoneNumber);

  @override
  String toString() {
    return 'ResendPhoneNumberVerification{phoneNumber: $phoneNumber}';
  }
}

class SetPhoneVerificationID {
  String verificationId;

  SetPhoneVerificationID(this.verificationId);

  @override
  String toString() {
    return 'SetPhoneVerificationID{verificationId: $verificationId}';
  }
}

class CheckPhoneVerified {
  CheckPhoneVerified();

  @override
  String toString() {
    return 'CheckPhoneVerified{}';
  }
}

class VerifyPhoneNumberWithCode {
  String verificationId;
  String verificationCode;

  VerifyPhoneNumberWithCode({this.verificationId, this.verificationCode});

  @override
  String toString() {
    return 'VerifyPhoneNumberWithCode{verificationId: $verificationId, verificationCode: $verificationCode}';
  }
}

class GetContacts {
  GetContacts();

  @override
  String toString() {
    return 'GetContacts{}';
  }
}

class GetFriendsForContacts {
  List<Contact> contacts;

  GetFriendsForContacts(this.contacts);

  @override
  String toString() {
    return 'GetFriendsForContacts{contacts is ${contacts == null || contacts.isEmpty ? "" : "not "}null';
  }
}

class GetFriendsForContactsResponse {
  List<PublicUser> users;

  GetFriendsForContactsResponse(this.users);

  @override
  String toString() {
    return 'GetFriendsForContactsResponse{users: $users}';
  }
}
