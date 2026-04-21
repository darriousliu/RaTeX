// ratex.dart — Public API for the ratex_flutter package.
//
// Usage:
//   import 'package:ratex_flutter/ratex.dart';
//
//   Widget build(BuildContext context) => RaTeXWidget(
//     latex: r'\frac{-b \pm \sqrt{b^2-4ac}}{2a}',
//     fontSize: 24,
//   );

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'src/display_list.dart';
import 'src/ratex_ffi.dart';
import 'src/ratex_painter.dart';

export 'src/display_list.dart';
export 'src/ratex_ffi.dart' show RaTeXException;

RaTeXColor _toRaTeXColor(Color color) => RaTeXColor(
  color.red / 255,
  color.green / 255,
  color.blue / 255,
  color.alpha / 255,
);

// MARK: - Engine

/// High-level entry point for RaTeX rendering.
class RaTeXEngine {
  static final RaTeXEngine instance = RaTeXEngine._();
  RaTeXEngine._();

  final _ffi = RaTeXFfi();

  /// Parse and lay out [latex], returning a [DisplayList].
  ///
  /// [displayMode] — `true` (default) for display/block style (`$$...$$`);
  /// `false` for inline/text style (`$...$`).
  /// [color] sets the default formula color; explicit LaTeX colors still take precedence.
  ///
  /// This is a synchronous, CPU-bound call. For long formulas, use [compute]
  /// with [ratexParseAndLayoutInIsolate]:
  /// ```dart
  /// final dl = await compute(
  ///   ratexParseAndLayoutInIsolate,
  ///   (latex: tex, displayMode: true, colorValue: const Color(0xFF000000).value),
  /// );
  /// ```
  DisplayList parseAndLayout(
    String latex, {
    bool displayMode = true,
    Color color = const Color(0xFF000000),
  }) => _ffi.parseAndLayout(
    latex,
    displayMode: displayMode,
    color: _toRaTeXColor(color),
  );
}

/// Arguments for [ratexParseAndLayoutInIsolate] (e.g. pass to [compute]).
typedef RaTeXParseAndLayoutArgs = ({
  String latex,
  bool displayMode,
  int colorValue,
});

/// Top-level isolate entry for [compute]; calls [RaTeXEngine.parseAndLayout].
DisplayList ratexParseAndLayoutInIsolate(RaTeXParseAndLayoutArgs args) =>
    RaTeXEngine.instance.parseAndLayout(
      args.latex,
      displayMode: args.displayMode,
      color: Color(args.colorValue),
    );

// MARK: - Stateful widget

/// A Flutter widget that renders a LaTeX math formula natively.
///
/// ```dart
/// RaTeXWidget(
///   latex: r'\int_0^\infty e^{-x^2}\,dx = \frac{\sqrt{\pi}}{2}',
///   fontSize: 24,
/// )
/// ```
class RaTeXWidget extends StatefulWidget {
  /// The LaTeX math-mode string to render.
  final String latex;

  /// Font size in logical pixels.
  final double fontSize;

  /// `true` (default) — display/block style; `false` — inline/text style.
  final bool displayMode;

  /// Default formula color. Explicit LaTeX colors still take precedence.
  final Color? color;

  /// Widget displayed while the formula is being computed.
  final Widget? loading;

  /// Called when a render error occurs.
  final void Function(RaTeXException)? onError;

  const RaTeXWidget({
    super.key,
    required this.latex,
    this.fontSize = 24,
    this.displayMode = true,
    this.color,
    this.loading,
    this.onError,
  });

  @override
  State<RaTeXWidget> createState() => _RaTeXWidgetState();
}

class _RaTeXWidgetState extends State<RaTeXWidget> {
  DisplayList? _displayList;
  RaTeXException? _error;
  Color? _lastInheritedColor;

  @override
  void initState() {
    super.initState();
    if (widget.color != null) {
      _render();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.color != null) {
      _lastInheritedColor = null;
      return;
    }

    final inheritedColor = _inheritedColor;
    if (_lastInheritedColor != inheritedColor) {
      _lastInheritedColor = inheritedColor;
      _render();
    }
  }

  @override
  void didUpdateWidget(RaTeXWidget old) {
    super.didUpdateWidget(old);
    if (old.latex != widget.latex ||
        old.fontSize != widget.fontSize ||
        old.displayMode != widget.displayMode ||
        old.color != widget.color) {
      _lastInheritedColor = widget.color == null ? _inheritedColor : null;
      _render();
    }
  }

  Color get _inheritedColor =>
      DefaultTextStyle.of(context).style.color ?? Colors.black;

  Future<void> _render() async {
    try {
      final resolvedColor = widget.color ?? _inheritedColor;
      final dl = await compute(
        ratexParseAndLayoutInIsolate,
        (
          latex: widget.latex,
          displayMode: widget.displayMode,
          colorValue: resolvedColor.value,
        ),
      );
      if (mounted) setState(() { _displayList = dl; _error = null; });
    } on RaTeXException catch (e) {
      widget.onError?.call(e);
      if (mounted) setState(() { _error = e; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Text('RaTeX error: ${_error!.message}',
          style: const TextStyle(color: Colors.red, fontSize: 12));
    }
    final dl = _displayList;
    if (dl == null) {
      return widget.loading ?? const SizedBox.shrink();
    }
    final painter = RaTeXPainter(displayList: dl, fontSize: widget.fontSize);
    return SizedBox(
      width:  painter.widthPx,
      height: painter.totalHeightPx,
      child:  CustomPaint(painter: painter),
    );
  }
}
