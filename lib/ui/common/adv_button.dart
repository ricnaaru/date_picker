import 'package:flutter/material.dart';

enum ButtonSize { small, large }

const _kDoubleTapPreventionDuration = Duration(milliseconds: 300);

class AdvButton extends StatefulWidget {
  final String? text;
  final Widget? child;
  final bool _bold;
  final bool enable;
  final VoidCallback? onPressed;
  final double circular;
  final ButtonSize buttonSize;
  final bool onlyBorder;
  final bool reverse;
  final Color primaryColor;
  final Color accentColor;
  final double? width;
  final double borderWidth;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool dismissKeyboardOnPressed;

  const AdvButton._({
    this.text,
    this.child,
    double? circular,
    bool? bold,
    bool? enable,
    bool? onlyBorder,
    bool? reverse,
    this.onPressed,
    ButtonSize? buttonSize,
    Color? primaryColor,
    Color? accentColor,
    this.width,
    double? borderWidth,
    this.padding,
    this.margin,
    bool? dismissKeyboardOnPressed,
  })  : buttonSize = buttonSize ?? ButtonSize.small,
        enable = enable ?? true,
        _bold = bold ?? false,
        circular = circular ?? 12,
        onlyBorder = onlyBorder ?? false,
        reverse = reverse ?? false,
        primaryColor = primaryColor ?? Colors.blue,
        accentColor = accentColor ?? Colors.white,
        borderWidth = borderWidth ?? 2,
        dismissKeyboardOnPressed = dismissKeyboardOnPressed ?? true;

  factory AdvButton.text(
    String text, {
    double circular = 12,
    bool enable = true,
    bool onlyBorder = false,
    bool reverse = false,
    bool bold = false,
    VoidCallback? onPressed,
    ButtonSize? buttonSize,
    Color? backgroundColor,
    Color? textColor,
    double? width,
    double? borderWidth,
    EdgeInsets? padding,
    EdgeInsets? margin,
    bool? dismissKeyboardOnPressed,
  }) {
    return AdvButton._(
      text: text,
      circular: circular,
      enable: enable,
      bold: bold,
      onlyBorder: onlyBorder,
      reverse: reverse,
      onPressed: onPressed,
      buttonSize: buttonSize,
      primaryColor: backgroundColor,
      accentColor: textColor,
      width: width,
      borderWidth: borderWidth,
      padding: padding,
      margin: margin,
      dismissKeyboardOnPressed: dismissKeyboardOnPressed ?? true,
    );
  }

  factory AdvButton.custom({
    required Widget child,
    double? circular,
    bool? enable,
    bool? onlyBorder,
    bool? reverse,
    bool? bold,
    VoidCallback? onPressed,
    ButtonSize? buttonSize,
    Color? primaryColor,
    Color? accentColor,
    double? width,
    double? borderWidth,
    EdgeInsets? padding,
    EdgeInsets? margin,
    bool? dismissKeyboardOnPressed,
  }) {
    return AdvButton._(
      child: child,
      circular: circular,
      enable: enable,
      onlyBorder: onlyBorder,
      reverse: reverse,
      onPressed: onPressed,
      buttonSize: buttonSize,
      primaryColor: primaryColor,
      accentColor: accentColor,
      width: width,
      borderWidth: borderWidth,
      padding: padding,
      margin: margin,
      dismissKeyboardOnPressed: dismissKeyboardOnPressed,
    );
  }

  @override
  _AdvButtonState createState() => _AdvButtonState();
}

class _AdvButtonState extends State<AdvButton> {
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    final _primaryColor =
        !widget.reverse ? widget.primaryColor : widget.accentColor;

    final _accentColor =
        !widget.reverse ? widget.accentColor : widget.primaryColor;

    final _borderWidth = widget.onlyBorder ? (widget.borderWidth) : 0.0;
    final disableBackgroundColor = Color.lerp(
      widget.reverse ? Colors.white : Colors.black54,
      Colors.grey,
      0.6,
    )!;

    final border = RoundedRectangleBorder(
      side: BorderSide(
        color: widget.enable ? _primaryColor : disableBackgroundColor,
        width: _borderWidth,
      ),
      borderRadius: BorderRadius.circular(widget.circular),
    );

    final _color = widget.onlyBorder ? _accentColor : _primaryColor;

    final finalPadding = widget.padding ??
        (widget.buttonSize == ButtonSize.large
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 8));

    var _child = widget.child;

    if (widget.child == null) {
      final fontSize = widget.buttonSize == ButtonSize.large ? 18.0 : 14.0;
      final fontWeight = widget._bold ? FontWeight.w700 : FontWeight.w500;
      // Color disableTextColor = Color.lerp(
      //     !reverse ? Colors.white : Colors.black54, Palette.borderColor, 0.6);
      const disableTextColor = Colors.white;
      final disableBackgroundColor = Color.lerp(
        widget.reverse ? Colors.white : Colors.black54,
        Colors.grey,
        0.6,
      )!;
      final _textColor = !widget.onlyBorder ? _accentColor : _primaryColor;
      final _disableTextColor =
          !widget.onlyBorder ? disableTextColor : disableBackgroundColor;
      final textStyle = TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: widget.enable ? _textColor : _disableTextColor);

      _child = Text(
        widget.text!,
        style: textStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    // NoSplash.splashFactory;
    return Container(
      margin: widget.margin,
      width: widget.width,
      child: TextButton(
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: MaterialStateProperty.all(border),
          padding: MaterialStateProperty.all(finalPadding),
          splashFactory: InkSplash.splashFactory,
          backgroundColor: MaterialStateProperty.all(_color),
          // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          // color: _color,
          // disabledColor: _disableColor,
          // disabledTextColor: _disableTextColor,
          // highlightColor: Palette.borderColor.withOpacity(.1),
          // splashColor: Palette.borderColor.withOpacity(.2),
        ),
        child: _child!,
        onPressed: widget.enable
            ? () {
                if (_working) {
                  return;
                }

                _working = true;
                Future.delayed(
                  _kDoubleTapPreventionDuration,
                ).then((value) => _working = false);

                if (widget.dismissKeyboardOnPressed) {
                  FocusScope.of(context).requestFocus(FocusNode());
                }

                if (widget.onPressed != null) widget.onPressed!();
              }
            : null,
      ),
    );
  }
}
