class user {
  final String username;
  final String password;

  user({required this.username, required this.password});
}

class admin {
  final String username;
  final String password;

  admin(this.username, this.password);
}

class DbKisiler {
  static final List<user> users = [
    user(username: 'zeynep', password: '4551'),
    user(username: 'yberke', password: '1112'),
    user(username: 'ayse', password: '1234'),
  ];

  static final List<admin> admins = [
    admin("admin", "1234")
  ];
  
  static bool checkUserLogin(String username, String password) {
    return users.any((u) => u.username == username && u.password == password);
  }

  static bool checkAdminLogin(String username, String password) {
    return admins.any((a) => a.username == username && a.password == password);
  }
}