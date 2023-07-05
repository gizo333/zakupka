import 'package:flutter/material.dart';

class PositionClass {
  int? code;
  late String name;
  int? ml;
  int? itog;

  late TextEditingController codeController;
  late TextEditingController nameController;
  late TextEditingController mlController;
  late TextEditingController itogController;

  PositionClass(this.code, this.name, this.ml, this.itog) {
    codeController = TextEditingController(text: code?.toString() ?? '');
    nameController = TextEditingController(text: name);
    mlController = TextEditingController(text: ml?.toString() ?? '');
    itogController = TextEditingController(text: itog?.toString() ?? '');
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'code': code,
  //     'name': name,
  //     'ml': ml,
  //     'itog': itog,
  //  };
  // }
}

