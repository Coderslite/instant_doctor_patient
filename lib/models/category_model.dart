import 'dart:ui';

class Categories {
  String? name;
  String? cat;
  String? image;
  VoidCallback? onTap;
  Categories({
    this.name,
    this.cat,
    this.image,
    this.onTap,
  });
}
