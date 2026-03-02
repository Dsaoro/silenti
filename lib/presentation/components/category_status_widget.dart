import 'package:flutter/material.dart';
import 'package:silenti/core/enums/silenti_colors.dart';

class CategoryStatusWidget extends StatelessWidget {
  final double percent;
  final double remaining;
  final double spentThisMonth;
  final String title;
  final VoidCallback? onLongPress;

  const CategoryStatusWidget({
    super.key,
    required this.percent,
    required this.remaining,
    required this.spentThisMonth,
    required this.title,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Colors
            .transparent, // Ensures the gesture detector captures events across the whole area
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  "${(percent * 100).toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: percent > 1.0 ? Colors.red : SilentiColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent.clamp(0.0, 1.0),
                minHeight: 12,
                backgroundColor: Colors.grey[300],
                color: percent > 0.9
                    ? Colors.orange
                    : (percent > 1.0 ? Colors.red : SilentiColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Gastado",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("\$${spentThisMonth.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Restante",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("\$${remaining.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: remaining < 0 ? Colors.red : Colors.green,
                        )),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
