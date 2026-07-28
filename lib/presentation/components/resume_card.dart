import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:silenti/generated/l10n.dart';

// ignore: must_be_immutable
class ResumeCard extends StatefulWidget {
  final List<Widget> children;
  final Color background;
  final bool isLoading;
  double height;

  ResumeCard({
    super.key,
    required this.isLoading,
    required this.children,
    this.height = 300,
    this.background = Colors.transparent,
  });

  @override
  State<ResumeCard> createState() => _ResumeCardState();
}

class _ResumeCardState extends State<ResumeCard> {
  @override
  Widget build(BuildContext context) {
    Widget emptyWidgetResponse = ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: [
        Padding(
          padding: EdgeInsets.all(4),
          child: Center(
            child: Text(
              S.current.unavailableData,
              overflow: TextOverflow.visible,
              maxLines: 2,
            ),
          ),
        ),
      ],
    );

    if (widget.children.isEmpty) {
      if (kDebugMode) {
        print("empty children properties");
      }
    } else {
      if (kDebugMode) {
        print("children properties: ${widget.children.length}");
      }
    }

    if (widget.isLoading) {
      return Container(
        height: widget.height,
        color: Colors.black,
        child: ListView(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
            )
          ],
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsGeometry.only(left: 12, top: 10),
            child: Text(
              "Movimientos",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            color: Theme.of(context).colorScheme.surface.withAlpha(200),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: widget.height,
              alignment: Alignment.topCenter,
              child: widget.children.isEmpty
                  ? emptyWidgetResponse
                  : ListView.separated(
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 0),
                      itemCount: widget.children.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (context, index) => widget.children[index],
                    ),
            ),
          )
        ],
      );
    }
  }
}
