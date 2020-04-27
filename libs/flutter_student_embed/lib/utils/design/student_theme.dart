// Copyright (C) 2019 - present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter_student_embed/utils/NativeComm.dart';
import 'package:flutter_student_embed/utils/design/student_colors.dart';
import 'package:provider/provider.dart';

/// Provides Parent App [ThemeData] to the 'builder' callback. This theme data is styled to account for dark mode,
/// high-contrast mode, and a selectable student color set. This widget is designed to directly wrap (or be a nearby
/// ancestor of) the 'MaterialApp' widget which should consume the provided 'themeData' object.
///
/// Mapping of design text style names to Flutter text style names:
///
///   Design name:    Flutter name:  Size:  Weight:
///   ---------------------------------------------------
///   caption    ->   subtitle       12     Medium (500) - faded
///   subhead    ->   overline       12     Bold (700) - faded
///   body       ->   body1          14     Regular (400)
///   subtitle   ->   caption        14     Medium (500) - faded
///   title      ->   subhead        16     Medium (500)
///   heading    ->   headline       18     Medium (500)
///   display    ->   display1       24     Medium (500)
///
class StudentTheme extends StatefulWidget {
  final Widget Function(BuildContext context, ThemeData themeData) builder;

  const StudentTheme({Key key, this.builder}) : super(key: key);

  @override
  _StudentThemeState createState() => _StudentThemeState();

  static _StudentThemeState of(BuildContext context) {
    return context.findAncestorStateOfType<_StudentThemeState>();
  }
}

/// State for the [StudentTheme] widget. Holds state for dark mode, high contrast mode, and the dynamically set
/// student color. To obtain an instance of this state, call 'ParentTheme.of(context)' with any context that
/// descends from a ParentTheme widget.
class _StudentThemeState extends State<StudentTheme> {
  ParentThemeStateChangeNotifier _notifier = ParentThemeStateChangeNotifier();

  @override
  void initState() {
    NativeComm.onThemeUpdated = () => setState(() {});
    super.initState();
  }

  /// Returns a theme with the institution colors
  ThemeData get defaultTheme => _buildTheme(StudentColors.primaryColor, StudentColors.buttonColor);

  ThemeData getCanvasContextTheme(String contextCode) {
    return _buildTheme(getCanvasContextColor(contextCode), StudentColors.buttonColor);
  }

  Color getCanvasContextColor(String contextCode) {
    if (contextCode == null || contextCode.isEmpty || contextCode.startsWith('user')) {
      return StudentColors.primaryColor;
    } else {
      return StudentColors.contextColors[contextCode] ?? StudentColors.generateContextColor(contextCode);
    }
  }

