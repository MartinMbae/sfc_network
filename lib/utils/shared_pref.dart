import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  final String id = "id";
  final String firstName = "first_name";
  final String lastName = "last_name";
  final String email = "email";
  final String username = "username";
  final String phone = "phone";

  Future<void> setFirstName(String firstName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(this.firstName, firstName);
  }
  Future<String> getFirstName() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(this.firstName) ?? null;
  }

  Future<void> setLastName(String lastName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(this.lastName, lastName);
  }
  Future<String> getLastName() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(this.lastName) ?? null;
  }


  Future<void> setEmail(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(this.email, email);
  }
  Future<String> getEmail() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(this.email) ?? null;
  }


  Future<void> setUsername(String username) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(this.username, username);
  }
  Future<String> getUsername() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(this.username) ?? null;
  }


  Future<void> setPhone(String phone) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(this.phone, phone);
  }
  Future<String> getPhone() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(this.phone) ?? null;
  }


  Future<void> setId(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(this.id, id);
  }
  Future<int> getId() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getInt(this.id) ?? null;
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

}