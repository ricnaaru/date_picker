part of date_picker;

class DayCalendar extends StatefulWidget {
  final BuildContext mainContext;
  final GlobalKey<MonthCalendarState> monthKey;
  final AnimationController dayMonthAnim;
  final DatePickerTheme datePickerTheme;
  final PickType pickType;
  final SelectionType selectionType;
  final List<MarkedDate> markedDates;
  final List<DateTime> selectedDateTimes;
  final Function(List<DateTime>)? onDayPressed;
  final DateTime? minDate;
  final DateTime? maxDate;
  final Function(int)? onDaySelected;
  final bool isLandscape;

  const DayCalendar({
    required this.isLandscape,
    required this.mainContext,
    Key? key,
    required this.monthKey,
    required this.dayMonthAnim,
    required this.datePickerTheme,
    required this.pickType,
    required this.selectionType,
    required this.markedDates,
    required this.selectedDateTimes,
    this.onDayPressed,
    this.minDate,
    this.maxDate,
    this.onDaySelected,
  }) : super(key: key);

  @override
  DayCalendarState createState() => DayCalendarState();
}

class DayCalendarState extends State<DayCalendar> {
  /// The first run, this will be shown (0.0 [widget.dayMonthAnim]'s value)
  ///
  /// When this title is tapped [_handleDayTitleTapped], we will give this the
  /// fade out animation ([widget.dayMonthAnim]'s value will gradually change
  /// from 0.0 to 1.0)
  ///
  /// When one of [MonthCalendar]'s boxes is tapped [_handleMonthBoxTapped],
  /// we will give this the fade in animation ([widget.dayMonthAnim]'s value
  /// will gradually change from 1.0 to 0.0)

  // Page Controller
  late PageController _pageCtrl;

  /// Start Date from each page
  /// the selected page is on index 1,
  /// 0 is for previous month,
  /// 2 is for next month
  List<DateTime?> _pageDates = List<DateTime?>.filled(3, null);

  /// Used to mark start and end of week days for rendering boxes purpose
  int _startWeekday = 0;
  int _endWeekday = 0;

  /// Selected DateTime
  List<DateTime> _selectedDateTimes = [];

  /// Marks whether the date range [SelectionType.range] is selected on both ends
  bool _selectRangeIsComplete = false;

  /// Transition that this Widget will go whenever this' title is tapped
  /// [_handleDayTitleTapped] or one of [MonthCalendar]'s boxes is tapped
  /// [_handleMonthBoxTapped]
  ///
  /// This tween will always begin from full expanded offset and size
  /// and end to one of [MonthCalendar]'s boxes offset and size
  RectTween? rectTween;

