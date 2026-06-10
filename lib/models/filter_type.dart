enum FilterType { all, pending, completed, today, overdue }

extension FilterTypeExtension on FilterType {
  String get label {
    switch (this) {
      case FilterType.all:
        return 'Tất cả';
      case FilterType.pending:
        return 'Chưa xong';
      case FilterType.completed:
        return 'Hoàn thành';
      case FilterType.today:
        return 'Hôm nay';
      case FilterType.overdue:
        return 'Quá hạn';
    }
  }
}
