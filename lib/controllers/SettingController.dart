import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../AppLocalizations.dart';
import '../constant/color.dart';
import '../constant/constants.dart';
import '../services/getVideoCallKeys.dart';

class SettingsController extends GetxController {
  Rx<bool> isDarkMode = false.obs;
  String selectedLanguage = defaultLanguage;
  AppLocalizations? appLocale;
  RxInt selectedIndex = 0.obs;
  var trialAvailable = false.obs;
  var loggedIn = false.obs;

  RxBool shouldLock = false.obs;
  RxBool isAuthScreenActive = false.obs;

  int? appId;
  String appSign = '';

  bool panelOpened = false;
  var panelController = PanelController();

  void setLanguage(String val) {
    selectedLanguage = val;
  }

  String translate(String key) {
    return appLocale!.translate(key);
  }

  handleChangeTheme() {
    isDarkMode.value = !isDarkMode.value;
    setTheme(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    if (isDarkMode.value) {
      setValue(THEME_MODE_INDEX, ThemeModeDark);
    } else {
      setValue(THEME_MODE_INDEX, ThemeModeLight);
    }
  }

  setTheme(ThemeMode theme) {
    if (theme == ThemeMode.dark) {
      textPrimaryColorGlobal = Colors.white;
      textSecondaryColorGlobal = textSecondaryColor;

      defaultLoaderBgColorGlobal = scaffoldSecondaryDark;
      appButtonBackgroundColorGlobal = appButtonColorDark;
      shadowColorGlobal = Colors.white12;
      setStatusBarColor(Colors.transparent, systemNavigationBarColor: null);
    } else {
      textPrimaryColorGlobal = textPrimaryColor;
      textSecondaryColorGlobal = textSecondaryColor;

      defaultLoaderBgColorGlobal = Colors.white;
      appButtonBackgroundColorGlobal = Colors.white;
      shadowColorGlobal = Colors.black12;
      setStatusBarColor(transparentColor, systemNavigationBarColor: null);
    }
  }

  handleGetVideoCallKeys() async {
    var data = await getVideoCallKeys();
    appId = data.appId!;
    appSign = data.appSign!;
    print("app Id $appId");
    print("app Sign $appSign");
  }
}
