import 'package:flutter/material.dart';

import 'desktop_module_panel.dart';

/// Shared presentation only; feature entry points supply their own copy.
class ModulePlaceholder extends StatelessWidget {
  const ModulePlaceholder({
    required this.title,
    required this.subtitle,
    required this.headline,
    required this.description,
    required this.icon,
    required this.color,
    required this.previewLabels,
    this.desktop = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final String headline;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> previewLabels;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = theme.brightness == Brightness.dark
        ? Color.lerp(color, Colors.white, .4)!
        : color;

    if (desktop) {
      return DesktopModulePanel(title: title, icon: icon, accent: accent);
    }

    final denseMobile =
        MediaQuery.sizeOf(context).width < 600 &&
        MediaQuery.textScalerOf(context).scale(1) <= 1.4;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(denseMobile ? 8 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(denseMobile ? 6 : 8),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(denseMobile ? 9 : 12),
                  ),
                  child: Icon(icon, color: accent, size: denseMobile ? 20 : 24),
                ),
                SizedBox(width: denseMobile ? 7 : 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: denseMobile ? 1 : 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: denseMobile ? 10 : 16),
            Text(
              'COMING SOON',
              style: theme.textTheme.labelSmall?.copyWith(
                color: accent,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: denseMobile ? 4 : 6),
            Text(
              headline,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -.5,
              ),
            ),
            SizedBox(height: denseMobile ? 4 : 6),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: denseMobile ? 1.25 : 1.4,
              ),
            ),
            SizedBox(height: denseMobile ? 8 : 12),
            Wrap(
              spacing: denseMobile ? 4 : 6,
              runSpacing: denseMobile ? 4 : 6,
              children: [
                for (final label in previewLabels)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: denseMobile ? 7 : 9,
                      vertical: denseMobile ? 3 : 5,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
