import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:dot_curved_bottom_nav/dot_curved_bottom_nav.dart';

class Navbar extends StatefulWidget {
  final Function(int) onPageSelected;
  final List<Widget> pages;
  final ScrollController scrollController; // Add ScrollController

  const Navbar({
    super.key,
    required this.onPageSelected,
    required this.pages,
    required this.scrollController,
  });

  @override
  NavbarState createState() => NavbarState();
}

class NavbarState extends State<Navbar> {
  int _currentPage = 0;
  bool _isNavbarVisible = true; // Track navbar visibility

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onPageSelected(0);
    });
    // Listen to scroll events
    widget.scrollController.addListener(_scrollListener);
  }

  // Listener to hide/show navbar based on scroll direction
  void _scrollListener() {
    if (widget.scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      // Scrolling down
      if (_isNavbarVisible) {
        setState(() {
          _isNavbarVisible = false; // Hide navbar
        });
      }
    } else if (widget.scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      // Scrolling up
      if (!_isNavbarVisible) {
        setState(() {
          _isNavbarVisible = true; // Show navbar
        });
      }
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener); // Remove listener
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: widget.pages[_currentPage],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            opacity: _isNavbarVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              color: Colors.transparent,
              child: DotCurvedBottomNav(
                onTap: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  widget.onPageSelected(index);
                },
                selectedIndex: _currentPage,
                items: const [
                  Icon(Icons.home),
                  Icon(Icons.chat),
                  Icon(Icons.calculate),
                  Icon(Icons.person),
                ],
                indicatorColor: Colors.black,
                backgroundColor: const Color.fromARGB(255, 211, 224, 247),
                height: 60.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
