enum TaskPriority { high, medium, low }

enum TaskStatus { active, completed }

enum TaskSource { manual, eeclass, elearn }

enum RepeatUnit { none, daily, weekly, monthly }

const taskCategories = [
  'Homework',
  'Exam',
  'Organization',
  'Personal',
  'Shopping',
  'Other',
];

extension TaskPriorityLabel on TaskPriority {
  String get label => ['High', 'Medium', 'Low'][index];
}

extension TaskStatusLabel on TaskStatus {
  String get label => ['Active', 'Completed'][index];
}

extension TaskSourceLabel on TaskSource {
  String get label => switch (this) {
    TaskSource.manual => 'Manual',
    TaskSource.eeclass => 'eeclass',
    TaskSource.elearn => 'eLearn',
  };
}

extension RepeatUnitLabel on RepeatUnit {
  String get label => ['Does not repeat', 'Daily', 'Weekly', 'Monthly'][index];
}

// Accept previous versions in saved filters and portable backups.
TaskStatus parseTaskStatus(String value) => switch (value) {
  'todo' || 'inProgress' => TaskStatus.active,
  _ => TaskStatus.values.byName(value),
};
TaskPriority parseTaskPriority(String value) =>
    value == 'urgent' ? TaskPriority.high : TaskPriority.values.byName(value);

const defaultTaskCategoryColors = <String, int>{
  'Homework': 0xFF8B80E8,
  'Exam': 0xFFF28B82,
  'Organization': 0xFFE2AE5C,
  'Personal': 0xFF68BAA9,
  'Shopping': 0xFF6AADE0,
  'Other': 0xFFA6A6B9,
};

enum TaskView { agenda, week, month }
