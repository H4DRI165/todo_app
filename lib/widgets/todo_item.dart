import 'package:flutter/material.dart';
import '../model/todo.dart';
import '../constants/colours.dart';

class ToDoItem extends StatelessWidget {
  final ToDo todo;
  final Function(ToDo) onToDoChanged;
  final onDeleteItem;
  final ShapeBorder? shape;

  const ToDoItem({
    super.key,
    required this.todo,
    required this.onToDoChanged,
    required this.onDeleteItem,
    this.shape,
  });

  String truncateWithEllipsis(String text, int maxLength) {
    return text.length <= maxLength
        ? text
        : '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5, left: 20, right: 10),
      child: ClipRect(
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          tileColor: lightGrey,
          leading: GestureDetector(
            onTap: (){
              onToDoChanged(todo); // Apply onToDoChange only to the checkbox
            },
            child: Icon(
              todo.isDone ? Icons.check_box : Icons.check_box_outline_blank,
              color: blue,
            ),
          ),
          title: GestureDetector(
            onTap: (){},
            child: Text(
              truncateWithEllipsis(todo.todoText!, 22),
              maxLines: 1,
              style: TextStyle(
                fontSize: 16,
                color: black,
                decoration: todo.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          trailing: GestureDetector(
            onTap: (){},
            child: Container(
              padding: const EdgeInsets.all(0),
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                color: red,
                borderRadius: BorderRadius.circular(5),
              ),
              child: IconButton(
                color: Colors.white,
                iconSize: 18,
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
