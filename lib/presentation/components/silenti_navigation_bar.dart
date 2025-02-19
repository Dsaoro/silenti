import 'package:flutter/material.dart';

import '../../core/enums/silenti_colors.dart';

class SilentiNavigationBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SilentiNavigationBarState();
  const SilentiNavigationBar({
    super.key,
    required this.pages,
    required this.titles,
    this.initialPage = 0,
  });

  final List<Widget> pages;
  final List<String> titles;
  final int initialPage;
}

class _SilentiNavigationBarState extends State<SilentiNavigationBar> {
  int _currentPageIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentPageIndex = widget.initialPage;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (int index) {
        setState(() {
          _currentPageIndex = index;
        });
      },
      indicatorColor: SilentiColors.primary,
      selectedIndex: _currentPageIndex,
      destinations: widget.pages
          .asMap()
          .entries
          .map((e) => NavigationDestination(
                icon: Icon(Icons.home),
                label: widget.titles[e.key],
              ))
          .toList(),
    );
  }
}
/*destinations:
<Widget>[
        NavigationDestination(
          icon: const Badge(child: Icon(Icons.account_balance_wallet_outlined)),
          selectedIcon: Icon(
            Icons.account_balance_wallet_outlined,
            color: SilentiColors.white,
          ),
          label: S.current.income,
        ),
        NavigationDestination(
          selectedIcon: Icon(
            Icons.home,
            color: SilentiColors.white,
          ),
          icon: Icon(Icons.home_outlined),
          label: S.current.home,
        ),
        NavigationDestination(
          icon: Badge(
            label: Text('2'),
            child: Icon(Icons.paste_outlined),
          ),
          selectedIcon: Icon(
            Icons.paste_outlined,
            color: SilentiColors.white,
          ),
          label: S.current.outcome,
        ),
      ]*/
