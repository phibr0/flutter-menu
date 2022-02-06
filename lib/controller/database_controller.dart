import 'dart:convert';

import 'package:menu/main.dart';
import 'package:menu/model/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../model/menu.dart';
import 'package:crypto/crypto.dart';

User? user;

class DatabaseController {
  Future<User?>? getUserDataFromDisk() async {
    String? name = await storage.read(key: 'user_name');
    String? lastName = await storage.read(key: 'user_last_name');
    String? password = await storage.read(key: 'user_password');
    if (name == null || lastName == null || password == null) {
      return null;
    }
    return getUserData(name, lastName, password);
  }

  Future<User> getUserData(String? name, String? lastName, String? password,
      {force = false}) async {
    if (force || user == null) {
      var result = await supabase
          .from('Users')
          .select('*')
          .eq('name', name)
          .eq('last_name', lastName)
          .eq('pwd_hash', sha256.convert(utf8.encode(password!)).toString())
          .execute();
      if (result.data?.length == 1) {
        user = User.fromSupabase(result.data.first);
        return user!;
      } else {
        throw result.error?.message ?? "Something went wrong.";
      }
    } else {
      return user!;
    }
  }

  Future<List<User>> getAllUsers() async {
    List<User> users = [];
    var response = await supabase.from('Users').select().execute();
    for (int i = 0; i < (response.data as List).length; i++) {
      users.add(User.fromSupabase(response.data[i]));
    }
    return users;
  }

  Future<void> deleteUser(String name, String lastName) async {
    await supabase
        .from('Users')
        .delete()
        .eq('name', name)
        .eq('last_name', lastName)
        .execute();
    return;
  }

  Future<void> resetPassword(
      String name, String lastName, String newPassword) async {
    await supabase
        .from('Users')
        .update(
          {"pwd_hash": sha256.convert(utf8.encode(newPassword)).toString()},
        )
        .eq('name', name)
        .eq('last_name', lastName)
        .execute();
    return;
  }

  Future<void> addUser(
      String name, String lastName, String type, String password) async {
    await supabase.from("Users").insert({
      "name": name,
      "last_name": lastName,
      "pwd_hash": sha256.convert(utf8.encode(password)).toString(),
      "user_type": type,
    }).execute();
    return;
  }

  onboardUser(String? preference, String email, String password) async {
    assert(user != null);
    var result = await supabase
        .from('Users')
        .update({
          'preferences': preference,
          'email': email,
          'pwd_hash': sha256.convert(utf8.encode(password)).toString(),
          'onboard': true
        })
        .eq('id', user!.id)
        .execute();

    if (result.hasError) {
      throw result.error!;
    }
  }

  Future<List<Menu>> menuOf({DateTime? date}) async {
    date ??= DateTime.now();
    final dateStr = "${date.year}-${date.month}-${date.day}T00:00:00.000Z";
    final preview = (await supabase
            .from('Preview')
            .select('id')
            .eq('start_date', dateStr)
            .execute())
        .data
        .first['id'];
    final menuIds = (await supabase
            .from('PreviewMenus')
            .select('menu')
            .eq('preview', preview)
            .execute())
        .data as List<dynamic>;

    var orStr = "";

    for (var i = 0; i < menuIds.length; i++) {
      orStr += "id.eq.${menuIds[i]['menu']}";
      if (i != menuIds.length - 1) {
        orStr += ",";
      }
    }

    var menuQuery =
        (await supabase.from('Menu').select('*').or(orStr).execute());

    if (menuQuery.hasError) throw menuQuery.error!.message;

    List<Menu> menus = [];

    for (var map in (menuQuery.data as List)) {
      menus.add(Menu.fromSupabase(map));
    }

    return menus;
  }

  order(String id) {
    supabase
        .from('Users')
        .update({
          'order_id': id,
          'tokens': user!.tokens != null
              ? user!.tokens = user!.tokens! - 1
              : user!.tokens = 0
        })
        .eq('id', user!.id)
        .execute();
    user!.order = id;
    user!.tokens != null ? user!.tokens = user!.tokens! - 1 : user!.tokens = 0;
  }

