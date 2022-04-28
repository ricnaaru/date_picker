import 'dart:ui' as ui;

import 'package:date_picker/date_picker.dart';
import 'package:date_picker/ui/common/adv_row.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MarkedDateWidget extends StatelessWidget {
  final MarkedDate markedDate;
  final TextStyle style;
  final bool showYear;

  const MarkedDateWidget({
    Key? key,
    required this.markedDate,
    required this.style,
    this.showYear = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final df = DateFormat("dd MMM${showYear ? " yyyy" : ""}");
    final markedDateString = df.format(markedDate.date);
    final tp2 = TextPainter(
      text: TextSpan(text: "9", style: style),
      textDirection: ui.TextDirection.ltr,
    );

    tp2.layout();

    return AdvRow(
      crossAxisAlignment: CrossAxisAlignment.start,
      divider: const Text(" - "),
      children: [
        Row(
          children: List.generate(
            markedDateString.length,
            (index) => SizedBox(
              child: Center(
                child: Text(
                  markedDateString[index],
                  textAlign: TextAlign.center,
                  style: style,
                ),
              ),
              width: markedDateString[index] == " " ? 4 : tp2.width,
            ),
          ),
        ),
        Expanded(
          child: Text(
            markedDate.note,
            style: style,
          ),
        )
      ],
    );
  }
}
