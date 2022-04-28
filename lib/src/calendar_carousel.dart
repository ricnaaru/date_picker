part of date_picker;

const int _kAnimationDuration = 300;

enum PickType {
  day,
  month,
  year,
}

class CalendarCarousel extends StatefulWidget {
  final PickType pickType;
  final List<DateTime> selectedDateTimes;
  final Function(List<DateTime>)? onDayPressed;
  final List<MarkedDate> markedDates;
  final SelectionType selectionType;
  final DateTime? minDate;
  final DateTime? maxDate;

  const CalendarCarousel({
    Key? key,
    this.pickType = PickType.day,
    this.selectedDateTimes = const <DateTime>[],
    this.onDayPressed,
    Color iconColor = Colors.blueAccent,
    this.markedDates = const [],
    this.selectionType = SelectionType.single,
    this.minDate,
    this.maxDate,
  }) : super(key: key);

  @override
  _CalendarCarouselState createState() => _CalendarCarouselState();
}

class _CalendarCarouselState extends State<CalendarCarousel>
    with TickerProviderStateMixin {
  final GlobalKey<DayCalendarState> _dayKey = GlobalKey<DayCalendarState>();
  final GlobalKey<MonthCalendarState> _monthKey =
      GlobalKey<MonthCalendarState>();
  final GlobalKey<YearCalendarState> _yearKey = GlobalKey<YearCalendarState>();
  late AnimationController _dayMonthAnim;
  late AnimationController _monthYearAnim;
  int _dateCount = 0;

  @override
  void initState() {
    super.initState();
    _dateCount = widget.selectedDateTimes.length;
    _dayMonthAnim = AnimationController(
      duration: const Duration(milliseconds: _kAnimationDuration),
      vsync: this,
    );
    _monthYearAnim = AnimationController(
      duration: const Duration(milliseconds: _kAnimationDuration),
      vsync: this,
      value: 1.0,
    );
  }

  @override
  dispose() {
    _dayMonthAnim.dispose();
    _monthYearAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _selectedDateTimes = widget.selectedDateTimes
        .map(
          (DateTime dateTime) =>
              DateTime(dateTime.year, dateTime.month, dateTime.day),
        )
        .toList();
    final monthFormat = DateFormat("MMM");
    final dayFormat = DateFormat("EEE");
    final monthsArray = List<String>.filled(12, "");
    final weekdaysArray = List<String>.filled(7, "");
    final dates = <DateTime>[
      DateTime(2020, 1, 1),
      DateTime(2020, 2, 1),
      DateTime(2020, 3, 1),
      DateTime(2020, 4, 1),
      DateTime(2020, 5, 1),
      DateTime(2020, 6, 1),
      DateTime(2020, 7, 1),
      DateTime(2020, 8, 1),
      DateTime(2020, 9, 1),
      DateTime(2020, 10, 1),
      DateTime(2020, 11, 1),
      DateTime(2020, 12, 1),
      DateTime(2020, 12, 2),
      DateTime(2020, 12, 3),
      DateTime(2020, 12, 4),
      DateTime(2020, 12, 5),
      DateTime(2020, 12, 6),
      DateTime(2020, 12, 7),
    ];

    for (final date in dates) {
      weekdaysArray[date.weekday % 7] = dayFormat.format(date);
      monthsArray[date.month - 1] = monthFormat.format(date);
    }

    final theme = DatePickerTheme(
      monthsArray: monthsArray,
      weekdaysArray: weekdaysArray,
    );

    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return Stack(
          children: [
            AdvColumn(
              children: [
                Expanded(
                  child: Builder(
                    builder: (BuildContext context) {
                      final children = <Widget>[
                        YearCalendar(
                          isLandscape: orientation == Orientation.landscape,
                          mainContext: context,
                          key: _yearKey,
                          datePickerTheme: theme,
                          pickType: widget.pickType,
                          monthKey: _monthKey,
                          monthYearAnim: _monthYearAnim,
                          selectedDateTimes: _selectedDateTimes,
                          onDayPressed: widget.onDayPressed,
                          markedDates: widget.markedDates,
                          selectionType: widget.selectionType,
                          minDate: widget.minDate,
                          maxDate: widget.maxDate,
                          onDaySelected: (int dateCount) {
                            setState(() {
                              _dateCount = dateCount;
                            });
                          },
                        ),
                      ];

                      if (widget.pickType == PickType.month ||
                          widget.pickType == PickType.day) {
                        children.add(
                          MonthCalendar(
                            isLandscape: orientation == Orientation.landscape,
                            mainContext: context,
                            key: _monthKey,
                            datePickerTheme: theme,
                            pickType: widget.pickType,
                            dayKey: _dayKey,
                            yearKey: _yearKey,
                            dayMonthAnim: _dayMonthAnim,
                            monthYearAnim: _monthYearAnim,
                            selectedDateTimes: _selectedDateTimes,
                            onDayPressed: widget.onDayPressed,
                            markedDates: widget.markedDates,
                            selectionType: widget.selectionType,
                            minDate: widget.minDate,
                            maxDate: widget.maxDate,
                            onDaySelected: (int dateCount) {
                              setState(() {
                                _dateCount = dateCount;
                              });
                            },
                          ),
                        );
                      }

                      if (widget.pickType == PickType.day) {
                        children.add(
                          DayCalendar(
                            isLandscape: orientation == Orientation.landscape,
                            mainContext: context,
                            key: _dayKey,
                            datePickerTheme: theme,
                            pickType: widget.pickType,
                            monthKey: _monthKey,
                            dayMonthAnim: _dayMonthAnim,
                            selectedDateTimes: _selectedDateTimes,
                            onDayPressed: widget.onDayPressed,
                            markedDates: widget.markedDates,
                            selectionType: widget.selectionType,
                            minDate: widget.minDate,
                            maxDate: widget.maxDate,
                            onDaySelected: (int dateCount) {
                              setState(() {
                                _dateCount = dateCount;
                              });
                            },
                          ),
                        );
                      }

                      return Stack(children: children);
                    },
                  ),
                ),
                orientation == Orientation.portrait
                    ? AnimatedBuilder(
                        animation: _dayMonthAnim,
                        builder: (BuildContext context, Widget? child) {
                          final selectedDateTimes = widget.pickType ==
                                  PickType.year
                              ? _yearKey.currentState!._selectedDateTimes
                              : widget.pickType == PickType.month
                                  ? _monthKey.currentState!._selectedDateTimes
                                  : _dayKey.currentState!._selectedDateTimes;
                          final dateCount =
                              calculateDateCount(selectedDateTimes);
                          return AdvVisibility(
                            visibility: (widget.selectionType ==
                                        SelectionType.multi ||
                                    widget.selectionType == SelectionType.range)
                                ? VisibilityFlag.visible
                                : VisibilityFlag.invisible,
                            child: Center(
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: AdvButton.text(
                                  "Submit ($dateCount ${widget.pickType.name})",
                                  width: double.infinity,
                                  buttonSize: ButtonSize.large,
                                  onPressed: () async {
                                    switch (widget.pickType) {
                                      case PickType.year:
                                        _yearKey.currentState!
                                            ._handleSubmitTapped();
                                        break;
                                      case PickType.month:
                                        _monthKey.currentState!
                                            ._handleSubmitTapped();
                                        break;
                                      case PickType.day:
                                        _dayKey.currentState!
                                            ._handleSubmitButtonTapped();
                                        break;
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : null,
              ],
            ),
            if (orientation == Orientation.landscape)
              Builder(
                builder: (BuildContext context) {
                  final selectedDateTimes = widget.pickType == PickType.year
                      ? _yearKey.currentState!._selectedDateTimes
                      : widget.pickType == PickType.month
                          ? _monthKey.currentState!._selectedDateTimes
                          : _dayKey.currentState!._selectedDateTimes;
                  final dateCount = calculateDateCount(selectedDateTimes);

                  return Positioned(
                    left: (context.mediaQuery.size.width - 48) / 2,
                    right: 0.0,
                    bottom: 0.0,
                    child: AdvVisibility(
                      visibility:
                          (widget.selectionType == SelectionType.multi ||
                                  widget.selectionType == SelectionType.range)
                              ? VisibilityFlag.visible
                              : VisibilityFlag.invisible,
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: AdvButton.text(
                            "Submit ($dateCount ${widget.pickType.name})",
                            buttonSize: ButtonSize.large,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            onPressed: () async {
                              switch (widget.pickType) {
                                case PickType.year:
                                  _yearKey.currentState!._handleSubmitTapped();
                                  break;
                                case PickType.month:
                                  _monthKey.currentState!._handleSubmitTapped();
                                  break;
                                case PickType.day:
                                  _dayKey.currentState!
                                      ._handleSubmitButtonTapped();
                                  break;
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  int calculateDateCount(List<DateTime> selectedDateTimes) {
    var dateCount = _dateCount;

    if (widget.selectionType == SelectionType.range) {
      if (selectedDateTimes.length == 1) {
        dateCount = 1;
      } else if (selectedDateTimes.isNotEmpty) {
        if (widget.pickType == PickType.day) {
          dateCount = selectedDateTimes.last
                  .difference(selectedDateTimes.first)
                  .inDays +
              1;
        } else if (widget.pickType == PickType.month) {
          final firstDate = selectedDateTimes.last;
          final lastDate = selectedDateTimes.first;

          dateCount = ((firstDate.year - lastDate.year) * 12) +
              (firstDate.month - lastDate.month) +
              1;
        } else {
          final firstDate = selectedDateTimes.last;
          final lastDate = selectedDateTimes.first;

          dateCount = firstDate.year - lastDate.year + 1;
        }
      }
    }

    return dateCount;
  }
}
