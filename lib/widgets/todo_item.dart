import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/todo.dart';
import '../constants/colours.dart';

class ToDoItem extends StatelessWidget {
  final ToDo todo;
  final Function(ToDo) onToDoChanged;
  final onDeleteItem;
  final String? deadlineAt;

  const ToDoItem({
    super.key,
    required this.todo,
    required this.onToDoChanged,
    required this.onDeleteItem,
    this.deadlineAt,
  });

  String truncateWithEllipsis(String text, int maxLength) {
    return text.length <= maxLength
        ? text
        : '${text.substring(0, maxLength)}...';
  }

  // Function to check if the deadline date is past
  bool isPastDeadline(String deadline) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final DateTime deadlineDate = dateFormat.parse(deadline);
    final DateTime today = DateTime.now();

    // Check if the deadline date is before today, considering only the date part
    return deadlineDate.isBefore(DateTime(today.year, today.month, today.day));
  }

  @override
  Widget build(BuildContext context) {
    //  Determine the text colour based on the deadline date
    final Color deadlineColor =
        isPastDeadline(todo.deadlineAt!) ? Colors.red : grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 5, left: 20, right: 10),
      child: ClipRect(
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          tileColor: lightGrey,
          leading: GestureDetector(
            onTap: () {
              onToDoChanged(todo); // Apply onToDoChange only to the checkbox
            },
            child: Icon(
              size: 30,
              todo.isDone ? Icons.check_box : Icons.check_box_outline_blank,
              color: blue,
            ),
          ),
          title: GestureDetector(
            onTap: () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  truncateWithEllipsis(todo.todoText!, 22),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 16,
                    color: black,
                    decoration: todo.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  todo.deadlineAt!, // Replace with your actual text
                  style: TextStyle(
                    fontSize: 10,
                    color: deadlineColor, // Customize the color if needed
                  ),
                ),
              ],
            ),
          ),
          trailing: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(0),
              margin: const EdgeInsets.symmetric(vertical: 1),
              height: 28,
              width: 30,
              decoration: BoxDecoration(
                color: red,
                borderRadius: BorderRadius.circular(5),
              ),
              child: IconButton(
                color: Colors.white,
                iconSize: 15,
                icon: const Icon(Icons.delete),
                onPressed: () {
                  onDeleteItem(todo.id);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
