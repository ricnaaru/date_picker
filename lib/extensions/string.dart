extension StringExtension on String {
  String repeat(int count) {
    return List.filled(count, this).join();
  }
}
