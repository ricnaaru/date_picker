part of date_picker;

class YearCalendar extends StatefulWidget {
  final BuildContext mainContext;
  final GlobalKey<MonthCalendarState> monthKey;
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

  const YearCalendar({
    required this.isLandscape,
    required this.mainContext,
    Key? key,
    required this.monthKey,
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
  YearCalendarState createState() => YearCalendarState();
}

class YearCalendarState extends State<YearCalendar>
    with SingleTickerProviderStateMixin {
  /// The first run, this will be hidden (1.0 [widget.monthYearAnim]'s value)
  ///
  /// When the [MonthCalendar]'s title is tapped [_handleMonthTitleTapped],
  /// we will give this the fade in animation ([widget.monthYearAnim]'s value
  /// will gradually change from 1.0 to 0.0)
  ///
  /// When one of this' boxes is tapped [_handleYearBoxTapped], we will give
  /// this the fade out animation ([widget.dayMonthAnim]'s value will gradually
  /// change from 0.0 to 1.0)
  ///
  late PageController _pageCtrl;

  /// Start Date from each page
  /// the selected page is on index 1,
  /// 0 is for previous 12 years,
  /// 2 is for next 12 years
  List<DateTime?> _pageDates = List<DateTime?>.filled(3, null);

  /// Selected DateTime
  List<DateTime> _selectedDateTimes = [];

  /// Marks whether the date range [SelectionType.range] is selected on both ends
  bool _selectRangeIsComplete = false;

  /// Array for each boxes position and size
  ///
  /// each boxes position and size is stored for the first time and after they
  /// are rendered, since their size and position at full extension is always
  /// the same. Later will be used by [MonthCalender] to squeezed its whole content
  /// as big as one of these boxes and in its position, according to its year
  /// value
  List<Rect?> boxRects = List<Rect?>.filled(12, null);

  /// Opacity controller for this
  ///
  /// This Opacity Controller is kinda different from [MonthCalendar]'s
  /// Since this AnimationController's value is reversed from [MonthCalendar]
  /// Explanation:
  /// [MonthCalendar.dayMonthAnim]'s 0.0 value would mean hidden for [MonthCalendar]
  /// and
  /// [MonthCalendar.dayMonthAnim]'s 1.0 value would mean shown for [MonthCalendar]
  ///
  /// therefore
  ///
  /// [MonthCalendar.opacityCtrl]'s 0.0 value would mean hidden for [MonthCalendar]
  /// and
  /// [MonthCalendar.opacityCtrl]'s 1.0 value would mean shown for [MonthCalendar]
  ///
  /// in order for [MonthCalendar]'s title can be tapped, it has to be in its full
  /// extension size ([MonthCalendar.opacityCtrl]'s 1.0 value) and when
  /// [MonthCalendar]'s title is tapped (_handleMonthTitleTapped), it has to reverse
  /// [MonthCalendar.opacityCtrl]'s value from 1.0 to 0.0, and if we link it to
  /// [MonthCalendar.monthYearCtrl] which is [this.monthYearCtrl] also,
  /// 0.0 would mean shown for this, thus, 1.0 would mean hidden.
  ///
  /// therefore
  ///
  /// this' opacity would be [1.0 - opacityCtrl.value]
  late AnimationController opacityCtrl;

  @override
  void initState() {
    super.initState();

    /// if the [pickType] is year, then show this as front page,
    /// (there will be no [DayCalendar] and [MonthCalendar], otherwise,
    /// hide this and wait until [MonthCalendar] request to be shown
    ///
    /// See [_handleMonthTitleTapped]
    opacityCtrl = AnimationController(
        duration: const Duration(milliseconds: _kAnimationDuration),
        vsync: this,
        value: widget.pickType == PickType.year ? 0.0 : 1.0);

    /// Change opacity controller's value equals month year controller's value
    widget.monthYearAnim.addListener(() {
      opacityCtrl.value = widget.monthYearAnim.value;
    });

    _selectedDateTimes = widget.selectedDateTimes;

    _selectRangeIsComplete = widget.selectionType == SelectionType.range &&
        _selectedDateTimes.length % 2 == 0;

    /// setup pageController
    _pageCtrl = PageController(
      initialPage: 1,
      keepPage: true,
      viewportFraction: widget.datePickerTheme.viewportFraction,

      /// width percentage
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
    return AnimatedBuilder(
      animation: opacityCtrl,
      builder: (BuildContext parentContext, Widget? child) {
        /// this opacity is kinda different from [MonthCalendar]
        ///
        /// See [opacityCtrl]
        return Opacity(
          opacity: 1.0 - opacityCtrl.value,
          child: widget.isLandscape
              ? _buildYearContentLandscape(context)
              : _buildYearContentPortrait(context),
        );
      },
    );
  }

  Widget _buildCalendar(int slideIndex) {
    final year = _pageDates[slideIndex]!.year;
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      childAspectRatio: widget.datePickerTheme.childAspectRatio,
      padding: EdgeInsets.zero,
      children: List.generate(
        12,
        (index) {
          final isToday = DateTime.now().year == year + index + 1;
          final currentDate = DateTime(year + index + 1);
          final isSelectedDay = (widget.selectionType != SelectionType.range &&
                  _selectedDateTimes.isNotEmpty &&
                  _selectedDateTimes
                      .where((loopDate) => loopDate.year == currentDate.year)
                      .isNotEmpty) ||
              (widget.selectionType == SelectionType.range &&
                  _selectedDateTimes.length == 2 &&
                  currentDate.year > _selectedDateTimes.first.year &&
                  currentDate.year < _selectedDateTimes.last.year);
          final isStartEndDay = _selectedDateTimes.isNotEmpty &&
              ((widget.selectionType == SelectionType.range &&
                      ((_selectedDateTimes.first.year == currentDate.year) ||
                          (_selectedDateTimes.last.year ==
                              currentDate.year))) ||
                  (widget.selectionType != SelectionType.range &&
                      _selectedDateTimes.isNotEmpty &&
                      _selectedDateTimes
                          .where(
                              (loopDate) => loopDate.year == currentDate.year)
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

          final availableDate = currentDate.year >=
                  (widget.minDate?.year ?? currentDate.year) &&
              currentDate.year <= (widget.maxDate?.year ?? currentDate.year);

          final fixedTextStyle =
              isToday ? widget.datePickerTheme.todayTextStyle : textStyle;

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
                                const Color(0xffD1D1D1),
                                boxColor,
                                0.8,
                              ),
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
                        _handleYearBoxTapped(context, currentDate.year),
                    child: Stack(
                      children: <Widget>[
                        Center(
                          child: Text(
                            "${currentDate.year}",
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

  Widget _buildMarkedDates() {
    final fromYear = _pageDates[1]!.year + 1;
    final toYear = _pageDates[1]!.year + 12;
    return Column(
      children: [
        Visibility(
            visible: widget.markedDates
                .where((markedDate) =>
                    markedDate.date.year >= fromYear &&
                    markedDate.date.year <= toYear)
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
                .where((markedDate) =>
                    markedDate.date.year >= fromYear &&
                    markedDate.date.year <= toYear)
                .toList()
                .map(
              (markedDate) {
                return MarkedDateWidget(
                  markedDate: markedDate,
                  style: widget.datePickerTheme.markedDaysTextStyle,
                  showYear: true,
                );
              },
            ).toList(),
          ),
        ),
      ],
    );
  }

  void _handleSubmitTapped() {
    if (widget.onDayPressed != null) widget.onDayPressed!(_selectedDateTimes);
  }

  void _handleYearBoxTapped(BuildContext context, int year) {
    /// check if whether this picker is enabled to pick only year
    if (widget.pickType != PickType.year) {
      /// unless the whole content is shown, cannot tap on year
      if (widget.monthYearAnim.value != 0.0 ||
          widget.monthYearAnim.status != AnimationStatus.dismissed) return;

      final monthState = widget.monthKey.currentState!;

      final yearBoxRenderBox = context.findRenderObject() as RenderBox?;
      final yearBoxSize = yearBoxRenderBox!.size;
      final yearBoxOffset = yearBoxRenderBox.localToGlobal(Offset.zero,
          ancestor: widget.mainContext.findRenderObject());
      final yearBoxRect = Rect.fromLTWH(yearBoxOffset.dx, yearBoxOffset.dy,
          yearBoxSize.width, yearBoxSize.height);

      final fullRenderBox = widget.mainContext.findRenderObject() as RenderBox?;
      const fullOffset = Offset.zero;
      final fullSize = fullRenderBox!.size;
      final fullRect = Rect.fromLTWH(
          fullOffset.dx, fullOffset.dy, fullSize.width, fullSize.height);

      monthState.setState(() {
        monthState.setYear(year);
        monthState.rectTween = RectTween(begin: yearBoxRect, end: fullRect);
        widget.monthYearAnim.forward();
      });
    } else {
      //pick year
      final currentDate = DateTime(year);
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

      setState(() {});
    }
  }

  void _setPage({int? page}) {
    /// for initial set
    if (page == null) {
      final year = (DateTime.now().year / 12).floor();

      final date0 = DateTime((year - 1) * 12);
      final date1 = DateTime(year * 12);
      final date2 = DateTime((year + 1) * 12);

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
        final year = (dates[0]!.year / 12).floor();
        if (year < 0) return;
        dates[2] = DateTime((year + 1) * 12);
        dates[1] = DateTime(year * 12);
        dates[0] = DateTime((year - 1) * 12);
        page = page + 1;
      } else if (page == 2) {
        /// next page
        final year = (dates[2]!.year / 12).floor();
        dates[0] = DateTime((year - 1) * 12);
        dates[1] = DateTime(year * 12);
        dates[2] = DateTime((year + 1) * 12);
        page = page - 1;
      }

      setState(() {
        _pageDates = dates;
      });

      /// animate to page right away after reset the values
      _pageCtrl.animateToPage(page,
          duration: const Duration(milliseconds: 1),
          curve: const Threshold(0.0));
    }
  }

  /// an open method for [MonthCalendar] to trigger whenever it itself changes
  /// its year value
  void setYear(int year) {
    final pageYear = (year / 12).floor();

    final dates = <DateTime>[
      DateTime((pageYear - 1) * 12),
      DateTime(pageYear * 12),
      DateTime((pageYear + 1) * 12),
    ];

    setState(() {
      _pageDates = dates;
    });
  }

  void updateSelectedDateTimes(List<DateTime> selectedDateTimes) {
    setState(() {
      _selectedDateTimes = selectedDateTimes;
    });
  }

  /// get boxes size by index
  Rect? getBoxRectFromIndex(int index) => boxRects[index];

  Widget buildPicker(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: DefaultTextStyle(
        style: widget.datePickerTheme.headerTextStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: () => _setPage(page: 0),
              icon: Icon(
                widget.datePickerTheme.iconPrevious,
                color: widget.datePickerTheme.iconColor,
              ),
            ),
            Text(
              "${_pageDates[1]!.year + 1} - ${_pageDates[1]!.year + 12}",
            ),
            IconButton(
              onPressed: () => _setPage(page: 2),
              icon: Icon(
                widget.datePickerTheme.iconNext,
                color: widget.datePickerTheme.iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearContentLandscape(BuildContext context) {
    return AdvRow(
      divider: const RowDivider(16),
      children: <Widget>[
        Expanded(
          child: PageView.builder(
            itemCount: 3,
            onPageChanged: (value) {
              _setPage(page: value);
            },
            controller: _pageCtrl,
            itemBuilder: (context, index) {
              return _buildCalendar(index);
            },
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              buildPicker(context),
              Expanded(child: _buildMarkedDates()),
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

  Widget _buildYearContentPortrait(BuildContext context) {
    return Column(
      children: <Widget>[
        buildPicker(context),
        Expanded(
          child: PageView.builder(
            itemCount: 3,
            onPageChanged: (value) {
              _setPage(page: value);
            },
            controller: _pageCtrl,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  _buildCalendar(index),
                  Expanded(child: _buildMarkedDates()),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
