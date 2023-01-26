// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flexible_carousel_slider/widget_keys.dart';
import 'package:flutter/material.dart';

class CarouselSlider extends StatefulWidget {
  const CarouselSlider({
    super.key,
    required this.children,
    this.autoPlayInterval = 4,
    this.autoPlay = true,
    this.autoPlayCurve = Curves.easeInOutCirc,
    this.viewportRatio = 0.92,
    this.scrollPhysics,
  });

  /// Enables auto play, sliding one page at a time.
  ///
  /// Use [autoPlayInterval] to determent the frequency of slides.
  /// Defaults to false.
  final bool autoPlay;

  /// Determines the animation curve physics.
  ///
  /// Defaults to [Curves.easeInOutCirc].
  final Curve autoPlayCurve;

  /// Sets Duration to determent the frequency of slides when
  ///
  /// [autoPlay] is set to true.
  /// Defaults to 4 seconds.
  final int autoPlayInterval;

  /// The widgets to be shown in the carousel of default constructor
  final List<Widget> children;

  /// How the carousel should respond to user input.
  ///
  /// For example, determines how the items continues to animate after the
  /// user stops dragging the page view.
  ///
  /// The physics are modified to snap to page boundaries using
  /// [PageScrollPhysics] prior to being used.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics? scrollPhysics;

  /// The fraction of the viewport that each child should occupy.
  ///
  /// Defaults to 0.92, which means each page fills 92% of the carousel.
  final double viewportRatio;

  @override
  _CarouselSliderState createState() => _CarouselSliderState();
}

class _CarouselSliderState extends State<CarouselSlider>
    with TickerProviderStateMixin {
  Timer? sliderTimer;

  int _currentIndex = 0;
  int _currentPage = 0;
  late List<double> _heights;
  late PageController _pageController;

  @override
  void dispose() {
    sliderTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _heights = widget.children.map((Widget e) => 0.0).toList();
    super.initState();
    _pageController = PageController(viewportFraction: widget.viewportRatio);
    if (widget.autoPlay) {
      sliderTimer = getTimer(duration: widget.autoPlayInterval);
    }
  }

  Timer getTimer({required int duration}) {
    return Timer.periodic(Duration(seconds: duration), (Timer timer) {
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(seconds: 1),
        curve: widget.autoPlayCurve,
      );
      _currentPage++;
    });
  }

  double get _currentHeight => _heights[_currentIndex];

  List<Widget> get _sizeReportingChildren => widget.children
      .asMap() //
      .map((int index, Widget child) {
        return MapEntry<int, Widget>(
          index,
          OverflowBox(
            /// [minHeight] is needed so that parent won't impose its constraints on the children, thus skewing the measurement results.
            minHeight: 0,
            maxHeight: double.infinity,
            alignment: Alignment.topCenter,
            child: SizeReportingWidget(
              onSizeChange: (Size size) =>
                  setState(() => _heights[index] = size.height),
              child: Align(
                child: GestureDetector(
                  key: carouselItemKey,
                  child: child,
                  onPanDown: (_) {
                    if (widget.autoPlay) {
                      sliderTimer?.cancel();
                      sliderTimer = null;
                    }
                  },
                  onPanCancel: () {
                    if (widget.autoPlay) {
                      sliderTimer = getTimer(duration: widget.autoPlayInterval);
                    }
                  },
                ),
              ),
            ),
          ),
        );
      })
      .values
      .toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TweenAnimationBuilder<double>(
          curve: Curves.easeInOutCubic,
          duration: const Duration(milliseconds: 100),
          tween: Tween<double>(begin: _heights[0], end: _currentHeight),
          builder: (BuildContext context, double value, Widget? child) =>
              SizedBox(height: value, child: child),
          child: PageView.builder(
            controller: _pageController,
            physics: widget.scrollPhysics,
            onPageChanged: (int index) =>
                setState(() => _currentIndex = index % widget.children.length),
            itemBuilder: (_, int index) {
              return _sizeReportingChildren
                  .asMap() //
                  .map(
                    (int index, Widget child) =>
                        MapEntry<int, Widget>(index, child),
                  )
                  .values

                  /// we are using modulus to loop through [widget.children] without running out bounds
                  .toList()[index % widget.children.length];
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(
            widget.children.length,
            (int index) => Container(
              margin: const EdgeInsets.all(2.0),
              child: Icon(
                Icons.circle,
                size: 12.2,
                color: _currentIndex == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
              ),
            ),
          ).toList(),
        )
      ],
    );
  }
}

class SizeReportingWidget extends StatefulWidget {
  const SizeReportingWidget({
    super.key,
    required this.child,
    required this.onSizeChange,
  });

  final Widget child;
  final ValueChanged<Size> onSizeChange;

  @override
  _SizeReportingWidgetState createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget> {
  Size _oldSize = Size.infinite;

  void _notifySize() {
    if (!mounted) {
      return;
    }
    final Size? size = context.size;
    if (_oldSize != size) {
      _oldSize = size!;
      widget.onSizeChange(size);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    return widget.child;
  }
}
