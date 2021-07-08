import 'package:flutter/material.dart';
import 'package:hashnode/core/providers/settings.dart';
import 'package:hashnode/presentation/ui/pages/about/about_page.dart';
import 'package:provider/provider.dart';

@visibleForTesting
class StoryPageHeader extends StatelessWidget implements PreferredSizeWidget {
  const StoryPageHeader({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: Consumer<Settings>(
        builder: (context, settings, _) {
          return IconButton(
            key: themeButtonKey,
            icon: Image(
              image: settings.theme == AppTheme.dark
                  ? AssetImage('images/hashnode_light_32.png')
                  : AssetImage('images/hashnode_dark_32.png'),
            ),
            onPressed: () => settings.toggleTheme(),
          );
        },
      ),
      actions: <Widget>[SettingsMenuButton()],
      elevation: 0.0,
    );
  }

  @visibleForTesting
  static const themeButtonKey = ValueKey('story_list_header_theme_button_key');
}

@visibleForTesting
class SettingsMenuButton extends StatelessWidget {
  const SettingsMenuButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (dynamic value) {
        if (value is AppTheme) {
          context.read<Settings>().toggleTheme();
        }

        if (value is DisplayDensity) {
          context.read<Settings>().setDisplayDensity(value);
        }

        if (value == 'about') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AboutPage();
              },
            ),
          );
        }
      },
      itemBuilder: (context) {
        final settings = context.read<Settings>();
        final themeText = settings.theme == AppTheme.dark
            ? "Disable dark mode"
            : "Enable dark mode";

        final displayDensity = settings.displayDensity;
        final isDisplayComfortable =
            displayDensity == DisplayDensity.comfortable;
        final displayDensityText = isDisplayComfortable
            ? 'Enable compact mode'
            : 'Disable compact mode';

        return [
          PopupMenuItem<AppTheme>(
            key: themeButtonKey,
            value: settings.theme,
            child: Text(themeText),
          ),
          PopupMenuItem<DisplayDensity>(
            key: displayButtonKey,
            value: isDisplayComfortable
                ? DisplayDensity.compact
                : DisplayDensity.comfortable,
            child: Text(displayDensityText),
          ),
          PopupMenuItem<String>(
            key: aboutButtonKey,
            value: 'about',
            child: Text('About'),
          ),
        ];
      },
    );
  }

  @visibleForTesting
  static const themeButtonKey = ValueKey('settings_theme_button_key');

  @visibleForTesting
  static const displayButtonKey = ValueKey('settings_display_button_key');

  @visibleForTesting
  static const aboutButtonKey = ValueKey('settings_about_button_key');
}
