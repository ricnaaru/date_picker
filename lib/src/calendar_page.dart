part of date_picker;

enum SelectionType { single, multi, range }

class MarkedDate {
  final DateTime date;
  final String note;

  const MarkedDate(this.date, this.note);
}

class CalendarPage extends StatefulWidget {
  final String? title;
  final List<DateTime>? currentDate;
  final List<MarkedDate> markedDates;
  final SelectionType selectionType;
  final PickType pickType;
  final DateTime? minDate;
  final DateTime? maxDate;

  const CalendarPage({
    Key? key,
    this.title,
    this.currentDate,
    this.markedDates = const [],
    this.selectionType = SelectionType.single,
    this.pickType = PickType.day,
    this.minDate,
    this.maxDate,
  }) : super(key: key);

  @override
  State createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with SingleTickerProviderStateMixin {
  late List<DateTime> _currentDate;
  late SelectionType _selectionType;
  late PickType _pickType;
  bool _datePicked = false;

  @override
  void initState() {
    super.initState();
    _selectionType = widget.selectionType;
    _pickType = widget.pickType;
    _currentDate = widget.currentDate ?? [DateTime.now()];
  }

  @override
  Widget build(BuildContext context) {
    return AdvScaffold(
      appBar: AppBar(
        title: Text(widget.title ?? ""),
        elevation: 1.0,
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        child: CalendarCarousel(
          pickType: _pickType,
          selectionType: _selectionType,
          onDayPressed: (List<DateTime> dates) async {
            if (_datePicked) return;
            _datePicked = true;
            setState(() => _currentDate = dates);
            Navigator.pop(context, _currentDate);
          },
          selectedDateTimes: _currentDate,
          markedDates: widget.markedDates,
          minDate: widget.minDate,
          maxDate: widget.maxDate,
        ),
      ),
    );
  }
}
