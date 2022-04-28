library date_picker;

import 'dart:ui' as ui;

import 'package:date_picker/extensions/build_context.dart';
import 'package:date_picker/extensions/int.dart';
import 'package:date_picker/ui/common/adv_button.dart';
import 'package:date_picker/ui/common/adv_column.dart';
import 'package:date_picker/ui/common/adv_row.dart';
import 'package:date_picker/ui/common/adv_scaffold.dart';
import 'package:date_picker/ui/common/adv_visibility.dart';
import 'package:date_picker/ui/marked_date.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart' show DateFormat;

part 'src/calendar_carousel.dart';

part 'src/calendar_day.dart';

part 'src/calendar_month.dart';

part 'src/calendar_page.dart';

part 'src/calendar_theme.dart';

part 'src/calendar_year.dart';

part 'src/controller.dart';

typedef DateResultInterpreter = String Function(List<DateTime> dates);

class DatePicker extends StatefulWidget {
  final DateTime? date;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool? enabled;
  final List<MarkedDate>? markedDates;
  final SelectionType selectionType;
  final PickType pickType;
  final String? dateFormat;
  final DateResultInterpreter? interpreter;
  final List<DateTime>? dates;
  final ApDatePickerController? controller;
  final String? hint;
  final String? label;
  final EdgeInsets? margin;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final ValueChanged<List<DateTime>>? onChanged;

  DatePicker({
    Key? key,
    this.date,
    this.minDate,
    this.maxDate,
    this.markedDates,
    this.selectionType = SelectionType.single,
    this.pickType = PickType.day,
    this.dateFormat,
    this.interpreter,
    this.dates,
    this.controller,
    this.hint,
    this.label,
    this.margin,
    this.style,
    this.textAlign = TextAlign.start,
    this.textDirection = TextDirection.ltr,
    this.onChanged,
    this.enabled,
  })  : assert(controller == null ||
            (date == null &&
                minDate == null &&
                maxDate == null &&
                dates == null &&
                enabled == null)),
        assert((minDate != null &&
                maxDate != null &&
                minDate.compareTo(maxDate) <= 0) ||
            !(minDate != null && maxDate != null)),
        super(key: key);

  @override
  _DatePickerState createState() => _DatePickerState();

  static Future<List<DateTime>?> pickDate(
    BuildContext context, {
    String? title,
    List<DateTime>? dates,
    List<MarkedDate>? markedDates,
    SelectionType? selectionType,
    PickType? pickType,
    DateTime? minDate,
    DateTime? maxDate,
  }) async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        fullscreenDialog: true,
        pageBuilder: (context, animation1, animation2) {
          return CalendarPage(
            title: title,
            currentDate: dates ?? const <DateTime>[],
            markedDates: markedDates ?? const <MarkedDate>[],
            pickType: pickType ?? PickType.day,
            selectionType: selectionType ?? SelectionType.single,
            minDate: minDate,
            maxDate: maxDate,
          );
        },
        transitionsBuilder: (context, animation1, animation2, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(animation1),
            child: child,
          );
        },
        settings: const RouteSettings(name: 'ComDatePickerPage'),
      ),
    );

    return result;
  }
}

class _DatePickerState extends State<DatePicker> {
  ApDatePickerController? get _effectiveController =>
      widget.controller ?? _ctrl;

  ApDatePickerController? _ctrl;

  @override
  void initState() {
    super.initState();

    _ctrl = widget.controller == null
        ? ApDatePickerController(
            date: widget.date,
            minDate: widget.minDate,
            maxDate: widget.maxDate,
            dates: widget.dates,
            enabled: widget.enabled ?? true,
          )
        : null;

    _effectiveController?.addListener(_update);
  }

  _update() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(DatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller == null && oldWidget.controller != null)
      _ctrl = ApDatePickerController.fromValue(oldWidget.controller?.value);
    else if (widget.controller != null && oldWidget.controller == null)
      _ctrl = null;
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat(widget.dateFormat ?? 'dd/MM/yyyy');

    final textEditingCtrl = TextEditingController(
        text: _effectiveController?.date == null
            ? ''
            : widget.interpreter != null
                ? widget.interpreter!(_effectiveController?.dates ?? [])
                : df.format(_effectiveController!.date!));

    final suffixChildren = <Widget>[];

    suffixChildren.add(
      AbsorbPointer(
        absorbing: true,
        child: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          icon: const Icon(Icons.remove_red_eye),
          onPressed: () {},
          color: Colors.transparent,
        ),
      ),
    );

    final decoration = InputDecoration(
      isDense: false,

      /// Because of Flutter's rule that suffix / prefix icon has to be at least 48px
      /// that means, Icon that inside Icon Button has already centered and got its own padding
      /// there's no need for padding anymore
      /// however, if the Obscure Text Icon + the suffix icon, that would make those more than 48px
      /// which is why it will require padding on the left / on the right of the textfield
      contentPadding: const EdgeInsets.only(left: 12, right: 0),
      errorText: widget.controller?.error,
      fillColor: Colors.white,
      filled: true,
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      hintText: widget.hint,
      disabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      suffixIcon: suffixChildren.isEmpty
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: suffixChildren,
            ),
    );

    final Widget textField = AbsorbPointer(
      absorbing: true,
      child: TextField(
        key: widget.key,
        controller: textEditingCtrl,
        decoration: decoration,
        style: widget.style,
        strutStyle: const StrutStyle(height: 1.4),
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        readOnly: true,
        obscureText: _effectiveController?.obscureText ?? false,
        enabled: _effectiveController?.enabled,
      ),
    );

    final margin = widget.margin ?? EdgeInsets.zero;

    return Container(
      margin: margin.copyWith(
          bottom:
              (margin.bottom) + (widget.controller?.error == null ? 33 : 8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8)
                  .copyWith(bottom: 6),
              child: Text(widget.label!),
            ),
          GestureDetector(
            onTap: _onTap,
            child: Stack(
              children: [
                textField,
                Positioned(
                  right: 0,
                  child: AbsorbPointer(
                    absorbing: true,
                    child: IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      icon: Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Colors.grey.shade700,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onTap() async {
    if (_effectiveController == null || !_effectiveController!.enabled) return;

    context.dismissFocus();

    final dates = await DatePicker.pickDate(
      context,
      title: widget.label ?? 'Pick Date',
      dates: _effectiveController!.dates,
      pickType: widget.pickType,
      selectionType: widget.selectionType,
      minDate: _effectiveController!.minDate,
      maxDate: _effectiveController!.maxDate,
      markedDates: widget.markedDates,
    );

    if (dates == null) return;

    _effectiveController!.error = null;
    _effectiveController!.dates = dates;
    _effectiveController!.date = dates.first;

    if (widget.onChanged != null) widget.onChanged!(dates);
  }
}
