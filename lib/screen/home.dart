import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../connection/database_helper.dart';
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

  void _sortItems(){
    _foundItem.sort((a,b) => a.isDone ? 1: -1);
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
                allTodosText(),
              ],
            ),
          ),
          listTask(),
          addButton(),
        ],
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

  Positioned listTask() {
    return Positioned(
      top: 120,
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        children: [
          Expanded(
            child: ClipRect(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                itemCount: _foundItem.length +
                    1, // Add 1 for the additional text widget
                itemBuilder: (context, index) {
                  if (index == _foundItem.length) {
                    //  Add text widget
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
                  ToDo todoo = _foundItem[index];
                  return ToDoItem(
                    key: ValueKey(todoo.id),
                    todo: todoo,
                    onToDoChanged: _handleChange,
                    onDeleteItem: _deleteItem,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container allTodosText() {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      alignment: Alignment.centerLeft,
      child: const Text(
        'All Todos',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
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

  void _saveTask() async {
    String? todo = _todoController.text; // Retrieve todo from _todoController
    if (todo.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter a task name",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return; // Exit the function without adding the todo item
    }

    ToDo newTodo = ToDo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      todoText: todo,
    );

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
}