  /// Create a preferred size divider that can be used as the bottom of an app bar
  PreferredSize _appBarDivider(Color color) => PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: color),
      );

  /// Returns a light divider if in dark mode, otherwise a light divider that changes color with HC mode
  PreferredSize get _appBarDividerThemed => _appBarDivider(StudentColors.appBarDividerLight);

  /// Returns a light divider if in dark mode, dark divider in light mode unless shadowInLightMode is true, wrapping the optional bottom passed in
  PreferredSizeWidget appBarDivider({PreferredSizeWidget bottom, bool shadowInLightMode = true}) => (!shadowInLightMode)
      ? PreferredSize(
          preferredSize: Size.fromHeight(1.0 + (bottom?.preferredSize?.height ?? 0)), // Bottom height plus divider
          child: Column(
            children: [
              if (bottom != null) bottom,
              _appBarDividerThemed,
            ],
          ),
        )
      : bottom;

  /// Returns a widget wrapping a divider on top of the passed in bottom
  Widget bottomNavigationDivider(Widget bottom) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _appBarDividerThemed,
          bottom,
        ],
      );

  @override
  void setState(fn) {
    super.setState(fn);
    _notifier.notify();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ParentThemeStateChangeNotifier>.value(
      value: _notifier,
      child: widget.builder(context, defaultTheme),
    );
  }

  /// Color for text, icons, etc that contrasts sharply with the scaffold (i.e. surface) color
  Color get onSurfaceColor => StudentColors.licorice;

  /// Color similar to the surface color but is slightly darker in light mode and slightly lighter in dark mode.
  /// This should be used elements that should be visually distinguishable from the surface color but must also contrast
  /// sharply with the [onSurfaceColor]. Examples are chip backgrounds, progressbar backgrounds, avatar backgrounds, etc.
  Color get nearSurfaceColor => StudentColors.porcelain;

  ThemeData _buildTheme(Color primaryColor, Color buttonColor) {
    var textTheme = _buildTextTheme(onSurfaceColor);

    var swatch = StudentColors.makeSwatch(primaryColor);
    return ThemeData(
        brightness: Brightness.light,
        primarySwatch: swatch,
        accentColor: swatch[500],
        toggleableActiveColor: swatch[500],
        textSelectionHandleColor: swatch[300],
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.white,
        accentColorBrightness: Brightness.dark,
        textTheme: textTheme,
        primaryTextTheme: _buildTextTheme(Colors.white, fadeColor: Colors.white70),
        accentTextTheme: _buildTextTheme(Colors.white, fadeColor: Colors.white70),
        iconTheme: IconThemeData(color: onSurfaceColor),
        primaryIconTheme: IconThemeData(color: Colors.white),
        accentIconTheme: IconThemeData(color: Colors.white),
        dividerColor: StudentColors.tiara,
        buttonColor: buttonColor,
        buttonTheme: ButtonThemeData(height: 48, minWidth: 120, buttonColor: buttonColor),
        pageTransitionsTheme: PageTransitionsTheme(builders: {TargetPlatform.android: _PopTransitionsBuilder()}));
  }

  TextTheme _buildTextTheme(Color color, {Color fadeColor = StudentColors.ash}) {
    return TextTheme(
      /// Design-provided styles

      // Comments for each text style represent the nomenclature of the designs we have
      // Caption
      subtitle: TextStyle(color: fadeColor, fontSize: 12, fontWeight: FontWeight.w500),

      // Subhead
      overline: TextStyle(color: fadeColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0),

      // Body
      body1: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.normal),

      // Subtitle
      caption: TextStyle(color: fadeColor, fontSize: 14, fontWeight: FontWeight.w500),

      // Title
      subhead: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w500),

      // Heading
      headline: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w500),

      // Display
      display1: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w500),

      /// Other/unmapped styles

      title: TextStyle(color: color),

      display4: TextStyle(color: fadeColor),

      display3: TextStyle(color: fadeColor),

      display2: TextStyle(color: fadeColor),

      body2: TextStyle(color: color),

      button: TextStyle(color: color),
    );
  }
}

/// A [ChangeNotifier] used to notify consumers when the ParentTheme state changes. Ideally the state itself would
/// be a [ChangeNotifier] so we wouldn't need this extra class, but there is currently a mixin-related limitation
/// that prevents the state's dispose method from being called: https://github.com/flutter/flutter/issues/24293
class ParentThemeStateChangeNotifier with ChangeNotifier {
  notify() => notifyListeners(); // notifyListeners is protected, so we expose it through another method
}

/// Applies a theme to descendant widgets using the color associated with the specified canvas context
class CanvasContextTheme extends StatelessWidget {
  final WidgetBuilder builder;
  final bool useNonPrimaryAppBar;
  final String contextCode;

  const CanvasContextTheme({
    Key key,
    @required this.contextCode,
    @required this.builder,
    this.useNonPrimaryAppBar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = StudentTheme.of(context).getCanvasContextTheme(contextCode);
    if (useNonPrimaryAppBar) theme = theme.copyWith(appBarTheme: _scaffoldColoredAppBarTheme(context));

    return Consumer<ParentThemeStateChangeNotifier>(
      builder: (context, state, _) => Theme(
        child: Builder(builder: builder),
        data: theme,
      ),
    );
  }

  AppBarTheme _scaffoldColoredAppBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return AppBarTheme(
      color: theme.scaffoldBackgroundColor,
      textTheme: theme.textTheme,
      iconTheme: theme.iconTheme,
      elevation: 0,
    );
  }
}

/// A [PageTransitionsBuilder] that does not use animations
class _PopTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
