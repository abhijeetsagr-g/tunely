import 'package:flutter/material.dart';

import 'package:another_flushbar/flushbar.dart';

void showFlushbar(BuildContext context, String message) {
  Flushbar(
    messageText: Row(
      children: [
        CircleAvatar(
          backgroundImage: AssetImage('assets/icon/icon.png'),
          radius: 14,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(message, style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),

    duration: const Duration(seconds: 1),
    flushbarPosition: FlushbarPosition.TOP,
    backgroundColor: Colors.black87,
    borderRadius: BorderRadius.circular(12),
    margin: const EdgeInsets.all(12),
  ).show(context);
}
