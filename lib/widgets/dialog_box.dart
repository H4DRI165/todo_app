import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo_app/constants/colours.dart';
import 'package:todo_app/widgets/custom_switch.dart';
import 'button.dart';

class DialogBox extends StatefulWidget {
  final TextEditingController taskName;
  final Function(String taskName, String deadlineAt, String createdAt) onSave;
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
  late String displayDate;

  TimeOfDay? selectedTime;
  TimeOfDay? reminderTime;

  bool _enable = false;

  @override
  void initState() {
    super.initState();
    //  Initialize displayDate with the current date
    displayDate =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
  }

  //  Update date with selected date
  void updateDate(DateTime selectedDate) {
    setState(() {
      displayDate =
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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        reminderTime = _calculateReminderTime(picked);
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) {
      return 'No';
    } else {
      return time.format(context);
    }
  }

  TimeOfDay _calculateReminderTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final adjustedTime = dateTime.subtract(const Duration(minutes: 10));
    return TimeOfDay.fromDateTime(adjustedTime);
  }

  void _toastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      backgroundColor: white,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildTaskName(),
            const SizedBox(
              height: 10,
            ),
            buildDeadlineDate(),
            const SizedBox(
              height: 10,
            ),
            buildDisplayTime(),
            const SizedBox(
              height: 10,
            ),
            buildSetReminder(),
            const SizedBox(
              height: 10,
            ),
            buildSaveCancel(),
          ],
        ),
      ),
    );
  }

  Widget buildDeadlineDate() {
    return GestureDetector(
      onTap: _openDatePicker,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_month_outlined),
          const SizedBox(
            width: 10,
          ),
          const Text('Deadline'),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  displayDate,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDisplayTime() {
    return GestureDetector(
      onTap: () => _selectTime(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.access_time),
          const SizedBox(width: 10),
          const Text('Time'),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  _formatTime(selectedTime),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSetReminder() {
    return GestureDetector(
      onTap: () {
        if (selectedTime == null) {
          _toastMessage('Please set time first');
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_active_outlined,
            color: selectedTime == null ? Colors.grey : Colors.black,
          ),
          const SizedBox(width: 10),
          Text(
            'Reminder',
            style: TextStyle(
              color: selectedTime == null ? Colors.grey : Colors.black,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    if (selectedTime != null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            elevation: 0,
                            insetPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            contentPadding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            content: Container(
                              width: MediaQuery.of(context).size.width - 40,
                              height: MediaQuery.of(context).size.height - 580,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          _enable
                                              ? 'Reminder is on'
                                              : 'Reminder is off',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: CustomSwitch(
                                              value: _enable,
                                              onChanged: (bool val) {
                                                setState(() {
                                                  _enable = val;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    const Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Reminder at',
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text('10 minutes before'),
                                              Icon(Icons.keyboard_arrow_down),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 30),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Button(
                                          text: 'Save',
                                          onPressed: () {},
                                        ),
                                        const SizedBox(width: 20),
                                        Button(
                                            text: 'Cancel', onPressed: () {}),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                  child: Text(
                    _formatTime(reminderTime),
                    style: TextStyle(
                      color: selectedTime == null ? Colors.grey : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTaskName() {
    return TextField(
      controller: widget.taskName,
      decoration: const InputDecoration(
        filled: true,
        fillColor: lightGrey,
        border: OutlineInputBorder(),
        hintText: 'Input new task here',
      ),
    );
  }

  Widget buildSaveCancel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Button(
          text: 'Save',
          onPressed: () {
            //  call onSave function
            widget.onSave(
              widget.taskName.text,
              displayDate,
              "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
            );
          },
        ),
        const SizedBox(width: 20),
        Button(text: 'Cancel', onPressed: widget.onCancel),
      ],
    );
  }
}
