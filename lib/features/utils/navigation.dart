import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tinycolor2/tinycolor2.dart';

import '../../config/constants.dart';
import '../../presentation/theme.dart';
import '../../presentation/utils.dart';

enum NavigationPage { home, profile }

int _indexOfPage(NavigationPage page) => NavigationPage.values.indexOf(page);

final navigationController = _NavigationPageController();

class _NavigationPageController extends ChangeNotifier {
  bool fullpage = true;

  // ignore: avoid_positional_boolean_parameters
  void setFullpage(bool v) {
    fullpage = v;
    notifyListeners();
  }
}

class NavigationButton extends StatelessWidget {
  const NavigationButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 15,
        bottom: 25,
        left: pageHorizontalPadding - 15,
        right: pageHorizontalPadding - 15,
      ),
      child: CustomGestureDetector(
        onTap: () {
          navigationController.setFullpage(false);
        },
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Container(
          height: 15,
          child: Assets.menu(),
        ),
      ),
    );
  }
}

class NavigationWrapper extends StatefulWidget {
  final Map<NavigationPage, Widget Function(BuildContext)> pages;
  NavigationWrapper({required this.pages})
      : assert(NavigationPage.values.every(pages.containsKey));

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  var _selectedPage = NavigationPage.home;
  int get _selectedPageIndex => _indexOfPage(_selectedPage);

  static const _pageVerticalDelta = 25.0;
  static const _pageHorizontalDelta = 270.0;
  static const _percPageVisible = .60;
  static const _percMenuVisible = .50;

  Color _backgroundColor(BuildContext context) =>
      AppColors.of(context).darkest.darken(5);
  Color _foregroundColor(BuildContext context) => ColorTween(
        begin: Colors.white,
        end: AppColors.of(context).medium,
      ).lerp(0.1)!;

  @override
  void initState() {
    navigationController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      tween:
          Tween<double>(begin: 0, end: navigationController.fullpage ? 0 : 1),
      builder: (context, percMenu, _) => _buildContent(context, percMenu),
    );
  }

  Widget _buildContent(BuildContext context, double percMenu) {
    return Scaffold(
      backgroundColor: _backgroundColor(context),
      body: Stack(children: [
        Positioned(
          top: MediaQuery.of(context).padding.top + 25,
          child: Opacity(
            opacity: max(percMenu - _percMenuVisible, 0) / _percMenuVisible,
            child: _buildNavigation(context),
          ),
        ),
        _buildRoatingPage(
          context,
          percMenu,
          child: widget.pages[_selectedPage]!(context),
        ),
      ]),
    );
  }

  Widget _buildRoatingPage(
    BuildContext context,
    double percMenu, {
    required Widget child,
  }) {
    return Positioned(
      top: percMenu * (MediaQuery.of(context).padding.top + _pageVerticalDelta),
      left: percMenu * _pageHorizontalDelta,
      child: Transform.rotate(
        angle: percMenu * -0.2,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: _backgroundColor(context),
                blurRadius: 6,
                spreadRadius: -1,
              )
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: child,
        ),
      ),
    );
  }

  Widget _buildNavigation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: pageHorizontalPadding - 15),
          child: GestureDetector(
            onTap: () {
              navigationController.setFullpage(true);
            },
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Icon(
                FontAwesomeIcons.xmark,
                size: 20,
                color: _foregroundColor(context).withOpacity(0.7),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: pageHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Text(
                'Menu',
                style: AppTexts.of(context)
                    .title3
                    .copyWith(color: _foregroundColor(context)),
              ),
              SizedBox(height: 40),
              ...NavigationPage.values.map((e) {
                switch (e) {
                  case NavigationPage.home:
                    return _buildMenuIcon(
                      context,
                      page: NavigationPage.home,
                      icon: FontAwesomeIcons.house,
                      name: 'eventos',
                    );
                  case NavigationPage.profile:
                    return _buildMenuIcon(
                      context,
                      page: NavigationPage.profile,
                      icon: FontAwesomeIcons.solidUser,
                      name: 'minha conta',
                    );
                }
              }).withBetween(SizedBox(height: 10)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuIcon(
    BuildContext context, {
    required NavigationPage page,
    required IconData icon,
    required String name,
  }) {
    final isSelected = page == _selectedPage;
    return GestureDetector(
      onTap: isSelected
          ? null
          : () {
              setState(() {
                navigationController.setFullpage(true);
                _selectedPage = page;
              });
            },
      child: Container(
        decoration: BoxDecoration(
          color: !isSelected
              ? null
              : AppColors.of(context).darkest.darken(10).withOpacity(0.6),
          borderRadius: BorderRadius.circular(15),
        ),
        height: 85,
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: _foregroundColor(context),
            ),
            SizedBox(width: 20),
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : null,
                color: _foregroundColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
