import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

extension BuildContextExtension on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  void dismissFocus() {
    final currentFocus = FocusScope.of(this);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  void pop<T extends Object?>([T? result]) {
    return Navigator.pop<T>(this, result);
  }

  Future<T?> push<T extends Object?>(Widget page) {
    return Navigator.push<T>(
      this,
      MaterialPageRoute(
        settings: RouteSettings(name: "$page"),
        builder: (BuildContext context) {
          return page;
        },
      ),
    );
  }

  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    Widget page, [
    TO? result,
  ]) {
    return Navigator.pushReplacement<T, TO>(
      this,
      MaterialPageRoute(
        settings: RouteSettings(name: "$page"),
        builder: (BuildContext context) {
          return page;
        },
      ),
      result: result,
    );
  }

  Future<T?> pushAndRemoveUntil<T extends Object?>(
    Widget page,
    bool Function(Route) predicate,
  ) {
    return Navigator.pushAndRemoveUntil<T>(
      this,
      MaterialPageRoute(
        settings: RouteSettings(name: "$page"),
        builder: (BuildContext context) {
          return page;
        },
      ),
      predicate,
    );
  }

  Future<void> ensureVisible() async {
    // Find the object which has the focus
    final object = findRenderObject();

    final viewport = RenderAbstractViewport.of(object);

    // If we are not working in a Scrollable, skip this routine
    if (viewport == null) {
      return;
    }

    // Get the Scrollable state (in order to retrieve its offset)
    final scrollableState = Scrollable.of(this);

    // If Scrollable is null, skip this routine
    if (scrollableState == null) {
      return;
    }

    // Get its offset
    final position = scrollableState.position;
    double alignment;

    if (position.pixels > viewport.getOffsetToReveal(object!, 0.0).offset) {
      // Move down to the top of the viewport
      alignment = 0.0;
    } else if (position.pixels <
        viewport.getOffsetToReveal(object, 1.0).offset) {
      // Move up to the bottom of the viewport
      alignment = 1.0;
    } else {
      // No scrolling is necessary to reveal the child
      return;
    }

    await position.ensureVisible(
      object,
      alignment: alignment,
      duration: const Duration(milliseconds: 100),
      curve: Curves.ease,
    );
  }
}