  Future<Menu> getMenuOfId(String id) async {
    return Menu.fromSupabase(
        (await supabase.from('Menu').select('*').eq('id', id).execute())
            .data
            .first);
  }

  Future<List<PreviewItem>> menuOfWeek() async {
    final today = DateTime.now();
    List<DateTime> dates = [];
    for (int i = 0; i < 7; i++) {
      dates.add(DateTime(today.year, today.month, today.day + i));
    }

    List<PreviewItem> menus = [];
    for (var date in dates) {
      List<Menu> m;
      try {
        m = await menuOf(date: date);
      } catch (e) {
        m = [];
      }
      menus.add(PreviewItem(m, date));
    }

    return menus;
  }

  Future<Map<String, int>> getOrderStats() async {
    var menus = await menuOf();
    Map<String, int> map = {};
    for (var i = 0; i < menus.length; i++) {
      map[menus[i].name] = (await supabase
                  .from('Users')
                  .select('*')
                  .eq('order_id', menus[i].id)
                  .execute(count: sb.CountOption.exact))
              .count ??
          0;
    }
    return map;
  }

  Future<List<int>> getPreferenceStats() async {
    return [
      (await supabase
              .from('Users')
              .select('*')
              .is_('preferences', 'NULL')
              .execute(count: sb.CountOption.exact))
          .count!,
      (await supabase
              .from('Users')
              .select('*')
              .eq('preferences', 'halal')
              .execute(count: sb.CountOption.exact))
          .count!,
      (await supabase
              .from('Users')
              .select('*')
              .eq('preferences', 'vegetarian')
              .execute(count: sb.CountOption.exact))
          .count!,
      (await supabase
              .from('Users')
              .select('*')
              .eq('preferences', 'vegan')
              .execute(count: sb.CountOption.exact))
          .count!,
    ];
  }

  Future<void> removeMenuOfPreview(DateTime date, String id) async {
    var result = await supabase
        .from('Preview')
        .select('id')
        .eq('start_date', date.toIso8601String())
        .execute();
    String? previewId = result.data.first['id'];
    if (previewId != null) {
      await supabase
          .from('PreviewMenus')
          .delete()
          .eq('preview', previewId)
          .eq('menu', id)
          .execute();
    }
  }

  Future<List<Menu>> listAllMenus() async {
    List<Menu> menus = [];
    var result = await supabase.from('Menu').select().execute();
    for (var map in result.data) {
      menus.add(Menu.fromSupabase(map));
    }
    return menus;
  }

  Future<void> addMenuToPreview(DateTime date, String id) async {
    var result = await supabase
        .from('Preview')
        .select('id')
        .eq('start_date', date.toIso8601String())
        .execute();

    String? previewId;
    try {
      previewId = result.data.first['id'];
    } catch (e) {
      await supabase
          .from('Preview')
          .insert({"start_date": date.toIso8601String()}).execute();
      var result = await supabase
          .from('Preview')
          .select('id')
          .eq('start_date', date.toIso8601String())
          .execute();
      previewId = result.data.first['id'];
    }
    if (previewId != null) {
      await supabase
          .from('PreviewMenus')
          .insert({"preview": previewId, "menu": id}).execute();
      return;
    }
  }

  Future<void> addMenu(String name, String description, String? type) async {
    await supabase.from('Menu').insert({
      "name": name,
      "description": description,
      "type": type,
    }).execute();
  }

  Future<void> removeOrderOfUser(String id) async {
    await supabase
        .from('Users')
        .update({'order_id': null})
        .eq('id', id)
        .execute();
  }

  Future<void> rateMenu(String menuId, int rating) async {
    var result = await supabase
        .from('Menu')
        .select('rating, rating_count')
        .eq('id', menuId)
        .execute();
    var ratingCount = result.data.first['rating_count'];
    var oldRating = result.data.first['rating'];
    await supabase
        .from('Menu')
        .update({'rating': oldRating + rating, 'rating_count': ratingCount + 1})
        .eq('id', menuId)
        .execute();
    return;
  }
}

class PreviewItem {
  List<Menu> menus;
  DateTime date;

  PreviewItem(this.menus, this.date);
}
