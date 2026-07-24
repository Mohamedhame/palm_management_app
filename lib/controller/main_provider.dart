import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nakeel_demo/services/shared_prefs_helper.dart';

class MainProvider extends ChangeNotifier {
  Map<String, dynamic> getUserData() {
    String userRawData = SharedPrefsHelper.getString("user");
    if (userRawData.isNotEmpty) {
      try {
        Map<String, dynamic> userMap =
            jsonDecode(userRawData) as Map<String, dynamic>;
        return userMap;
      } catch (e) {
        return {};
      }
    }
    return {};
  }
}
