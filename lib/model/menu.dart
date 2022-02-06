import 'package:menu/model/database_item.dart';

class Menu extends DatabaseItem {
  late DateTime createdAt;
  late String name;
  late String description;
  late String? type;
  late double rating;

  Menu(this.createdAt, this.name, this.description, this.type, String id,
      int rating, int ratingCount)
      : super(id) {
    this.rating = ratingCount == 0 ? 0 : rating / ratingCount;
  }

  static Menu fromSupabase(dynamic data) {
    return Menu(
        DateTime.parse(data['created_at']!),
        data['name']!,
        data['description']!,
        data['type'],
        data['id']!,
        data['rating']!,
        data['rating_count']!);
  }
}
