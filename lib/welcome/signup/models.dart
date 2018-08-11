class EmailAndPasswordData {
  String username;
  String email;
  String password;

  EmailAndPasswordData({this.username, this.email, this.password});

  @override
  String toString() {
    return 'EmailAndPasswordData{}';
  }
}

class NameAndNumberData {
  String firstName;
  String lastName;
  String phoneNumber;

  NameAndNumberData({this.firstName, this.lastName, this.phoneNumber});

  @override
  String toString() {
    return 'NameAndNumberData{}';
  }
}
