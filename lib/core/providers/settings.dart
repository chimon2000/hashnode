import 'package:flutter/foundation.dart';

enum AppTheme { light, dark }
enum DisplayDensity { comfortable, compact }

class Settings with ChangeNotifier {
  AppTheme _theme = AppTheme.light;
  AppTheme get theme => _theme;

  DisplayDensity _displayDensity = DisplayDensity.comfortable;
  DisplayDensity get displayDensity => _displayDensity;

  void toggleTheme() {
    _theme = _theme == AppTheme.dark ? AppTheme.light : AppTheme.dark;
    notifyListeners();
  }

  void setDisplayDensity(DisplayDensity displayDensity) {
    _displayDensity = displayDensity;
    notifyListeners();
  }
}
