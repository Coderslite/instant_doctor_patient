import 'dart:ui';

import 'package:flutter/material.dart';

class Categories {
  String? name;
  String? cat;
  String? image;
  GlobalKey<State<StatefulWidget>>? key;
  VoidCallback? onTap;
  Categories({
    this.name,
    this.cat,
    this.image,
    this.onTap,
    this.key,
  });
}
