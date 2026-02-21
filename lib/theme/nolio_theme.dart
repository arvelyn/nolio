import 'dart:ui';

import 'package:flutter/material.dart';

class NolioTheme extends ThemeExtension<NolioTheme> {
  final bool glass;
  final double panelOpacity;
  final double borderOpacity;
  final double blurSigma;

  const NolioTheme({
    required this.glass,
    required this.panelOpacity,
    required this.borderOpacity,
    required this.blurSigma,
  });

  static NolioTheme of(BuildContext context) {
    return Theme.of(context).extension<NolioTheme>() ??
        const NolioTheme(
          glass: false,
          panelOpacity: 0.06,
          borderOpacity: 0.0,
          blurSigma: 24,
        );
  }

  @override
  NolioTheme copyWith({
    bool? glass,
    double? panelOpacity,
    double? borderOpacity,
    double? blurSigma,
  }) {
    return NolioTheme(
      glass: glass ?? this.glass,
      panelOpacity: panelOpacity ?? this.panelOpacity,
      borderOpacity: borderOpacity ?? this.borderOpacity,
      blurSigma: blurSigma ?? this.blurSigma,
    );
  }

  @override
  NolioTheme lerp(ThemeExtension<NolioTheme>? other, double t) {
    if (other is! NolioTheme) return this;
    return NolioTheme(
      glass: t < 0.5 ? glass : other.glass,
      panelOpacity: lerpDouble(panelOpacity, other.panelOpacity, t) ??
          panelOpacity,
      borderOpacity: lerpDouble(borderOpacity, other.borderOpacity, t) ??
          borderOpacity,
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t) ?? blurSigma,
    );
  }
}

class NolioPanel extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  const NolioPanel({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final ext = NolioTheme.of(context);

    final panel = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: ext.panelOpacity),
        borderRadius: borderRadius,
        border: Border.all(
          color: Colors.white.withValues(alpha: ext.borderOpacity),
        ),
      ),
      child: child,
    );

    if (!ext.glass) return panel;

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: ext.blurSigma,
          sigmaY: ext.blurSigma,
        ),
        child: panel,
      ),
    );
  }
}

enum NolioThemeId {
  defaultTheme('default', 'Default'),
  amoled('amoled', 'Amoled (Glass)'),
  gruvbox('gruvbox', 'Gruvbox'),
  everforest('everforest', 'Everforest'),
  nord('nord', 'Nord'),
  tokyoNight('tokyo_night', 'Tokyo Night'),
  catppuccin('catppuccin', 'Catppuccin'),
  ;

  final String id;
  final String label;
  const NolioThemeId(this.id, this.label);

  static NolioThemeId fromId(String id) {
    return NolioThemeId.values.firstWhere(
      (v) => v.id == id,
      orElse: () => NolioThemeId.defaultTheme,
    );
  }
}

class NolioThemes {
  static ThemeData build({
    required NolioThemeId themeId,
    required Color defaultAccent,
  }) {
    switch (themeId) {
      case NolioThemeId.defaultTheme:
        return _default(defaultAccent);
      case NolioThemeId.amoled:
        return _amoled();
      case NolioThemeId.gruvbox:
        return _fixed(
          seed: const Color(0xFFD79921),
          secondary: const Color(0xFFB8BB26),
          background: const Color(0xFF282828),
          surface: const Color(0xFF32302F),
          error: const Color(0xFFFB4934),
        );
      case NolioThemeId.everforest:
        return _fixed(
          seed: const Color(0xFFA7C080),
          secondary: const Color(0xFFDBBC7F),
          background: const Color(0xFF2D353B),
          surface: const Color(0xFF3A454A),
          error: const Color(0xFFE67E80),
        );
      case NolioThemeId.nord:
        return _fixed(
          seed: const Color(0xFF88C0D0),
          secondary: const Color(0xFF81A1C1),
          background: const Color(0xFF2E3440),
          surface: const Color(0xFF3B4252),
          error: const Color(0xFFBF616A),
        );
      case NolioThemeId.tokyoNight:
        return _fixed(
          seed: const Color(0xFF7AA2F7),
          secondary: const Color(0xFFBB9AF7),
          background: const Color(0xFF1A1B26),
          surface: const Color(0xFF24283B),
          error: const Color(0xFFF7768E),
        );
      case NolioThemeId.catppuccin:
        return _fixed(
          seed: const Color(0xFF89B4FA),
          secondary: const Color(0xFFF5C2E7),
          background: const Color(0xFF1E1E2E),
          surface: const Color(0xFF313244),
          error: const Color(0xFFF38BA8),
        );
    }
  }

  static ThemeData _fixed({
    required Color seed,
    required Color secondary,
    required Color background,
    required Color surface,
    required Color error,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ).copyWith(
      secondary: secondary,
      surface: surface,
      error: error,
      outline: Colors.white.withValues(alpha: 0.12),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      extensions: const [
        NolioTheme(
          glass: false,
          panelOpacity: 0.06,
          borderOpacity: 0.0,
          blurSigma: 24,
        ),
      ],
    );
  }

  static ThemeData _default(Color accent) {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      extensions: const [
        NolioTheme(
          glass: false,
          panelOpacity: 0.06,
          borderOpacity: 0.0,
          blurSigma: 24,
        ),
      ],
    );
  }

  static ThemeData _amoled() {
    const background = Colors.black;
    const surface = Color(0xFF0B0B0D);
    const primary = Color(0xFF1DB954);
    const secondary = Color(0xFF4CC38A);
    const error = Color(0xFFFB4934);

    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ).copyWith(
      secondary: secondary,
      surface: surface,
      error: error,
      outline: Colors.white.withValues(alpha: 0.12),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      dialogTheme: const DialogThemeData(backgroundColor: background),
      canvasColor: Colors.black,
      extensions: const [
        NolioTheme(
          glass: true,
          panelOpacity: 0.06,
          borderOpacity: 0.14,
          blurSigma: 26,
        ),
      ],
    );
  }
}
