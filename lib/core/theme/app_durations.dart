class AppDurations {
  AppDurations._();

  static const Duration stagger = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration verySlow = Duration(milliseconds: 600);
  static const Duration gauge = Duration(milliseconds: 800);
  static const Duration toast = Duration(seconds: 5);
}
