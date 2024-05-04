class ToDo {
  String? id;
  String? todoText;
  bool isDone;

  ToDo({required this.id, required this.todoText, this.isDone = false});

  static List<ToDo> todoList() {
    return [
      ToDo(id: '01', todoText: 'Exercise', isDone: true),
      ToDo(id: '02', todoText: 'Buy Groceries', isDone: true),
      ToDo(
        id: '03',
        todoText: 'Check Emails',
      ),
      ToDo(
        id: '04',
        todoText: 'Continue yesterday coding',
      ),
      ToDo(
        id: '05',
        todoText: 'Hangout with friends',
      ),
      ToDo(
        id: '06',
        todoText: 'Testing the app',
      ),
      ToDo(
        id: '07',
        todoText: 'Testing 1',
      ),
    ];
  }
}
