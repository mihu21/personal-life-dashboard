import 'package:flutter/material.dart';

/// A bounded empty panel, without simulated records or loading indicators.
class DesktopModulePanel extends StatelessWidget {
  const DesktopModulePanel({
    required this.title,
    required this.icon,
    required this.accent,
    super.key,
  });

  final String title;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final headerHeight = (MediaQuery.textScalerOf(context).scale(20) + 28)
              .clamp(0.0, constraints.maxHeight);
          final showBody = constraints.maxHeight > headerHeight + 32;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: headerHeight,
                child: ColoredBox(
                  color: scheme.surfaceContainerLow.withValues(alpha: .5),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(icon, size: 20, color: accent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Keep the module title legible in narrower windows or
                        // with larger text. The body still identifies its state.
                        if (constraints.maxWidth > 520 &&
                            MediaQuery.textScalerOf(context).scale(12) <=
                                18) ...[
                          const SizedBox(width: 12),
                          Text(
                            'PLACEHOLDER',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              letterSpacing: .8,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (showBody) ...[
                Divider(height: 1, color: scheme.outlineVariant),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 28,
                              color: accent.withValues(alpha: .7),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Coming soon',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
