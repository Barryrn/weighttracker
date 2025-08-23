import 'package:flutter/material.dart';
import 'package:weigthtracker/View/body_entry_sheet_view.dart';
import 'package:weigthtracker/View/footer_pages/home_page.dart';
import 'package:weigthtracker/View/footer_pages/progress_page.dart';
import 'package:weigthtracker/View/footer_pages/goals_page.dart';
import 'package:weigthtracker/View/footer_pages/more_page.dart';
import '../Widget/footer.dart';

/// Main container that manages page navigation with static footer
/// 
/// This widget uses PageView to handle smooth transitions between pages
/// while keeping the footer static at the bottom of the screen.
class MainContainer extends StatefulWidget {
  const MainContainer({Key? key}) : super(key: key);

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  /// Current active page index
  int _currentIndex = 0;
  
  /// PageController for managing page transitions
  late PageController _pageController;
  
  /// Flag to track if we're programmatically animating
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    
    // Listen to page controller to detect when animation completes
    _pageController.addListener(_onPageControllerChange);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageControllerChange);
    _pageController.dispose();
    super.dispose();
  }

  /// Listener for page controller changes
  void _onPageControllerChange() {
    // Only update index when animation is complete and page is settled
    if (!_pageController.position.isScrollingNotifier.value && 
        _pageController.page != null) {
      final currentPage = _pageController.page!.round();
      if (currentPage != _currentIndex && !_isAnimating) {
        setState(() {
          _currentIndex = currentPage;
        });
      }
    }
  }

  /// Handles page change events from PageView
  /// 
  /// This method is now simplified since we handle updates in the listener
  void _onPageChanged(int index) {
    // Only update immediately if not currently animating programmatically
    if (!_isAnimating) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  /// Handles footer tap events
  /// 
  /// Navigates to the selected page or shows body entry sheet for "Add" button
  void _onFooterTap(int index) {
    if (index == 2) {
      // Handle the "Add" button - show the body entry sheet
      BodyEntrySheet.show(context: context);
      return;
    }
    
    if (index != _currentIndex) {
      _isAnimating = true;
      setState(() {
        _currentIndex = index;
      });
      
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ).then((_) {
        _isAnimating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swiping
        onPageChanged: _onPageChanged,
        children: const [
          HomePageContent(),
          ProgressPageContent(),
          SizedBox(), // Placeholder for "Add" - not used since it shows a sheet
          GoalsPageContent(),
          MorePageContent(),
        ],
      ),
      bottomNavigationBar: Footer(
        currentIndex: _currentIndex,
        onTap: _onFooterTap,
      ),
    );
  }
}