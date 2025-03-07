import 'package:flutter/material.dart';
import 'package:silenti/core/enums/silenti_colors.dart';

class ResumeCard extends StatefulWidget {
  ResumeCard({
    super.key,
    required this.isLoading,
    required this.children,
    this.height = 300,
    this.background = SilentiColors.gray,
  });

  final List<Widget> children;
  final Color background;
  final bool isLoading;
  double height;
  @override
  State<ResumeCard> createState() => _ResumeCardState();
}

Widget _emptyWidgetResponse = SizedBox(
  height: double.infinity,
  width: double.infinity,
  child: Center(
    child: Text(
      "There is no available data",
      overflow: TextOverflow.visible,
      maxLines: 2,
    ),
  ),
);

class _ResumeCardState extends State<ResumeCard> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return ListView(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
          )
        ],
      );
    } else {
      return Container(
          width: MediaQuery.of(context).size.width * 0.90,
          height: widget.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: EdgeInsets.all(3),
            child: widget.children.isEmpty
                ? _emptyWidgetResponse
                : ListView.separated(
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemCount: widget.children.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) => widget.children[index],
                  ),
          ));
    }
  }
}
