import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../model/todo.dart';
import '../widgets/dialog_box.dart';
import '../widgets/todo_item.dart';
import '../constants/colours.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ToDo> _todosList = []; //  Empty list
  final _todoController = TextEditingController();
  List<ToDo> _foundItem = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isPastListVisible = true;
  bool _isTodayListVisible = true;

  @override
  void initState() {
    _refreshTodoList();
    super.initState();
  }

  Future<void> _refreshTodoList() async {
    final data = await _dbHelper.getToDos();
    setState(() {
      _todosList = data;
      _foundItem = List.from(data);
      _sortItems();
    });
  }

  void _sortItems() {
    _foundItem.sort((a, b) => a.isDone ? 1 : -1);
  }

  void _saveTask(String taskName, String deadlineAt, String createdAt) async {
    if (taskName.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter a task name",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return; // Exit the function without adding the todo item
    }

    ToDo newTodo = ToDo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      todoText: taskName,
      createdAt: createdAt,
      deadlineAt: deadlineAt,
    );

    // Save the todo with additional data
    await _dbHelper.insertToDo(newTodo);

    _todoController.clear();
    Navigator.of(context).pop();
    _refreshTodoList();
  }

  void _createTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
            taskName: _todoController,
            onSave: _saveTask,
            onCancel: () {
              //  clear text
              _todoController.clear();
              Navigator.of(context).pop();
            });
      },
    );
  }

  void _handleChange(ToDo todo) async {
    todo.isDone = !todo.isDone;
    await _dbHelper.updateToDo(todo);
    await _refreshTodoList();
  }

  void _deleteItem(String id) async {
    await _dbHelper.deleteToDo(id);
    _refreshTodoList();
  }

  void _runSearch(String enteredName) {
    List<ToDo> results = [];
    if (enteredName.isEmpty) {
      results = _todosList;
    } else {
      results = _todosList
          .where((item) =>
              item.todoText!.toLowerCase().contains(enteredName.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundItem = results;
    });
  }

  List<ToDo> getPastTasks() {
    return _foundItem.where((todo) {
      final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
      final DateTime deadlineDate = dateFormat.parse(todo.deadlineAt!);
      final DateTime today = DateTime.now();
      return deadlineDate
          .isBefore(DateTime(today.year, today.month, today.day));
    }).toList();
  }

  List<ToDo> getTodayTasks() {
    return _foundItem.where((todo) {
      final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
      final DateTime deadlineDate = dateFormat.parse(todo.deadlineAt!);
      final DateTime today = DateTime.now();
      return deadlineDate.year == today.year &&
          deadlineDate.month == today.month &&
          deadlineDate.day == today.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              children: [
                searchBox(),
                const SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isPastListVisible = !_isPastListVisible;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Past',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      Icon(
                        _isPastListVisible
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                    ],
                  ),
                ),
                if (_isPastListVisible) taskList(getPastTasks()),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isTodayListVisible = !_isTodayListVisible;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Today',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      Icon(
                        _isTodayListVisible
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                    ],
                  ),
                ),
                if (_isTodayListVisible) todayTaskList(),
              ],
            ),
          ),
          addButton(),
        ],
      ),
    );
  }

  Widget taskList(List<ToDo> tasks) {
    return Flexible(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          ToDo todoo = tasks[index];
          return ToDoItem(
            key: ValueKey(todoo.id),
            todo: todoo,
            onToDoChanged: _handleChange,
            onDeleteItem: _deleteItem,
          );
        },
      ),
    );
  }

  Widget todayTaskList() {
    List<ToDo> tasks = getTodayTasks();
    return Flexible(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        itemCount: tasks.length + 1,
        itemBuilder: (context, index) {
          if (index == tasks.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 70),
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  'Check all completed tasks',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.grey,
                  ),
                ),
              ),
            );
          }
          ToDo todoo = tasks[index];
          return ToDoItem(
            key: ValueKey(todoo.id),
            todo: todoo,
            onToDoChanged: _handleChange,
            onDeleteItem: _deleteItem,
          );
        },
      ),
    );
  }

  Align addButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30, right: 20),
        child: ElevatedButton(
          onPressed: _createTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[300],
            minimumSize: const Size(60, 60),
            elevation: 10,
          ),
          child: const Text(
            '+',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) => _runSearch(value),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: grey),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: lightGrey,
      title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.menu,
              color: Colors.black,
              size: 30,
            ),
            SizedBox(
              height: 40,
              width: 40,
              child: ClipRect(
                child: Icon(
                  Icons.account_circle_outlined,
                  size: 30,
                ),
              ),
            )
          ]),
    );
  }
}
