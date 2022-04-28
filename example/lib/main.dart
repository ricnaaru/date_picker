import 'package:date_picker/date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Date picker demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final markedDates = [
    MarkedDate(DateTime(2022, 1, 1), "Global Family Day"),
    MarkedDate(DateTime(2022, 1, 4), "World Braille Day"),
    MarkedDate(DateTime(2022, 1, 11), "International Thank-You Day"),
    MarkedDate(DateTime(2022, 1, 30), "World Leprosy Day"),
    MarkedDate(DateTime(2022, 2, 12), "Darwin Day"),
    MarkedDate(DateTime(2022, 2, 21), "International Mother Language Day"),
    MarkedDate(DateTime(2022, 2, 22), "World Thinking Day"),
    MarkedDate(DateTime(2022, 3, 1), "International Day of the Seal"),
    MarkedDate(DateTime(2022, 3, 8), "International Women's Day"),
    MarkedDate(DateTime(2022, 3, 20), "World Frog Day"),
    MarkedDate(DateTime(2022, 3, 21), "World Down Syndrome Day"),
    MarkedDate(DateTime(2022, 3, 22), "World Water Day"),
    MarkedDate(DateTime(2022, 3, 23), "World Meteorological Day"),
    MarkedDate(DateTime(2022, 3, 24), "World TB Day"),
    MarkedDate(DateTime(2022, 3, 26), "Earth Hour"),
    MarkedDate(DateTime(2022, 4, 2), "International Children's Book Day"),
    MarkedDate(DateTime(2022, 4, 7), "World Health Day"),
    MarkedDate(DateTime(2022, 4, 12), "Yuri's Night"),
    MarkedDate(DateTime(2022, 4, 16), "International Special Librarians Day"),
    MarkedDate(
        DateTime(2022, 4, 21), "International Creativity and Innovation Day"),
    MarkedDate(DateTime(2022, 4, 22), "Earth Day"),
    MarkedDate(DateTime(2022, 4, 23), "World Book Day"),
    MarkedDate(DateTime(2022, 4, 25), "World Penguin Day"),
    MarkedDate(DateTime(2022, 4, 25), "World Malaria Day"),
    MarkedDate(DateTime(2022, 5, 3), "World Press Freedom Day"),
    MarkedDate(DateTime(2022, 5, 5), "International Midwives Day"),
    MarkedDate(DateTime(2022, 5, 8), "World Red Cross Day"),
    MarkedDate(DateTime(2022, 5, 10), "World Lupus Day"),
    MarkedDate(DateTime(2022, 5, 12), "International Nurses Day"),
    MarkedDate(DateTime(2022, 5, 13), "IEEE Global Engineering Day"),
    MarkedDate(DateTime(2022, 5, 15), "International Day of Families"),
    MarkedDate(DateTime(2022, 5, 17), "World Hypertension Day"),
    MarkedDate(DateTime(2022, 5, 18), "International Museum Day"),
    MarkedDate(DateTime(2022, 5, 21), "World Day for Cultural Diversity"),
    MarkedDate(
        DateTime(2022, 5, 22), "International Day for Biological Diversity"),
    MarkedDate(DateTime(2022, 5, 23), "World Turtle Day"),
    MarkedDate(DateTime(2022, 5, 24), "World Schizophrenia Day"),
    MarkedDate(DateTime(2022, 5, 25), "Towel Day"),
    MarkedDate(DateTime(2022, 5, 31), "World No-Tobacco Day"),
    MarkedDate(DateTime(2022, 6, 1), "World Milk Day"),
    MarkedDate(DateTime(2022, 6, 3), "World Bicycle Day"),
    MarkedDate(DateTime(2022, 6, 5), "World Environment Day"),
    MarkedDate(DateTime(2022, 6, 8), "World Ocean Day"),
    MarkedDate(DateTime(2022, 6, 14), "World Blood Donor Day"),
    MarkedDate(DateTime(2022, 6, 16), "International Day of the African Child"),
    MarkedDate(
        DateTime(2022, 6, 17), "World Day to Combat Desertification & Drought"),
    MarkedDate(DateTime(2022, 6, 20), "World Refugee Day"),
    MarkedDate(DateTime(2022, 6, 21), "International Yoga Day"),
    MarkedDate(DateTime(2022, 6, 26),
        "International Day Against Drug Abuse and Trafficking"),
    MarkedDate(DateTime(2022, 7, 11), "World Population Day"),
    MarkedDate(DateTime(2022, 7, 16), "World Snake Day"),
    MarkedDate(DateTime(2022, 7, 28), "World Hepatitis Day"),
    MarkedDate(DateTime(2022, 8, 7), "International Friendship Day"),
    MarkedDate(DateTime(2022, 8, 8), "Universal & International Infinity Day"),
    MarkedDate(DateTime(2022, 8, 9),
        "International Day of the World's Indigenous People"),
    MarkedDate(DateTime(2022, 8, 10), "International Biodiesel Day"),
    MarkedDate(DateTime(2022, 8, 12), "International Youth Day"),
    MarkedDate(DateTime(2022, 8, 13), "International Lefthanders Day"),
    MarkedDate(DateTime(2022, 8, 14), "World Lizard Day"),
    MarkedDate(DateTime(2022, 8, 23),
        "International Day for the Remembrance of the Slave Trade & its Abolition"),
    MarkedDate(DateTime(2022, 9, 8), "International Literacy Day"),
    MarkedDate(DateTime(2022, 9, 13), "International Chocolate Day"),
    MarkedDate(DateTime(2022, 9, 15), "Software Freedom Day"),
    MarkedDate(DateTime(2022, 9, 15), "International Day of Democracy"),
    MarkedDate(DateTime(2022, 9, 16),
        "International Day for the Preservation of the Ozone Layer"),
    MarkedDate(DateTime(2022, 9, 19), "Talk Like a Pirate Day"),
    MarkedDate(DateTime(2022, 9, 21), "World Gratitude Day"),
    MarkedDate(DateTime(2022, 9, 22), "World Car-Free Day"),
    MarkedDate(DateTime(2022, 9, 29), "Inventors Day"),
    MarkedDate(DateTime(2022, 9, 29), "World Heart Day"),
    MarkedDate(DateTime(2022, 10, 1), "International Music Day"),
    MarkedDate(DateTime(2022, 10, 1), "World Ballet Day"),
    MarkedDate(DateTime(2022, 10, 2), "World Farm Animals Day"),
    MarkedDate(DateTime(2022, 10, 3), "World Temperance Day"),
    MarkedDate(DateTime(2022, 10, 4), "World Animal Day"),
    MarkedDate(DateTime(2022, 10, 5), "World Teacher's Day"),
    MarkedDate(DateTime(2022, 10, 10), "World Mental Health Day"),
    MarkedDate(DateTime(2022, 10, 16), "World Food Day"),
    MarkedDate(DateTime(2022, 10, 17),
        "International Day for the Eradication of Poverty"),
    MarkedDate(DateTime(2022, 10, 24), "United Nations Day"),
    MarkedDate(DateTime(2022, 10, 29), "International Internet Day"),
    MarkedDate(DateTime(2022, 11, 8), "World Town Planning Day"),
    MarkedDate(DateTime(2022, 11, 14), "World Diabetes Day"),
    MarkedDate(DateTime(2022, 11, 16), "International Day for Tolerance"),
    MarkedDate(DateTime(2022, 11, 19), "World Toilet Day"),
    MarkedDate(DateTime(2022, 11, 21), "World Television Day"),
    MarkedDate(DateTime(2022, 11, 25),
        "International Day for the Elimination of Violence Against Women"),
    MarkedDate(DateTime(2022, 11, 30), "International Computer Security Day"),
    MarkedDate(DateTime(2022, 12, 1), "World Aids Day"),
    MarkedDate(DateTime(2022, 12, 2),
        "International Day for the Abolition of Slavery"),
    MarkedDate(DateTime(2022, 12, 5), "International Volunteers Day"),
    MarkedDate(DateTime(2022, 12, 7), "International Civil Aviation Day"),
    MarkedDate(DateTime(2022, 12, 10), "Human Rights Day"),
  ];

  @override
  Widget build(BuildContext context) {
    final dayDf = DateFormat("d MMM yyyy");
    final monthDf = DateFormat("MMM yyyy");
    final yearDf = DateFormat("yyyy");

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DatePicker(
            label: "Single DAY picker",
            pickType: PickType.day,
            selectionType: SelectionType.single,
            markedDates: markedDates,
            interpreter: (List<DateTime> dates) {
              if (dates.isEmpty) return "";

              return dayDf.format(dates.first);
            },
          ),
          DatePicker(
            label: "Range DAY picker",
            pickType: PickType.day,
            selectionType: SelectionType.range,
            markedDates: markedDates,
            interpreter: (List<DateTime> dates) {
              if (dates.isEmpty) return "";

              return dates.map((e) => dayDf.format(e)).join(" - ");
            },
          ),
          DatePicker(
            label: "Multi DAY picker",
            pickType: PickType.day,
            selectionType: SelectionType.multi,
            markedDates: markedDates,
            interpreter: (List<DateTime> dates) {
              if (dates.isEmpty) return "";

              return dates.map((e) => dayDf.format(e)).join(", ");
            },
          ),
          DatePicker(
            label: "Single MONTH picker",
            pickType: PickType.month,
            selectionType: SelectionType.single,
            markedDates: markedDates,
            interpreter: (List<DateTime> dates) {
              if (dates.isEmpty) return "";

              return monthDf.format(dates.first);
            },
          ),
          DatePicker(
            label: "Range MONTH picker",
            pickType: PickType.month,
            selectionType: SelectionType.range,
            markedDates: markedDates,
            interpreter: (List<DateTime> dates) {
              if (dates.isEmpty) return "";

              return dates.map((e) => monthDf.format(e)).join(" - ");
            },
          ),
          DatePicker(
            label: "Multi MONTH picker",
            pickType: PickType.month,
            selectionType: SelectionType.multi,
            markedDates: markedDates,
            interpreter: (List<DateTime> dates) {
              if (dates.isEmpty) return "";

              return dates.map((e) => monthDf.format(e)).join(", ");
            },
          ),
          DatePicker(
            label: "Single YEAR picker",
            pickType: PickType.year,
            selectionType: SelectionType.single,
            markedDates: markedDates,
            interpreter: (List<DateTime> dates) {
              if (dates.isEmpty) return "";

              return yearDf.format(dates.first);
            },
          ),
          DatePicker(
            label: "Range YEAR picker",
            pickType: PickType.year,
            selectionType: SelectionType.range,
            markedDates: markedDates,
            interpreter: (List<DateTime> dates) {
              if (dates.isEmpty) return "";

              return dates.map((e) => yearDf.format(e)).join(" - ");
            },
          ),
          DatePicker(
            label: "Multi YEAR picker",
            pickType: PickType.year,
            selectionType: SelectionType.multi,
            markedDates: markedDates,
            interpreter: (List<DateTime> dates) {
              if (dates.isEmpty) return "";

              return dates.map((e) => yearDf.format(e)).join(", ");
            },
          ),
        ],
      ),
    );
  }
}
