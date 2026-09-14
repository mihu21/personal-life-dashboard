import 'package:flutter/material.dart';

import 'app_density.dart';

abstract final class AppTheme {
  static final light = _build(Brightness.light);
  static final dark = _build(Brightness.dark);

  /// Applied above the Navigator so pushed pages and dialog routes use the
  /// same base typography. System text scaling remains entirely untouched.
  static ThemeData responsive(BuildContext context, ThemeData theme) {
    final mobile = AppDensity.isMobile(context);
    final text = theme.textTheme;
    final type = mobile
        ? text.copyWith(
            headlineLarge: text.headlineLarge?.copyWith(fontSize: 22),
            headlineMedium: text.headlineMedium?.copyWith(fontSize: 20),
            headlineSmall: text.headlineSmall?.copyWith(fontSize: 18),
            titleLarge: text.titleLarge?.copyWith(fontSize: 18),
            titleMedium: text.titleMedium?.copyWith(fontSize: 14),
            titleSmall: text.titleSmall?.copyWith(fontSize: 13),
            bodyLarge: text.bodyLarge?.copyWith(fontSize: 13),
            bodyMedium: text.bodyMedium?.copyWith(fontSize: 12),
            bodySmall: text.bodySmall?.copyWith(fontSize: 11),
            labelLarge: text.labelLarge?.copyWith(fontSize: 12),
            labelMedium: text.labelMedium?.copyWith(fontSize: 11),
            labelSmall: text.labelSmall?.copyWith(fontSize: 10),
          )
        : text;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final controls = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(0, AppDensity.controlHeight(context)),
      ),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 10, vertical: mobile ? 5 : 8),
      ),
      visualDensity: mobile ? VisualDensity.compact : VisualDensity.standard,
      textStyle: WidgetStatePropertyAll(type.labelLarge),
    );
    return theme.copyWith(
      textTheme: type,
      visualDensity: mobile ? VisualDensity.standard : VisualDensity.compact,
      iconTheme: theme.iconTheme.copyWith(size: mobile ? 20 : 24),
      appBarTheme: theme.appBarTheme.copyWith(
        toolbarHeight: mobile
            ? (textScale <= 1.4
                  ? 38
                  : MediaQuery.textScalerOf(context)
                            .scale(18)
                            .clamp(28, double.infinity) +
                        16)
            : null,
        titleTextStyle: type.titleLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        titleSpacing: mobile ? 10 : 16,
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
        constraints: const BoxConstraints(minHeight: 44),
      ),
      filledButtonTheme: FilledButtonThemeData(style: controls),
      outlinedButtonTheme: OutlinedButtonThemeData(style: controls),
      textButtonTheme: TextButtonThemeData(style: controls),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(
            Size.square(AppDensity.controlHeight(context)),
          ),
          padding: WidgetStatePropertyAll(
            EdgeInsets.all(mobile && textScale <= 1.4 ? 5 : 8),
          ),
          visualDensity: mobile ? VisualDensity.compact : VisualDensity.standard,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      chipTheme: theme.chipTheme.copyWith(
        labelStyle: type.labelLarge,
        padding: EdgeInsets.symmetric(
          horizontal: 4,
          vertical: mobile && textScale <= 1.4 ? 0 : 2,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      listTileTheme: theme.listTileTheme.copyWith(
        titleTextStyle: type.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        subtitleTextStyle: type.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: mobile ? 10 : 12,
          vertical: 2,
        ),
      ),
      dialogTheme: theme.dialogTheme.copyWith(
        insetPadding: EdgeInsets.symmetric(
          horizontal: AppDensity.dialogInset(context),
          vertical: 12,
        ),
      ),
      navigationBarTheme: theme.navigationBarTheme.copyWith(
        height: mobile && textScale <= 1.4 ? 48 : 56,
        labelTextStyle: WidgetStatePropertyAll(type.labelSmall),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(size: mobile && textScale <= 1.4 ? 19 : 22),
        ),
      ),
    );
  }

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6960A8),
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.compact,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF6F5F9)
          : const Color(0xFF141319),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .6)),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        dense: true,
        minVerticalPadding: 2,
        horizontalTitleGap: 8,
        minLeadingWidth: 24,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
