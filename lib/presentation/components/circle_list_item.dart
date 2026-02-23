import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CircleListItem extends StatefulWidget {
  CircleListItem({
    super.key,
    this.onTap,
    this.title = "",
    this.icon,
    this.isSelected = false,
  });

  final Function? onTap;
  bool isSelected;
  final String title;
  final IconData? icon;
  @override
  State<StatefulWidget> createState() => _CircleListItemState();
}

class _CircleListItemState extends State<CircleListItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        }
        // setState(() {
        //   widget.isSelected = true;
        // });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                widget.icon,
                size: 28,
                color: widget.isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 64,
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.surface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
