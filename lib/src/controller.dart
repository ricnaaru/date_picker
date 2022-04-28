part of date_picker;

class ApDatePickerController extends ValueNotifier<ApDatePickerValue> {
  DateTime? get date => value.date;

  set date(DateTime? newDate) {
    value = value.copyWith(
      date: newDate,
      minDate: minDate,
      maxDate: maxDate,
      dates: dates,
      error: error,
      enabled: enabled,
      obscureText: obscureText,
    );
  }

  DateTime? get minDate => value.minDate;

  set minDate(DateTime? newMinDate) {
    value = value.copyWith(
      date: date,
      minDate: newMinDate,
      maxDate: maxDate,
      dates: dates,
      error: error,
      enabled: enabled,
      obscureText: obscureText,
    );
  }

  DateTime? get maxDate => value.maxDate;

  set maxDate(DateTime? newMaxDate) {
    value = value.copyWith(
      date: date,
      minDate: minDate,
      maxDate: newMaxDate,
      dates: dates,
      error: error,
      enabled: enabled,
      obscureText: obscureText,
    );
  }

  List<DateTime>? get dates => value.dates;

  set dates(List<DateTime>? newDates) {
    value = value.copyWith(
      date: date,
      minDate: minDate,
      maxDate: maxDate,
      dates: newDates,
      error: error,
      enabled: enabled,
      obscureText: obscureText,
    );
  }

  String? get error => value.error;

  set error(String? newError) {
    value = value.copyWith(
      date: date,
      minDate: minDate,
      maxDate: maxDate,
      dates: dates,
      error: newError,
      enabled: enabled,
      obscureText: obscureText,
    );
  }

  bool get enabled => value.enabled;

  set enabled(bool newEnabled) {
    value = value.copyWith(
      date: date,
      minDate: minDate,
      maxDate: maxDate,
      dates: dates,
      error: error,
      enabled: newEnabled,
      obscureText: obscureText,
    );
  }

  bool get obscureText => value.obscureText;

  set obscureText(bool newObscureText) {
    value = value.copyWith(
      date: date,
      minDate: minDate,
      maxDate: maxDate,
      dates: dates,
      error: error,
      enabled: enabled,
      obscureText: newObscureText,
    );
  }

  ApDatePickerController({
    DateTime? date,
    DateTime? minDate,
    DateTime? maxDate,
    List<DateTime>? dates,
    String? error,
    bool? enabled,
    bool? obscureText,
  }) : super(
          date == null &&
                  minDate == null &&
                  maxDate == null &&
                  dates == null &&
                  error == null &&
                  enabled == null &&
                  obscureText == null
              ? ApDatePickerValue.empty
              : ApDatePickerValue(
                  date: date,
                  minDate: minDate,
                  maxDate: maxDate,
                  dates: dates,
                  error: error,
                  enabled: enabled ?? true,
                  obscureText: obscureText ?? false,
                ),
        );

  ApDatePickerController.fromValue(ApDatePickerValue? value)
      : super(value ?? ApDatePickerValue.empty);

  void clear() {
    value = ApDatePickerValue.empty;
  }
}

@immutable
class ApDatePickerValue {
  const ApDatePickerValue({
    this.date,
    this.minDate,
    this.maxDate,
    this.dates,
    this.error,
    this.enabled = true,
    this.obscureText = false,
  });

  final DateTime? date;
  final DateTime? minDate;
  final DateTime? maxDate;
  final List<DateTime>? dates;
  final String? error;
  final bool enabled;
  final bool obscureText;

  static const ApDatePickerValue empty = ApDatePickerValue();

  ApDatePickerValue copyWith({
    DateTime? date,
    DateTime? minDate,
    DateTime? maxDate,
    List<DateTime>? dates,
    String? error,
    bool enabled = true,
    bool obscureText = false,
  }) {
    return ApDatePickerValue(
      date: date,
      minDate: minDate,
      maxDate: maxDate,
      dates: dates,
      error: error,
      enabled: enabled,
      obscureText: obscureText,
    );
  }

  ApDatePickerValue.fromValue(ApDatePickerValue copy)
      : date = copy.date,
        minDate = copy.minDate,
        maxDate = copy.maxDate,
        dates = copy.dates,
        error = copy.error,
        enabled = copy.enabled,
        obscureText = copy.obscureText;

  @override
  String toString() =>
      "$runtimeType(date: \u2524$date\u251C, minDate: \u2524$minDate\u251C, maxDate: \u2524$maxDate\u251C, dates: $dates, error: \u2524$error\u251C, enabled: $enabled, obscureText: $obscureText)";

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! ApDatePickerValue) return false;
    return other.date == date &&
        other.minDate == minDate &&
        other.maxDate == maxDate &&
        other.dates == dates &&
        other.error == error &&
        other.enabled == enabled &&
        other.obscureText == obscureText;
  }

  @override
  int get hashCode => hashValues(
      date.hashCode,
      minDate.hashCode,
      maxDate.hashCode,
      dates.hashCode,
      error.hashCode,
      enabled.hashCode,
      obscureText.hashCode);
}
