import 'package:flutter/material.dart';

class SnakePixel extends StatelessWidget {
  final bool isHead;
  const SnakePixel({super.key, this.isHead = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: isHead
            ? const LinearGradient(
                colors: [Colors.orange, Colors.amber],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Colors.green, Colors.teal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(isHead ? 8 : 10),
        boxShadow: [
          BoxShadow(
            color: isHead
                ? Colors.orangeAccent.withOpacity(0.85)
                : Colors.greenAccent.withOpacity(0.5),
            blurRadius: isHead ? 10 : 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
