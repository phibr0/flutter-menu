import 'dart:collection';
import 'database_item.dart';

class User extends DatabaseItem {
  late DateTime createdAt;
  late String name;
  late String lastName;
  late String? email;
  late String pwdHash;
  late String? order; //UUID
  late String? preference;
  late bool onboard;
  late String? userType;
  late int? tokens;

  User(
      this.createdAt,
      this.name,
      this.lastName,
      this.email,
      this.pwdHash,
      this.onboard,
      this.order,
      this.preference,
      this.tokens,
      this.userType,
      String id)
      : super(id);

  static fromSupabase(dynamic data) {
    return User(
      DateTime.parse(data['created_at']),
      data['name'],
      data['last_name'],
      data['email'],
      data['pwd_hash'],
      data['onboard'],
      data['order_id'],
      data['preferences'],
      data['tokens'],
      data['user_type'],
      data['id'],
    );
  }
}
