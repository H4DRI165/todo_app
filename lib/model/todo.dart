class ToDo {
  String? id;
  String? todoText;
  bool isDone;
  String? createdAt;
  String? deadlineAt;
  String? finishedAt;

  ToDo({
    required this.id,
    required this.todoText,
    this.isDone = false,
    this.createdAt,
    this.deadlineAt,
    this.finishedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'todoText': todoText,
      'isDone': isDone ? 1 : 0,
      'createdAt' : createdAt,
      'deadlineAt' : deadlineAt,
      'finishedAt' : null,
    };
  }

  @override
  String toString() {
    return 'ToDo{id: $id, todoText: $todoText, isDone: $isDone, createdAt: $createdAt, deadlineAt: $deadlineAt, finishedAt: $finishedAt}';
  }
}
