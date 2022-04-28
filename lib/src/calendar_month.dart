part of date_picker;

class MonthCalendar extends StatefulWidget {
  final BuildContext mainContext;
  final GlobalKey<DayCalendarState> dayKey;
  final GlobalKey<YearCalendarState> yearKey;
  final AnimationController dayMonthAnim;
  final AnimationController monthYearAnim;
  final DatePickerTheme datePickerTheme;
  final PickType pickType;
  final SelectionType selectionType;
  final List<MarkedDate> markedDates;
  final List<DateTime> selectedDateTimes;
  final Function(List<DateTime>)? onDayPressed;
  final Function(int)? onDaySelected;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool isLandscape;

  const MonthCalendar({
    required this.isLandscape,
    required this.mainContext,
    Key? key,
    required this.dayKey,
    required this.yearKey,
    required this.dayMonthAnim,
    required this.monthYearAnim,
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
  MonthCalendarState createState() => MonthCalendarState();
}

class MonthCalendarState extends State<MonthCalendar>
    with TickerProviderStateMixin {
  /// The first run, this will be shown (0.0 [widget.dayMonthAnim]'s value)
  ///
  /// After the first run, when [widget.dayMonthAnim]'s value is 0.0, this will
  /// be gone
  ///
  /// When the [DayCalendar]'s title is tapped [_handleDayTitleTapped],
  /// we will give this the fade in animation ([widget.dayMonthAnim]'s value
  /// will gradually change from 0.0 to 1.0)
  ///
  /// When one of this' boxes is tapped [_handleMonthBoxTapped], we will give
  /// this the fade out animation ([widget.dayMonthAnim]'s value will gradually
  /// change from 1.0 to 0.0)
  ///
  /// When this title is tapped [_handleMonthTitleTapped],
  /// we will give this the fade out animation ([widget.monthYearAnim]'s value
  /// will gradually change from 1.0 to 0.0)
  ///
  /// When one of [YearCalendar]'s boxes is tapped [_handleYearBoxTapped],
  /// we will give this the fade in animation ([widget.monthYearAnim]'s value
  /// will gradually change from 0.0 to 1.0)

  /// Page Controller
  late PageController _pageCtrl;

  /// Start Date from each page
  /// the selected page is on index 1,
  /// 0 is for previous year,
  /// 2 is for next year
  List<DateTime?> _pageDates = List<DateTime?>.filled(3, null);

  /// Selected DateTime
  List<DateTime> _selectedDateTimes = <DateTime>[];

  List<DateTime> get selectedDateTimes => _selectedDateTimes;

  /// Marks whether the date range [SelectionType.range] is selected on both ends
  bool _selectRangeIsComplete = false;

  /// Array for each boxes position and size
  ///
  /// each boxes position and size is stored for the first time and after they
  /// are rendered, since their size and position at full extension is always
  /// the same. Later will be used by [DayCalender] to squeezed its whole content
  /// as big as one of these boxes and in its position, according to its month
  /// value
  List<Rect?> boxRects = List<Rect?>.filled(12, null);

  /// Opacity controller for [MonthCalender]
  late AnimationController opacityCtrl;

  /// Transition that this Widget will go whenever [DayCalendar]' title is tapped
  /// [_handleDayTitleTapped] or one of this' boxes is tapped [_handleMonthBoxTapped]
  ///
  /// or
  ///
  /// whenever this' title is tapped [_handleMonthTitleTapped] or one of
  /// [YearCalendar]'s boxes is tapped [_handleYearBoxTapped]
  ///
  /// This tween will always begin from one of [YearCalendar]'s boxes offset and size
  /// and end to full expanded offset and size
  RectTween? rectTween;

  /// On the first run, [MonthCalendar] will need to be drawn so [boxRects] will
  /// be set
  bool _firstRun = true;

  @override
  void initState() {
    super.initState();

    /// if the [pickType] is month, then show [MonthCalendar] as front page,
    /// (there will be no [DayCalendar], otherwise, hide [MonthCalendar] and
    /// wait until [DayCalendar] request to be shown
    ///
    /// See [_handleDayTitleTapped]
    opacityCtrl = AnimationController(
        duration: const Duration(milliseconds: _kAnimationDuration),
        vsync: this,
        value: widget.pickType == PickType.month ? 1.0 : 0.0);

    /// Change opacity controller's value equals month year controller's value
    widget.dayMonthAnim.addListener(() {
      opacityCtrl.value = widget.dayMonthAnim.value;
    });

    /// Whenever month to year animation is finished, reset rectTween to null
    /// Also change opacity controller's value equals month year controller's value
    widget.monthYearAnim.addListener(() {
      opacityCtrl.value = widget.monthYearAnim.value;

      if (widget.monthYearAnim.status == AnimationStatus.completed ||
          widget.monthYearAnim.status == AnimationStatus.dismissed) {
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

    /// Switch firstRun's value to false after the first build
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _firstRun = false;
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monthContent = widget.isLandscape
        ? _buildMonthContentLandscape(context)
        : _buildMonthContentPortrait(context);

    return AnimatedBuilder(
      animation: opacityCtrl,
      builder: (BuildContext context, Widget? child) {
        if (rectTween == null)
          return AdvVisibility(
            visibility: opacityCtrl.value == 0.0 && !_firstRun
                ? VisibilityFlag.gone
                : VisibilityFlag.visible,
            child: Opacity(
              opacity: opacityCtrl.value,
              child: monthContent,
            ),
          );

        /// rect tween set when one of these two occasions occurs
        /// 1. Month Title tapped so it has to be squeezed inside year boxes
        ///
        ///     See also [_handleMonthTitleTapped]
        /// 2. One of year boxes is tapped, so Month content should be expanded
        ///     See also [_handleMonthBoxTapped]
        ///
        /// calculate lerp of destination rect according to current
        /// widget.dayMonthAnim.value or widget.monthYearAnim.value
        final destRect = rectTween!.evaluate(opacityCtrl);

        /// minus padding for each horizontal and vertical axis
        final destSize = Size(
            destRect!.size.width - (widget.datePickerTheme.dayPadding * 2),
            destRect.size.height - (widget.datePickerTheme.dayPadding * 2));
        final top = destRect.top + widget.datePickerTheme.dayPadding;
        final left = destRect.left + widget.datePickerTheme.dayPadding;

        final xFactor = destSize.width / rectTween!.end!.width;
        final yFactor = destSize.height / rectTween!.end!.height;

        final transform = Matrix4.identity()..scale(xFactor, yFactor, 1.0);

        /// For the Width and Height :
        /// keep the initial size, so we can achieve destination scale
        /// example :
        /// rectTween.end.width * destSize.width / rectTween.end.width => destSize.width

        /// For the Opacity :
        /// as the scaling goes from 0.0 to 1.0, we progressively change the opacity
        ///
        /// Note: to learn how these animations controller's value work,
        /// read the documentation at start of this State's script
        return Positioned(
          top: top,
          width: rectTween!.end!.width,
          height: rectTween!.end!.height,
          left: left,
          child: Opacity(
            opacity: opacityCtrl.value,
            child: Transform(
              transform: transform,
              child: monthContent,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthContentLandscape(BuildContext parentContext) {
    final year = _pageDates[1]!.year;

    return AdvRow(
      divider: const RowDivider(8),
      children: [
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            final width =
                ((constraint.maxHeight - 32.0) / 6 * 7).clamp(0.0, 500.0);

            return SizedBox(
              width: width,
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
            );
          },
        ),
        Expanded(
          child: Column(
            children: [
              buildPicker(parentContext),
              Visibility(
                visible: widget.markedDates
                    .where((markedDate) => markedDate.date.year == year)
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
                      .where((markedDate) => markedDate.date.year == year)
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

  Widget _buildMonthContentPortrait(BuildContext parentContext) {
    return Column(
      children: <Widget>[
        buildPicker(parentContext),
        Expanded(
          child: PageView.builder(
            itemCount: 3,
            onPageChanged: (value) {
              _setPage(page: value);
            },
            controller: _pageCtrl,
            itemBuilder: (context, index) {
              final year = _pageDates[index]!.year;

              return Column(
                children: [
                  _buildCalendar(index),
                  Visibility(
                      visible: widget.markedDates
                          .where((markedDate) => markedDate.date.year == year)
                          .toList()
                          .isNotEmpty,
                      child: Container(
                        child: Text(
                          widget.datePickerTheme.markedDatesTitle,
                          style: const TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w700),
                        ),
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                      )),
                  Expanded(
                    child: ListView(
                      children: widget.markedDates
                          .where((markedDate) => markedDate.date.year == year)
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
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(int slideIndex) {
    final year = _pageDates[slideIndex]!.year;

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: widget.isLandscape ? 6 : 4,
      childAspectRatio: widget.datePickerTheme.childAspectRatio,
      padding: EdgeInsets.zero,
      children: List.generate(12, (index) {
        final currentDate = DateTime(year, index + 1, 1);
        final currentDateInt =
            int.tryParse("$year${(index + 1).leadingZero(2)}") ?? 0;
        final isToday = DateTime.now().month == currentDate.month &&
            DateTime.now().year == currentDate.year;

        final firstDate =
            _selectedDateTimes.isNotEmpty ? _selectedDateTimes.first : null;
        final firstDateInt = _selectedDateTimes.isNotEmpty
            ? int.tryParse(
                    "${firstDate?.year}${firstDate?.month.leadingZero(2)}") ??
                0
            : 0;

        final lastDate =
            _selectedDateTimes.length == 2 ? _selectedDateTimes.last : null;
        final lastDateInt = _selectedDateTimes.length == 2
            ? int.tryParse(
                    "${lastDate?.year}${lastDate?.month.leadingZero(2)}") ??
                0
            : 0;

        final isSelectedDay = (widget.selectionType != SelectionType.range &&
                _selectedDateTimes.isNotEmpty &&
                _selectedDateTimes
                    .where((loopDate) =>
                        loopDate.month == currentDate.month &&
                        loopDate.year == currentDate.year)
                    .isNotEmpty) ||
            (widget.selectionType == SelectionType.range &&
                (_selectedDateTimes.length == 2 &&
                    currentDateInt > firstDateInt &&
                    currentDateInt < lastDateInt));

        final isStartEndDay = _selectedDateTimes.isNotEmpty &&
            ((widget.selectionType == SelectionType.range &&
                        (_selectedDateTimes.length == 1 &&
                            _selectedDateTimes.first.month ==
                                currentDate.month &&
                            _selectedDateTimes.first.year ==
                                currentDate.year) ||
                    (_selectedDateTimes.length == 2 &&
                        ((_selectedDateTimes.first.month == currentDate.month &&
                                _selectedDateTimes.first.year ==
                                    currentDate.year) ||
                            (_selectedDateTimes.last.month ==
                                    currentDate.month &&
                                _selectedDateTimes.last.year ==
                                    currentDate.year)))) ||
                (widget.selectionType != SelectionType.range &&
                    _selectedDateTimes.isNotEmpty &&
                    _selectedDateTimes
                        .where((loopDate) =>
                            loopDate.month == currentDate.month &&
                            loopDate.year == currentDate.year)
                        .isNotEmpty));

        TextStyle textStyle;
        Color borderColor;

        Color boxColor;
        if (isStartEndDay) {
          textStyle = widget.datePickerTheme.selectedDayTextStyle;
          boxColor = widget.datePickerTheme.selectedColor;
          borderColor = widget.datePickerTheme.thisMonthDayBorderColor;
        } else if (isSelectedDay) {
          textStyle = widget.datePickerTheme.selectedDayTextStyle;
          boxColor = widget.datePickerTheme.selectedColor.withAlpha(150);
          borderColor = widget.datePickerTheme.thisMonthDayBorderColor;
        } else if (isToday) {
          textStyle = widget.datePickerTheme.todayTextStyle;
          boxColor = widget.datePickerTheme.dayButtonColor;
          borderColor = widget.datePickerTheme.todayColor;
        } else {
          textStyle = widget.datePickerTheme.weekdayTextStyle;
          boxColor = widget.datePickerTheme.dayButtonColor;
          borderColor = widget.datePickerTheme.thisMonthDayBorderColor;
        }

        final currentDateLong = int.tryParse(
                "${currentDate.year}${currentDate.month.leadingZero(2)}") ??
            0;
        final minDateLong = int.tryParse(
                "${widget.minDate?.year ?? currentDate.year}${(widget.minDate?.month ?? currentDate.month).leadingZero(2)}") ??
            0;
        final maxDateLong = int.tryParse(
                "${widget.maxDate?.year ?? currentDate.year}${(widget.maxDate?.month ?? currentDate.month).leadingZero(2)}") ??
            0;

        final availableDate =
            currentDateLong >= minDateLong && currentDateLong <= maxDateLong;

        return Builder(
          builder: (BuildContext context) {
            /// if [index]' boxRect is still null, set post frame callback to
            /// set boxRect after first render
            if (boxRects[index] == null) {
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                final renderBox = context.findRenderObject() as RenderBox?;
                final mainRenderBox =
                    widget.mainContext.findRenderObject() as RenderBox?;
                final offset = renderBox!
                    .localToGlobal(Offset.zero, ancestor: mainRenderBox);
                final size = renderBox.size;
                final rect = Rect.fromLTWH(
                    offset.dx, offset.dy, size.width, size.height);
                boxRects[index] = rect;
              });
            }

            final circularRadius = Radius.circular(
              widget.datePickerTheme.daysHaveCircularBorder ? 100 : 12,
            );

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(circularRadius),
                border: Border.all(color: borderColor),
              ),
              margin: EdgeInsets.all(widget.datePickerTheme.dayPadding),
              child: IgnorePointer(
                ignoring: !availableDate,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      availableDate
                          ? boxColor
                          : Color.lerp(const Color(0xffD1D1D1), boxColor, 0.8),
                    ),
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
                  ),
                  onPressed: () =>
                      _handleMonthBoxTapped(context, index + 1, year),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Text(
                          widget.datePickerTheme
                              .monthsArray[currentDate.month - 1],
                          style: availableDate
                              ? textStyle
                              : textStyle.copyWith(
                                  color: Color.lerp(const Color(0xffD1D1D1),
                                      textStyle.color, 0.5)),
                          maxLines: 1,
                        ),
                      ),
                      _renderMarked(currentDate),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
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

  Widget _buildCalendarLandscape(int slideIndex) {
    final year = _pageDates[slideIndex]!.year;

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      childAspectRatio: widget.datePickerTheme.childAspectRatio,
      padding: EdgeInsets.zero,
      children: List.generate(
        12,
        (index) {
          final currentDate = DateTime(year, index + 1, 1);
          final currentDateInt =
              int.tryParse("$year${(index + 1).leadingZero(2)}") ?? 0;
          final isToday = DateTime.now().month == currentDate.month &&
              DateTime.now().year == currentDate.year;

          final firstDate =
              _selectedDateTimes.isNotEmpty ? _selectedDateTimes.first : null;
          final firstDateInt = _selectedDateTimes.isNotEmpty
              ? int.tryParse(
                      "${firstDate?.year}${firstDate?.month.leadingZero(2)}") ??
                  0
              : 0;

          final lastDate =
              _selectedDateTimes.length == 2 ? _selectedDateTimes.last : null;
          final lastDateInt = _selectedDateTimes.length == 2
              ? int.tryParse(
                      "${lastDate?.year}${lastDate?.month.leadingZero(2)}") ??
                  0
              : 0;

          final isSelectedDay = (widget.selectionType != SelectionType.range &&
                  _selectedDateTimes.isNotEmpty &&
                  _selectedDateTimes
                      .where((loopDate) =>
                          loopDate.month == currentDate.month &&
                          loopDate.year == currentDate.year)
                      .isNotEmpty) ||
              (widget.selectionType == SelectionType.range &&
                  (_selectedDateTimes.length == 2 &&
                      currentDateInt > firstDateInt &&
                      currentDateInt < lastDateInt));

          final isStartEndDay = _selectedDateTimes.isNotEmpty &&
              ((widget.selectionType == SelectionType.range &&
                  (_selectedDateTimes.length == 1 &&
                      _selectedDateTimes.first.month ==
                          currentDate.month &&
                      _selectedDateTimes.first.year ==
                          currentDate.year) ||
                  (_selectedDateTimes.length == 2 &&
                      ((_selectedDateTimes.first.month == currentDate.month &&
                          _selectedDateTimes.first.year ==
                              currentDate.year) ||
                          (_selectedDateTimes.last.month ==
                              currentDate.month &&
                              _selectedDateTimes.last.year ==
                                  currentDate.year)))) ||
                  (widget.selectionType != SelectionType.range &&
                      _selectedDateTimes.isNotEmpty &&
                      _selectedDateTimes
                          .where((loopDate) =>
                      loopDate.month == currentDate.month &&
                          loopDate.year == currentDate.year)
                          .isNotEmpty));

          TextStyle textStyle;
          Color borderColor;

          Color boxColor;
          if (isStartEndDay) {
            textStyle = widget.datePickerTheme.selectedDayTextStyle;
            boxColor = widget.datePickerTheme.selectedColor;
            borderColor = widget.datePickerTheme.thisMonthDayBorderColor;
          } else if (isSelectedDay) {
            textStyle = widget.datePickerTheme.selectedDayTextStyle;
            boxColor = widget.datePickerTheme.selectedColor.withAlpha(150);
            borderColor = widget.datePickerTheme.thisMonthDayBorderColor;
          } else if (isToday) {
            textStyle = widget.datePickerTheme.todayTextStyle;
            boxColor = widget.datePickerTheme.dayButtonColor;
            borderColor = widget.datePickerTheme.todayColor;
          } else {
            textStyle = widget.datePickerTheme.weekdayTextStyle;
            boxColor = widget.datePickerTheme.dayButtonColor;
            borderColor = widget.datePickerTheme.thisMonthDayBorderColor;
          }

          final currentDateLong = int.tryParse(
                  "${currentDate.year}${currentDate.month.leadingZero(2)}") ??
              0;
          final minDateLong = int.tryParse(
                  "${widget.minDate?.year ?? currentDate.year}${(widget.minDate?.month ?? currentDate.month).leadingZero(2)}") ??
              0;
          final maxDateLong = int.tryParse(
                  "${widget.maxDate?.year ?? currentDate.year}${(widget.maxDate?.month ?? currentDate.month).leadingZero(2)}") ??
              0;

          final availableDate =
              currentDateLong >= minDateLong && currentDateLong <= maxDateLong;

          return Builder(
            builder: (BuildContext context) {
              /// if [index]' boxRect is still null, set post frame callback to
              /// set boxRect after first render
              if (boxRects[index] == null) {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  final renderBox = context.findRenderObject() as RenderBox?;
                  final mainRenderBox =
                      widget.mainContext.findRenderObject() as RenderBox?;
                  final offset = renderBox!
                      .localToGlobal(Offset.zero, ancestor: mainRenderBox);
                  final size = renderBox.size;
                  final rect = Rect.fromLTWH(
                      offset.dx, offset.dy, size.width, size.height);
                  boxRects[index] = rect;
                });
              }

              final circularRadius = Radius.circular(
                widget.datePickerTheme.daysHaveCircularBorder ? 100 : 12,
              );

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(circularRadius),
                  border: Border.all(color: borderColor),
                ),
                margin: EdgeInsets.all(widget.datePickerTheme.dayPadding),
                child: IgnorePointer(
                  ignoring: !availableDate,
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        availableDate
                            ? boxColor
                            : Color.lerp(
                                const Color(0xffD1D1D1), boxColor, 0.8),
                      ),
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
                    ),
                    onPressed: () =>
                        _handleMonthBoxTapped(context, index + 1, year),
                    child: Stack(
                      children: <Widget>[
                        Center(
                          child: Text(
                            widget.datePickerTheme
                                .monthsArray[currentDate.month - 1],
                            style: availableDate
                                ? textStyle
                                : textStyle.copyWith(
                                    color: Color.lerp(const Color(0xffD1D1D1),
                                        textStyle.color, 0.5)),
                            maxLines: 1,
                          ),
                        ),
                        _renderMarked(currentDate),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handleSubmitTapped() {
    if (widget.onDayPressed != null) widget.onDayPressed!(_selectedDateTimes);
  }

  void _handleMonthTitleTapped(BuildContext context) {
    /// unless the whole content is fully expanded, cannot tap on title
    if (widget.monthYearAnim.value != 1.0) return;

    final yearMod = _pageDates[1]!.year % 12;
    final boxRect = widget.yearKey.currentState!
        .getBoxRectFromIndex((yearMod == 0 ? 12 : yearMod) - 1);

    final fullRenderBox = context.findRenderObject() as RenderBox?;
    final fullSize = fullRenderBox!.size;
    const fullOffset = Offset.zero;

    final fullRect = Rect.fromLTWH(
        fullOffset.dx, fullOffset.dy, fullSize.width, fullSize.height);

    rectTween = RectTween(begin: boxRect, end: fullRect);

    if (mounted)
      setState(() {
        widget.monthYearAnim.reverse();
      });
  }

  void _handleMonthBoxTapped(BuildContext context, int month, int year) {
    /// check if whether this picker is enabled to pick only month and year
    if (widget.pickType != PickType.month) {
      /// unless the whole content is fully expanded, cannot tap on month
      if (widget.dayMonthAnim.value != 1.0 ||
          widget.dayMonthAnim.status != AnimationStatus.completed) return;
      if (widget.monthYearAnim.value != 1.0 ||
          widget.monthYearAnim.status != AnimationStatus.completed) return;

      final dayState = widget.dayKey.currentState!;

      final monthBoxRenderBox = context.findRenderObject() as RenderBox?;
      final monthBoxSize = monthBoxRenderBox!.size;
      final monthBoxOffset = monthBoxRenderBox.localToGlobal(Offset.zero,
          ancestor: widget.mainContext.findRenderObject());
      final monthBoxRect = Rect.fromLTWH(monthBoxOffset.dx, monthBoxOffset.dy,
          monthBoxSize.width, monthBoxSize.height);

      final fullRenderBox = widget.mainContext.findRenderObject() as RenderBox?;
      final fullSize = fullRenderBox!.size;
      const fullOffset = Offset.zero;
      final fullRect = Rect.fromLTWH(
          fullOffset.dx, fullOffset.dy, fullSize.width, fullSize.height);

      if (dayState.mounted)
        dayState.setState(() {
          dayState.setMonth(month, year);
          dayState.rectTween = RectTween(begin: fullRect, end: monthBoxRect);
          widget.dayMonthAnim.reverse();
        });
    } else {
      //pick month
      final currentDate = DateTime(year, month);

      if (widget.selectionType == SelectionType.single) {
        _selectedDateTimes.clear();
        _selectedDateTimes.add(currentDate);
        if (widget.onDayPressed != null)
          widget.onDayPressed!(_selectedDateTimes);
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

          // if (widget.onDayPressed != null)
          //   widget.onDayPressed!(_selectedDateTimes);
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
    }
  }

  void _setPage({int? page}) {
    /// for initial set
    if (page == null) {
      final date0 = DateTime(DateTime.now().year - 1);
      final date1 = DateTime(DateTime.now().year);
      final date2 = DateTime(DateTime.now().year + 1);

      if (mounted)
        setState(() {
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
        dates[2] = DateTime(dates[0]!.year + 1);
        dates[1] = DateTime(dates[0]!.year);
        dates[0] = DateTime(dates[0]!.year - 1);
        page = page + 1;
      } else if (page == 2) {
        /// next page
        dates[0] = DateTime(dates[2]!.year - 1);
        dates[1] = DateTime(dates[2]!.year);
        dates[2] = DateTime(dates[2]!.year + 1);
        page = page - 1;
      }

      if (mounted)
        setState(() {
          _pageDates = dates;
        });

      /// animate to page right away after reset the values
      _pageCtrl.animateToPage(page,
          duration: const Duration(milliseconds: 1),
          curve: const Threshold(0.0));

      /// set year on [YearCalendar]
      widget.yearKey.currentState!.setYear(_pageDates[1]!.year);
    }
  }

  /// an open method for [DayCalendar] to trigger whenever it itself changes
  /// its month value
  void setMonth(int month, int year) {
    final dates = <DateTime>[
      DateTime(year, month - 1, 1),
      DateTime(year, month, 1),
      DateTime(year, month + 1, 1),
    ];

    if (mounted)
      setState(() {
        _pageDates = dates;
      });
  }

  /// an open method for [DayCalendar] or [YearCalendar] to trigger whenever it
  /// itself changes its month value
  void setYear(int year) {
    final month = _pageDates[1]!.month;
    final dates = <DateTime>[
      DateTime(year - 1, month, 1),
      DateTime(year, month, 1),
      DateTime(year + 1, month, 1),
    ];

    if (mounted)
      setState(() {
        _pageDates = dates;
      });
  }

  void updateSelectedDateTimes(List<DateTime> selectedDateTimes) {
    if (mounted)
      setState(() {
        _selectedDateTimes = selectedDateTimes;
      });

    widget.yearKey.currentState!.updateSelectedDateTimes(selectedDateTimes);
  }

  /// get boxes size by index
  Rect? getBoxRectFromIndex(int index) => boxRects[index];

  Widget buildPicker(BuildContext context) {
    return AdvRow(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          onPressed: () => _setPage(page: 0),
          icon: Icon(
            widget.datePickerTheme.iconPrevious,
            color: widget.datePickerTheme.iconColor,
          ),
        ),
        Builder(builder: (BuildContext childContext) {
          return Expanded(
            child: InkWell(
              child: Container(
                margin: widget.datePickerTheme.headerMargin,
                child: Text(
                  "${_pageDates[1]!.year}",
                  textAlign: TextAlign.center,
                  style: widget.datePickerTheme.headerTextStyle,
                ),
              ),
              onTap: () => _handleMonthTitleTapped(context),
            ),
          );
        }),
        IconButton(
          onPressed: () => _setPage(page: 2),
          icon: Icon(
            widget.datePickerTheme.iconNext,
            color: widget.datePickerTheme.iconColor,
          ),
        ),
      ],
    );
  }
}
