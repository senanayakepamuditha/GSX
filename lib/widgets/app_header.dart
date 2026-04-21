import 'package:flutter/material.dart';
import '../config/app_config.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showLogo;

  const AppHeader({
    super.key,
    this.title,
    this.actions,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLogo) ...[
            Icon(Icons.eco_rounded, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
          ],
          Text(
            title ?? AppConfig.appName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
