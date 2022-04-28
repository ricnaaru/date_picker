part of date_picker;

class DatePickerTheme {
  final String dateFormat;
  final Color todayColor;
  final Color selectedColor;
  final Color iconColor;
  final IconData iconPrevious;
  final IconData iconNext;
  final Color toolbarColor;
  final Color prevDaysColor;
  final Color nextDaysColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color hintColor;
  final Color labelColor;
  final Color errorColor;
  final List<String> weekdaysArray;
  final List<String> monthsArray;
  final String markedDatesTitle;
  final TextStyle headerTextStyle;
  final TextStyle weekdayTextStyle;
  final TextStyle todayTextStyle;
  final TextStyle selectedDayTextStyle;
  final TextStyle daysLabelTextStyle;
  final TextStyle markedDaysTextStyle;
  final TextStyle weekendTextStyle;
  final Widget markedDateWidget;
  final double viewportFraction;
  final Color prevMonthDayBorderColor;
  final Color thisMonthDayBorderColor;
  final Color nextMonthDayBorderColor;
  final double dayPadding;
  final Color dayButtonColor;
  final bool daysHaveCircularBorder;
  final EdgeInsets headerMargin;
  final double childAspectRatio;
  final EdgeInsets weekDayMargin;

  const DatePickerTheme({
    this.dateFormat = "dd-MM-yyyy",
    this.daysLabelTextStyle = const TextStyle(color: Color(0xff208e5d)),
    this.todayTextStyle = const TextStyle(color: Colors.black),
    this.todayColor = const Color(0xffe0ab00),
    this.selectedColor = Colors.blue,
    this.selectedDayTextStyle = const TextStyle(color: Color(0xffffffff)),
    this.iconColor = Colors.blueAccent,
    this.iconPrevious = Icons.keyboard_arrow_left,
    this.iconNext = Icons.keyboard_arrow_right,
    this.weekendTextStyle = const TextStyle(color: Color(0xffff235e)),
    this.weekdayTextStyle = const TextStyle(color: Color(0xff44363a)),
    this.toolbarColor = const Color(0xfff4329a),
    this.headerTextStyle =
        const TextStyle(fontSize: 20, color: Color(0xff505357)),
    this.prevDaysColor = const Color(0xffa6a6a6),
    this.nextDaysColor = const Color(0xffa6a6a6),
    this.markedDaysTextStyle = const TextStyle(color: Color(0xff5f9ac8)),
    this.markedDateWidget = const Positioned.fill(
      child: Center(
        child: SizedBox(
          height: 32,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 4,
              width: 4,
              child: Material(
                color: Colors.orange,
              ),
            ),
          ),
        ),
      ),
    ),
    this.backgroundColor = const Color(0xffffffff),
    this.borderColor = const Color(0xffa6a6a6),
    this.hintColor = const Color(0xffa6a6a6),
    this.labelColor = const Color(0xff777777),
    this.errorColor = const Color(0xffd81920),
    this.weekdaysArray = const [
      "Sun",
      "Mon",
      "Tue",
      "Wed",
      "Thur",
      "Fri",
      "Sat"
    ],
    this.monthsArray = const [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ],
    this.markedDatesTitle = "Marked date",
    this.viewportFraction = 1.0,
    this.prevMonthDayBorderColor = Colors.transparent,
    this.thisMonthDayBorderColor = Colors.transparent,
    this.nextMonthDayBorderColor = Colors.transparent,
    this.dayPadding = 2.0,
    this.dayButtonColor = Colors.transparent,
    this.daysHaveCircularBorder = true,
    this.headerMargin = const EdgeInsets.symmetric(vertical: 16.0),
    this.childAspectRatio = 1.0,
    this.weekDayMargin = const EdgeInsets.only(bottom: 4.0),
  });

  DatePickerTheme copyWith({
    String? dateFormat,
    TextStyle? daysLabelTextStyle,
    Color? todayColor,
    Color? selectedColor,
    TextStyle? selectedDayTextStyle,
    Color? iconColor,
    IconData? iconPrevious,
    IconData? iconNext,
    TextStyle? weekendTextStyle,
    TextStyle? weekdayTextStyle,
    TextStyle? todayTextStyle,
    Color? toolbarColor,
    TextStyle? headerTextStyle,
    Color? prevDaysColor,
    Color? nextDaysColor,
    TextStyle? markedDaysTextStyle,
    Color? backgroundColor,
    Color? borderColor,
    Color? hintColor,
    Color? labelColor,
    Color? errorColor,
    List<String>? weekdaysArray,
    List<String>? monthsArray,
    String? markedDatesTitle,
    Widget? markedDateWidget,
    double? viewportFraction,
    Color? prevMonthDayBorderColor,
    Color? thisMonthDayBorderColor,
    Color? nextMonthDayBorderColor,
    double? dayPadding,
    Color? dayButtonColor,
    bool? daysHaveCircularBorder,
    EdgeInsets? headerMargin,
    double? childAspectRatio,
    EdgeInsets? weekDayMargin,
  }) {
    return DatePickerTheme(
      dateFormat: dateFormat ?? this.dateFormat,
      daysLabelTextStyle: daysLabelTextStyle ?? this.daysLabelTextStyle,
      todayTextStyle: todayTextStyle ?? this.todayTextStyle,
      todayColor: todayColor ?? this.todayColor,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedDayTextStyle: selectedDayTextStyle ?? this.selectedDayTextStyle,
      iconColor: iconColor ?? this.iconColor,
      iconPrevious: iconPrevious ?? this.iconPrevious,
      iconNext: iconNext ?? this.iconNext,
      weekendTextStyle: weekendTextStyle ?? this.weekendTextStyle,
      weekdayTextStyle: weekdayTextStyle ?? this.weekdayTextStyle,
      toolbarColor: toolbarColor ?? this.toolbarColor,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      prevDaysColor: prevDaysColor ?? this.prevDaysColor,
      nextDaysColor: nextDaysColor ?? this.nextDaysColor,
      markedDaysTextStyle: markedDaysTextStyle ?? this.markedDaysTextStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      hintColor: hintColor ?? this.hintColor,
      labelColor: labelColor ?? this.labelColor,
      errorColor: errorColor ?? this.errorColor,
      weekdaysArray: weekdaysArray ?? this.weekdaysArray,
      monthsArray: monthsArray ?? this.monthsArray,
      markedDatesTitle: markedDatesTitle ?? this.markedDatesTitle,
      markedDateWidget: markedDateWidget ?? this.markedDateWidget,
      viewportFraction: viewportFraction ?? this.viewportFraction,
      prevMonthDayBorderColor:
          prevMonthDayBorderColor ?? this.prevMonthDayBorderColor,
      thisMonthDayBorderColor:
          thisMonthDayBorderColor ?? this.thisMonthDayBorderColor,
      nextMonthDayBorderColor:
          nextMonthDayBorderColor ?? this.nextMonthDayBorderColor,
      dayPadding: dayPadding ?? this.dayPadding,
      dayButtonColor: dayButtonColor ?? this.dayButtonColor,
      daysHaveCircularBorder:
          daysHaveCircularBorder ?? this.daysHaveCircularBorder,
      headerMargin: headerMargin ?? this.headerMargin,
      childAspectRatio: childAspectRatio ?? this.childAspectRatio,
      weekDayMargin: weekDayMargin ?? this.weekDayMargin,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! DatePickerTheme) return false;
    return (other.dateFormat == dateFormat) &&
        (other.daysLabelTextStyle == daysLabelTextStyle) &&
        (other.todayTextStyle == todayTextStyle) &&
        (other.todayColor == todayColor) &&
        (other.selectedColor == selectedColor) &&
        (other.selectedDayTextStyle == selectedDayTextStyle) &&
        (other.iconColor == iconColor) &&
        (other.iconPrevious == iconPrevious) &&
        (other.iconNext == iconNext) &&
        (other.weekendTextStyle == weekendTextStyle) &&
        (other.weekdayTextStyle == weekdayTextStyle) &&
        (other.toolbarColor == toolbarColor) &&
        (other.headerTextStyle == headerTextStyle) &&
        (other.prevDaysColor == prevDaysColor) &&
        (other.nextDaysColor == nextDaysColor) &&
        (other.markedDaysTextStyle == markedDaysTextStyle) &&
        (other.backgroundColor == backgroundColor) &&
        (other.borderColor == borderColor) &&
        (other.hintColor == hintColor) &&
        (other.labelColor == labelColor) &&
        (other.errorColor == errorColor) &&
        (other.weekdaysArray == weekdaysArray) &&
        (other.monthsArray == monthsArray) &&
        (other.markedDatesTitle == markedDatesTitle) &&
        (other.markedDateWidget == markedDateWidget) &&
        (other.viewportFraction == viewportFraction) &&
        (other.prevMonthDayBorderColor == prevMonthDayBorderColor) &&
        (other.thisMonthDayBorderColor == thisMonthDayBorderColor) &&
        (other.nextMonthDayBorderColor == nextMonthDayBorderColor) &&
        (other.dayPadding == dayPadding) &&
        (other.dayButtonColor == dayButtonColor) &&
        (other.daysHaveCircularBorder == daysHaveCircularBorder) &&
        (other.headerMargin == headerMargin) &&
        (other.childAspectRatio == childAspectRatio) &&
        (other.weekDayMargin == weekDayMargin);
  }

  @override
  int get hashCode {
    final values = <Object>[
      dateFormat.hashCode,
      daysLabelTextStyle.hashCode,
      todayTextStyle.hashCode,
      todayColor.hashCode,
      selectedColor.hashCode,
      selectedDayTextStyle.hashCode,
      iconColor.hashCode,
      iconPrevious.hashCode,
      iconNext.hashCode,
      weekendTextStyle.hashCode,
      weekdayTextStyle.hashCode,
      toolbarColor.hashCode,
      headerTextStyle.hashCode,
      prevDaysColor.hashCode,
      nextDaysColor.hashCode,
      markedDaysTextStyle.hashCode,
      backgroundColor.hashCode,
      borderColor.hashCode,
      hintColor.hashCode,
      labelColor.hashCode,
      errorColor.hashCode,
      weekdaysArray.hashCode,
      monthsArray.hashCode,
      markedDatesTitle.hashCode,
      markedDateWidget.hashCode,
      viewportFraction.hashCode,
      prevMonthDayBorderColor.hashCode,
      thisMonthDayBorderColor.hashCode,
      nextMonthDayBorderColor.hashCode,
      dayPadding.hashCode,
      dayButtonColor.hashCode,
      daysHaveCircularBorder.hashCode,
      headerMargin.hashCode,
      childAspectRatio.hashCode,
      weekDayMargin.hashCode,
    ];
    return hashList(values);
  }
}