  @override
  void initState() {
    super.initState();

    /// Whenever day to month animation is finished, reset rectTween to null
    widget.dayMonthAnim.addListener(() {
      if (widget.dayMonthAnim.status == AnimationStatus.completed ||
          widget.dayMonthAnim.status == AnimationStatus.dismissed) {
        rectTween = null;
      }
    });

    _selectedDateTimes = widget.selectedDateTimes;

    _selectRangeIsComplete = widget.selectionType == SelectionType.range &&
        _selectedDateTimes.length % 2 == 0;

    /// setup pageController
    _pageCtrl = PageController(
      initialPage: 1,
      keepPage: true,
      viewportFraction: widget.datePickerTheme.viewportFraction,
    );

    /// set _pageDates for the first time
    _setPage();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dayContent = widget.isLandscape
        ? _buildDayContentLandscape(context)
        : _buildDayContentPortrait(context);

    return AnimatedBuilder(
      animation: widget.dayMonthAnim,
      builder: (BuildContext context, Widget? child) {
        if (rectTween == null) {
          return AdvVisibility(
            visibility: widget.dayMonthAnim.value == 1.0
                ? VisibilityFlag.gone
                : VisibilityFlag.visible,
            child: dayContent,
          );
        }

        /// rect tween set when one of these two occasions occurs
        /// 1. Day Title tapped so it has to be squeezed inside month boxes
        ///
        ///     See also [_handleDayTitleTapped]
        /// 2. One of month boxes is tapped, so Day content should be expanded
        ///     See also [_handleDayBoxTapped]

        /// calculate lerp of destination rect according to current widget.dayMonthAnim.value
        final destRect = rectTween!.evaluate(widget.dayMonthAnim);

        /// minus padding for each horizontal and vertical axis
        final destSize = Size(
            destRect!.size.width - (widget.datePickerTheme.dayPadding * 2),
            destRect.size.height - (widget.datePickerTheme.dayPadding * 2));
        final top = destRect.top + widget.datePickerTheme.dayPadding;
        final left = destRect.left + widget.datePickerTheme.dayPadding;

        final xFactor = destSize.width / rectTween!.begin!.width;
        final yFactor = destSize.height / rectTween!.begin!.height;

        /// scaling the content inside
        final transform = Matrix4.identity()..scale(xFactor, yFactor, 1.0);

        /// keep the initial size, so we can achieve destination scale
        /// example :
        /// rectTween.begin.width * destSize.width / rectTween.begin.width => destSize.width

        /// For the Opacity :
        /// as the scaling goes from 0.0 to 1.0, we progressively change the opacity from 1.0 to 0.0
        return Positioned(
          top: top,
          width: rectTween!.begin!.width,
          height: rectTween!.begin!.height,
          left: left,
          child: Opacity(
            opacity: 1.0 - widget.dayMonthAnim.value,
            child: Transform(
              transform: transform,
              child: dayContent,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayContentPortrait(BuildContext context) {
    return Column(
      children: <Widget>[
        AdvRow(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          children: <Widget>[
            IconButton(
              onPressed: () => _setPage(page: 0),
              icon: Icon(
                widget.datePickerTheme.iconPrevious,
                color: widget.datePickerTheme.iconColor,
              ),
            ),
            Builder(
              builder: (BuildContext childContext) {
                final title = DateFormat.yMMM().format(_pageDates[1]!);
                return Expanded(
                  child: InkWell(
                    child: Container(
                      padding: widget.datePickerTheme.headerMargin,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: widget.datePickerTheme.headerTextStyle,
                      ),
                    ),
                    onTap: () => _handleDayTitleTapped(context),
                  ),
                );
              },
            ),
            IconButton(
              padding: widget.datePickerTheme.headerMargin,
              onPressed: () => _setPage(page: 2),
              icon: Icon(
                widget.datePickerTheme.iconNext,
                color: widget.datePickerTheme.iconColor,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _renderWeekDays(),
        ),
        Expanded(
          child: PageView.builder(
            itemCount: 3,
            onPageChanged: (value) {
              _setPage(page: value);
            },
            controller: _pageCtrl,
            itemBuilder: (context, index) {
              return _buildCalendarPortrait(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayContentLandscape(BuildContext context) {
    final year = _pageDates[1]!.year;
    final month = _pageDates[1]!.month;

    return AdvRow(
      divider: const RowDivider(16),
      children: [
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            final width = ((constraint.maxHeight - 48) / 6 * 7)
                .clamp(0, 500)
                .toDouble();

            return SizedBox(
              width: width,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _renderWeekDays(),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      itemCount: 3,
                      onPageChanged: (value) {
                        _setPage(page: value);
                      },
                      controller: _pageCtrl,
                      itemBuilder: (context, index) {
                        return _buildCalendarLandscape(index);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Expanded(
          child: Column(
            children: [
              AdvRow(
                children: <Widget>[
                  IconButton(
                    onPressed: () => _setPage(page: 0),
                    icon: Icon(
                      widget.datePickerTheme.iconPrevious,
                      color: widget.datePickerTheme.iconColor,
                    ),
                  ),
                  Builder(builder: (BuildContext childContext) {
                    final title = DateFormat.yMMM().format(_pageDates[1]!);
                    return Expanded(
                      child: InkWell(
                        child: Container(
                          padding: widget.datePickerTheme.headerMargin,
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: widget.datePickerTheme.headerTextStyle,
                          ),
                        ),
                        onTap: () => _handleDayTitleTapped(context),
                      ),
                    );
                  }),
                  IconButton(
                    padding: widget.datePickerTheme.headerMargin,
                    onPressed: () => _setPage(page: 2),
                    icon: Icon(
                      widget.datePickerTheme.iconNext,
                      color: widget.datePickerTheme.iconColor,
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: widget.markedDates
                    .where((markedDate) =>
                        markedDate.date.month == month &&
                        markedDate.date.year == year)
                    .toList()
                    .isNotEmpty,
                child: Container(
                  child: Text(
                    widget.datePickerTheme.markedDatesTitle,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 8),
                ),
              ),
              Expanded(
                child: ListView(
                  children: widget.markedDates
                      .where((markedDate) =>
                          markedDate.date.month == month &&
                          markedDate.date.year == year)
                      .toList()
                      .map(
                    (markedDate) {
                      return MarkedDateWidget(
                        markedDate: markedDate,
                        style: widget.datePickerTheme.markedDaysTextStyle,
                      );
                    },
                  ).toList(),
                ),
              ),
              AdvVisibility(
                //temp solution
                visibility: VisibilityFlag.invisible,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: AdvButton.text(
                    "Submit",
                    buttonSize: ButtonSize.large,
                    onPressed: () async {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarPortrait(int slideIndex) {
    final d = DateTime(
      _pageDates[slideIndex]!.year,
      _pageDates[slideIndex]!.month + 1,
      0,
    );
    final startWeekDay = slideIndex == 0
        ? 7 - ((d.day - _startWeekday) % 7)
        : slideIndex == 1
            ? _startWeekday
            : _endWeekday;
    final endWeekDay = slideIndex == 0
        ? _startWeekday
        : slideIndex == 1
            ? _endWeekday
            : (d.day - (7 - _endWeekday)) % 7;
    final totalItemCount =
        d.day + startWeekDay + (endWeekDay > 0 ? (7 - endWeekDay) : 0);
    final year = _pageDates[slideIndex]!.year;
    final month = _pageDates[slideIndex]!.month;

    /// build calendar and marked dates notes
    return Column(
      children: <Widget>[
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 7,
          childAspectRatio: widget.datePickerTheme.childAspectRatio,
          padding: EdgeInsets.zero,
          children: List.generate(
            totalItemCount,
            (index) {
              return _buildDayButton(year, month, index, slideIndex);
            },
          ),
        ),
        Visibility(
          visible: widget.markedDates
              .where((markedDate) =>
                  markedDate.date.month == month &&
                  markedDate.date.year == year)
              .toList()
              .isNotEmpty,
          child: Container(
            child: Text(
              widget.datePickerTheme.markedDatesTitle,
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
            ),
            width: double.infinity,
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          ),
        ),
        Expanded(
          child: ListView(
            children: widget.markedDates
                .where((markedDate) =>
                    markedDate.date.month == month &&
                    markedDate.date.year == year)
                .toList()
                .map(
              (markedDate) {
                return MarkedDateWidget(
                  markedDate: markedDate,
                  style: widget.datePickerTheme.markedDaysTextStyle,
                );
              },
            ).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarLandscape(int slideIndex) {
    final d = DateTime(
      _pageDates[slideIndex]!.year,
      _pageDates[slideIndex]!.month + 1,
      0,
    );
    final startWeekDay = slideIndex == 0
        ? 7 - ((d.day - _startWeekday) % 7)
        : slideIndex == 1
            ? _startWeekday
            : _endWeekday;
    final endWeekDay = slideIndex == 0
        ? _startWeekday
        : slideIndex == 1
            ? _endWeekday
            : (d.day - (7 - _endWeekday)) % 7;
    final totalItemCount =
        d.day + startWeekDay + (endWeekDay > 0 ? (7 - endWeekDay) : 0);
    final year = _pageDates[slideIndex]!.year;
    final month = _pageDates[slideIndex]!.month;

    /// build calendar and marked dates notes
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 7,
      childAspectRatio: widget.datePickerTheme.childAspectRatio,
      padding: EdgeInsets.zero,
      children: List.generate(totalItemCount, (index) {
        return _buildDayButton(year, month, index, slideIndex);
      }),
    );
  }

  List<Widget> _renderWeekDays() {
    final list = <Widget>[];

    for (final weekDay in widget.datePickerTheme.weekdaysArray) {
      list.add(
        Expanded(
            child: Container(
          margin: widget.datePickerTheme.weekDayMargin,
          child: Center(
            child: Text(
              weekDay,
              style: widget.datePickerTheme.daysLabelTextStyle,
            ),
          ),
        )),
      );
    }

    return list;
  }

  /// draw a little dot inside the each boxes (only if it's one of the
  /// [widget.markedDates] and slightly below day text
  Widget _renderMarked(DateTime now) {
    if (widget.markedDates.isNotEmpty &&
        widget.markedDates
            .where((markedDate) => markedDate.date == now)
            .toList()
            .isNotEmpty) {
      return widget.datePickerTheme.markedDateWidget;
    }

    return Container();
  }

  void _handleSubmitButtonTapped() {
    if (widget.onDayPressed != null) widget.onDayPressed!(_selectedDateTimes);
  }

  void _handleDayTitleTapped(BuildContext context) {
    /// unless the whole content is fully expanded, cannot tap on title
    if (widget.dayMonthAnim.value != 0.0) return;

    final fullRenderBox = context.findRenderObject() as RenderBox?;
    final fullSize = fullRenderBox!.size;
    const fullOffset = Offset.zero;

    final fullRect = Rect.fromLTWH(
        fullOffset.dx, fullOffset.dy, fullSize.width, fullSize.height);
    final boxRect = widget.monthKey.currentState!
        .getBoxRectFromIndex(_pageDates[1]!.month - 1);

    rectTween = RectTween(begin: fullRect, end: boxRect);

    if (mounted)
      setState(() {
        widget.dayMonthAnim.forward();
      });
  }

  void _handleDayBoxTapped(DateTime currentDate) {
    /// unless the whole content is fully expanded, cannot tap on date
    if (widget.dayMonthAnim.value != 0.0) return;

    if (widget.selectionType == SelectionType.single) {
      _selectedDateTimes.clear();
      _selectedDateTimes.add(currentDate);
      if (widget.onDayPressed != null) widget.onDayPressed!(_selectedDateTimes);
    } else if (widget.selectionType == SelectionType.multi) {
      if (_selectedDateTimes.where((date) => date == currentDate).isEmpty) {
        _selectedDateTimes.add(currentDate);
      } else {
        _selectedDateTimes.remove(currentDate);
      }

      if (widget.onDaySelected != null) {
        widget.onDaySelected!(_selectedDateTimes.length);
      }
    } else if (widget.selectionType == SelectionType.range) {
      if (!_selectRangeIsComplete) {
        final dateDiff = _selectedDateTimes[0].difference(currentDate).inDays;
        DateTime loopDate;
        DateTime endDate;

        if (dateDiff > 0) {
          loopDate = currentDate;
          endDate = _selectedDateTimes[0];
        } else {
          loopDate = _selectedDateTimes[0];
          endDate = currentDate;
        }

        _selectedDateTimes.clear();
        _selectedDateTimes.add(loopDate);
        _selectedDateTimes.add(endDate);

//        if (widget.onDayPressed != null) widget.onDayPressed(_selectedDateTimes);
      } else {
        _selectedDateTimes.clear();
        _selectedDateTimes.add(currentDate);
      }

      _selectRangeIsComplete = !_selectRangeIsComplete;

      if (widget.onDaySelected != null) {
        widget.onDaySelected!(_selectedDateTimes.length);
      }
    }

    if (mounted) setState(() {});

    widget.monthKey.currentState!.updateSelectedDateTimes(_selectedDateTimes);
  }

  void _setPage({int? page}) {
    /// for initial set
    if (page == null) {
      final selectedDate = _selectedDateTimes.isNotEmpty
          ? _selectedDateTimes.first
          : DateTime.now();

      final date0 = DateTime(selectedDate.year, selectedDate.month - 1, 1);
      final date1 = DateTime(selectedDate.year, selectedDate.month, 1);
      final date2 = DateTime(selectedDate.year, selectedDate.month + 1, 1);

      if (mounted)
        setState(() {
          _startWeekday = date1.weekday;
          _endWeekday = date2.weekday;
          _pageDates = [
            date0,
            date1,
            date2,
          ];
        });
    } else if (page == 1) {
      /// return right away if the selected page is current page
      return;
    } else {
      /// processing for the next or previous page
      final dates = _pageDates;

      /// previous page
      if (page == 0) {
        dates[2] = DateTime(dates[0]!.year, dates[0]!.month + 1, 1);
        dates[1] = DateTime(dates[0]!.year, dates[0]!.month, 1);
        dates[0] = DateTime(dates[0]!.year, dates[0]!.month - 1, 1);
        page = page + 1;
      } else if (page == 2) {
        /// next page
        dates[0] = DateTime(dates[2]!.year, dates[2]!.month - 1, 1);
        dates[1] = DateTime(dates[2]!.year, dates[2]!.month, 1);
        dates[2] = DateTime(dates[2]!.year, dates[2]!.month + 1, 1);
        page = page - 1;
      }

      if (mounted)
        setState(() {
          _startWeekday = dates[page!]!.weekday;
          _endWeekday = dates[page + 1]!.weekday;
          _pageDates = dates;
        });

      /// animate to page right away after reset the values
      _pageCtrl.animateToPage(page,
          duration: const Duration(milliseconds: 1),
          curve: const Threshold(0.0));
    }

    /// set current month and year in the [MonthCalendar] and
    /// [YearCalendar (via MonthCalendar)]
    widget.monthKey.currentState!
        .setMonth(_pageDates[1]!.month, _pageDates[1]!.year);
    widget.monthKey.currentState!.setYear(_pageDates[1]!.year);
  }

  /// an open method for [MonthCalendar] to trigger whenever it itself changes
  /// its month value
  void setMonth(
    int month,
    int year,
  ) {
    final dates = <DateTime>[
      DateTime(year, month - 1, 1),
      DateTime(year, month, 1),
      DateTime(year, month + 1, 1),
    ];

    if (mounted)
      setState(() {
        _startWeekday = dates[1].weekday;
        _endWeekday = dates[2].weekday;
        _pageDates = dates;
      });
  }

  Widget _buildDayButton(int year, int month, int index, int slideIndex) {
    final d = DateTime(
      _pageDates[slideIndex]!.year,
      _pageDates[slideIndex]!.month + 1,
      0,
    );
    final startWeekDay = slideIndex == 0
        ? 7 - ((d.day - _startWeekday) % 7)
        : slideIndex == 1
            ? _startWeekday
            : _endWeekday;
    final currentDate = DateTime(year, month, index + 1 - startWeekDay);
    final isToday = DateTime.now().day == currentDate.day &&
        DateTime.now().month == currentDate.month &&
        DateTime.now().year == currentDate.year;
    final isSelectedDay = (widget.selectionType != SelectionType.range &&
            _selectedDateTimes.isNotEmpty &&
            _selectedDateTimes.contains(currentDate)) ||
        (widget.selectionType == SelectionType.range &&
            _selectedDateTimes.length == 2 &&
            currentDate.difference(_selectedDateTimes[0]).inDays > 0 &&
            _selectedDateTimes.last.difference(currentDate).inDays > 0);

    /// this is for range selection type
    final isStartEndDay = _selectedDateTimes.isNotEmpty &&
        ((_selectedDateTimes.indexOf(currentDate) == 0 ||
                _selectedDateTimes.indexOf(currentDate) ==
                    _selectedDateTimes.length - 1) ||
            (widget.selectionType != SelectionType.range &&
                _selectedDateTimes.contains(currentDate)));

    final isPrevMonthDay = index < startWeekDay;
    final isNextMonthDay =
        index >= (DateTime(year, month + 1, 0).day) + startWeekDay;
    final isThisMonthDay = !isPrevMonthDay && !isNextMonthDay;

    TextStyle? textStyle;
    Color? borderColor;

    if (isPrevMonthDay) {
      textStyle = isSelectedDay || isStartEndDay
          ? widget.datePickerTheme.selectedDayTextStyle
          : isToday
              ? widget.datePickerTheme.todayTextStyle
              : (index % 7 == 0 || index % 7 == 6)
                  ? widget.datePickerTheme.weekendTextStyle
                  : widget.datePickerTheme.weekdayTextStyle;
      textStyle = textStyle.copyWith(
          color: Color.lerp(textStyle.color, Colors.white, 0.7));
      borderColor = widget.datePickerTheme.prevMonthDayBorderColor;
    } else if (isThisMonthDay) {
      textStyle = isSelectedDay || isStartEndDay
          ? widget.datePickerTheme.selectedDayTextStyle
          : isToday
              ? widget.datePickerTheme.todayTextStyle
              : (index % 7 == 0 || index % 7 == 6)
                  ? widget.datePickerTheme.weekendTextStyle
                  : widget.datePickerTheme.weekdayTextStyle;
      borderColor = isToday
          ? widget.datePickerTheme.todayColor
          : widget.datePickerTheme.nextMonthDayBorderColor;
    } else if (isNextMonthDay) {
      textStyle = isSelectedDay || isStartEndDay
          ? widget.datePickerTheme.selectedDayTextStyle
          : isToday
              ? widget.datePickerTheme.todayTextStyle
              : (index % 7 == 0 || index % 7 == 6)
                  ? widget.datePickerTheme.weekendTextStyle
                  : widget.datePickerTheme.weekdayTextStyle;
      textStyle = textStyle.copyWith(
          color: Color.lerp(textStyle.color, Colors.white, 0.7));
      borderColor = widget.datePickerTheme.nextMonthDayBorderColor;
    }

    Color boxColor;
    if (isStartEndDay) {
      boxColor = widget.datePickerTheme.selectedColor;
    } else if (isSelectedDay) {
      boxColor = widget.datePickerTheme.selectedColor.withAlpha(150);
    } else if (isToday) {
      boxColor = widget.datePickerTheme.dayButtonColor;
    } else {
      boxColor = widget.datePickerTheme.dayButtonColor;
    }

    final currentDateLong = currentDate.millisecondsSinceEpoch;
    final minDateLong =
        widget.minDate?.millisecondsSinceEpoch ?? currentDateLong;
    final maxDateLong =
        widget.maxDate?.millisecondsSinceEpoch ?? currentDateLong;
    final availableDate =
        currentDateLong >= minDateLong && currentDateLong <= maxDateLong;

    final circularRadius = Radius.circular(
      widget.datePickerTheme.daysHaveCircularBorder ? 100 : 12,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(circularRadius),
        border: Border.all(color: borderColor!),
      ),
      margin: EdgeInsets.all(widget.datePickerTheme.dayPadding),
      child: IgnorePointer(
        ignoring: !availableDate,
        child: TextButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(
              EdgeInsets.all(widget.datePickerTheme.dayPadding),
            ),
            shape: MaterialStateProperty.all(
              widget.datePickerTheme.daysHaveCircularBorder
                  ? const CircleBorder()
                  : RoundedRectangleBorder(
                borderRadius: BorderRadius.all(circularRadius),
                // side: BorderSide(color: borderColor),
              ),
            ),
            backgroundColor: MaterialStateProperty.all(
              availableDate
                  ? boxColor
                  : Color.lerp(const Color(0xffD1D1D1), boxColor, 0.8),
            ),
          ),
          onPressed: () => _handleDayBoxTapped(currentDate),
          child: Stack(
            children: <Widget>[
              Center(
                child: Text(
                  "${currentDate.day}",
                  style: availableDate
                      ? textStyle!
                      : textStyle!.copyWith(
                          color: Color.lerp(
                              const Color(0xffD1D1D1), textStyle.color, 0.5)),
                  maxLines: 1,
                ),
              ),
              _renderMarked(currentDate),
            ],
          ),
        ),
      ),
    );
  }
}
