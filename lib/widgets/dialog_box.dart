import 'package:flutter/material.dart';
import 'package:todo_app/constants/colours.dart';

import 'button.dart';

class DialogBox extends StatefulWidget {
  final TextEditingController taskName;
  VoidCallback onSave;
  VoidCallback onCancel;

  DialogBox({
    super.key,
    required this.taskName,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  late String currentDate;

  @override
  void initState() {
    super.initState();
    // Initialize currentDate with the current date
    currentDate =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
  }

  //  Update date with selected date
  void updateDate(DateTime selectedDate) {
    setState(() {
      currentDate =
          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
    });
  }

  void _openDatePicker() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      updateDate(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      backgroundColor: white,
      content: SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextField(
              controller: widget.taskName,
              decoration: const InputDecoration(
                filled: true,
                fillColor: lightGrey,
                border: OutlineInputBorder(),
                hintText: 'Add a new task',
              ),
            ),
            GestureDetector(
              onTap: _openDatePicker,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_month_outlined),
                  const SizedBox(width: 10),
                  Text(
                    currentDate,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Button(text: 'Save', onPressed: widget.onSave),
                const SizedBox(width: 20),
                Button(text: 'Cancel', onPressed: widget.onCancel)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
