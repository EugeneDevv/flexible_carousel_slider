// ignore_for_file: prefer_const_constructors

import 'package:flexible_carousel_slider/flexible_carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlexibleCarouselSlider', () {
    List<Widget> testList = <Widget>[
      Container(
        color: Colors.red,
        height: 500,
        width: 400,
        child: const Text('500'),
      ),
      Container(
        color: Colors.blue,
        height: 200,
        width: 400,
        child: const Text('200'),
      ),
      Container(
        color: Colors.blue,
        height: 600,
        width: 400,
        child: const Text('600'),
      ),
    ];

    test('can be instantiated', () {
      expect(
        FlexibleCarouselSlider(
          children: testList,
        ),
        isNotNull,
      );
    });
  });
}
