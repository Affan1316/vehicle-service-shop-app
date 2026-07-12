class TimelineEvent {
  final String title;
  final DateTime date;
  final String description;
  final String? amount;
  final String type; // 'payment', 'work_order', 'quote', 'appointment', 'check_in'
  final String status;

  const TimelineEvent({
    required this.title,
    required this.date,
    required this.description,
    this.amount,
    required this.type,
    required this.status,
  });
}
