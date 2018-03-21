import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Created by Marcin Szałek
/// horizontal implementation by Andrea Zanini

///NumberPicker is a widget designed to pick a number between #minValue and #maxValue
class NumberPicker extends StatefulWidget {

  ///height of every list element
  static const double DEFAULT_ITEM_EXTENT = 50.0;

  ///width of list view
  static const double DEFAULT_LISTVIEW_WIDTH = 100.0;

  ///called when selected value changes
  final ValueChanged<num> onChanged;

  ///min value user can pick
  final int minValue;

  ///max value user can pick
  final int maxValue;

  ///inidcates how many decimal places to show
  /// e.g. 0=>[1,2,3...], 1=>[1.0, 1.1, 1.2...]  2=>[1.00, 1.01, 1.02...]
  final int decimalPlaces;

  ///height of every list element in pixels
  final double itemExtent;

  ///view will always contain only 3 elements of list in pixels
  final double listViewHeight;

  ///width of list view in pixels
  final double listViewWidth;

  ///horizontal view?
  final bool horizontal;
  final int initialValue;
  final double initialDecimalValue;
  bool value = true;

  ///constructor for integer number picker
  NumberPicker.integer({
    Key key,
    @required this.initialValue,
    @required this.minValue,
    @required this.maxValue,
    @required this.onChanged,
    this.itemExtent = DEFAULT_ITEM_EXTENT,
    this.listViewWidth = DEFAULT_LISTVIEW_WIDTH,
    this.horizontal = false,
    this.listViewHeight = DEFAULT_ITEM_EXTENT * 3,
    this.decimalPlaces = 0,
    value = true,
    this.initialDecimalValue = 0.0,
  });

  ///constructor for decimal number picker
  NumberPicker.decimal({
    Key key,
    @required this.initialDecimalValue,
    @required this.minValue,
    @required this.maxValue,
    @required this.onChanged,
    this.decimalPlaces = 1,
    this.itemExtent = DEFAULT_ITEM_EXTENT,
    this.listViewWidth = DEFAULT_LISTVIEW_WIDTH,
    this.horizontal = false,
    this.listViewHeight = DEFAULT_ITEM_EXTENT * 3,
    value = false,
    this.initialValue = 0,
  });


  @override
  createState() =>
      (value) ? new NumberPickerState.integer(
          initialValue: initialValue,
          minValue: minValue,
          maxValue: maxValue,
          onChanged: onChanged,
          itemExtent: itemExtent,
          listViewWidth: listViewWidth,
          horizontal: horizontal,
          listViewHeight: listViewHeight) : new NumberPickerState.decimal(
          initialValue: initialDecimalValue,
          minValue: minValue,
          maxValue: maxValue,
          onChanged: onChanged,
          itemExtent: itemExtent,
          listViewWidth: listViewWidth,
          horizontal: horizontal,
          listViewHeight: listViewHeight);


}


class NumberPickerState extends State<NumberPicker> {
  ///height of every list element
  static const double DEFAULT_ITEM_EXTENT = 50.0;

  ///width of list view
  static const double DEFAULT_LISTVIEW_WIDTH = 100.0;

  ///called when selected value changes
  final ValueChanged<num> onChanged;

  ///min value user can pick
  final int minValue;

  ///max value user can pick
  final int maxValue;

  ///inidcates how many decimal places to show
  /// e.g. 0=>[1,2,3...], 1=>[1.0, 1.1, 1.2...]  2=>[1.00, 1.01, 1.02...]
  final int decimalPlaces;

  ///height of every list element in pixels
  final double itemExtent;

  ///view will always contain only 3 elements of list in pixels
  final double listViewHeight;

  ///width of list view in pixels
  final double listViewWidth;

  ///ScrollController used for integer list
  final ScrollController intScrollController;

  ///ScrollController used for decimal list
  final ScrollController decimalScrollController;

  ///Currently selected integer value
  final int selectedIntValue;

  ///Currently selected decimal value
  final int selectedDecimalValue;

  ///horizontal view?
  final bool horizontal;

  //------------CONSTRUCTOR---------

  NumberPickerState.integer({
    Key key,
    @required int initialValue,
    @required this.minValue,
    @required this.maxValue,
    @required this.onChanged,
    this.itemExtent = DEFAULT_ITEM_EXTENT,
    this.listViewWidth = DEFAULT_LISTVIEW_WIDTH,
    this.horizontal = false,
    this.listViewHeight = DEFAULT_ITEM_EXTENT * 3,
  })
      : assert(initialValue != null),
        assert(minValue != null),
        assert(maxValue != null),
        assert(maxValue > minValue),
        assert(initialValue >= minValue && initialValue <= maxValue),
        selectedIntValue = initialValue,
        selectedDecimalValue = -1,
        decimalPlaces = 0,
        intScrollController = new ScrollController(
          initialScrollOffset: (initialValue - minValue) * itemExtent,
        ),
        decimalScrollController = null;

  ///constructor for decimal number picker
  NumberPickerState.decimal({
    Key key,
    @required double initialValue,
    @required this.minValue,
    @required this.maxValue,
    @required this.onChanged,
    this.decimalPlaces = 1,
    this.itemExtent = DEFAULT_ITEM_EXTENT,
    this.listViewWidth = DEFAULT_LISTVIEW_WIDTH,
    this.horizontal = false,
    this.listViewHeight = DEFAULT_ITEM_EXTENT * 3,

  })
      : assert(initialValue != null),
        assert(minValue != null),
        assert(maxValue != null),
        assert(decimalPlaces != null && decimalPlaces > 0),
        assert(maxValue > minValue),
        assert(initialValue >= minValue && initialValue <= maxValue),
        selectedIntValue = initialValue.floor(),
        selectedDecimalValue = ((initialValue - initialValue.floorToDouble()) *
            pow(10, decimalPlaces))
            .round(),
        intScrollController = new ScrollController(
          initialScrollOffset: (initialValue.floor() - minValue) * itemExtent,
        ),
        decimalScrollController = new ScrollController(
          initialScrollOffset: ((initialValue - initialValue.floorToDouble()) *
              pow(10, decimalPlaces))
              .roundToDouble() *
              itemExtent,
        );

  //
  //----------------------------- PUBLIC ------------------------------
  //

  animateInt(int valueToSelect) {
    _animate(intScrollController, (valueToSelect - minValue) * itemExtent);
  }

  animateDecimal(int decimalValue) {
    _animate(decimalScrollController, decimalValue * itemExtent);
  }

  animateDecimalAndInteger(double valueToSelect) {
    print(valueToSelect);
    animateInt(valueToSelect.floor());
    animateDecimal(((valueToSelect - valueToSelect.floorToDouble()) *
        pow(10, decimalPlaces))
        .round());
  }

  //
  //----------------------------- VIEWS -----------------------------
  //

  ///main widget
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    if (decimalPlaces == 0) {
      return _integerListView(themeData);
    } else if (horizontal) {
      return new Column(
        children: <Widget>[
          _integerListView(themeData),
          _decimalListView(themeData),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );
    } else {
      return new Row(
        children: <Widget>[
          _integerListView(themeData),
          _decimalListView(themeData),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );
    }
  }

  Widget _integerListView(ThemeData themeData) {
    TextStyle defaultStyle = themeData.textTheme.body1;
    TextStyle selectedStyle =
    themeData.textTheme.headline.copyWith(color: themeData.accentColor);

    int itemCount = maxValue - minValue + 3;

    return new NotificationListener(
      child: new Container(
        height: listViewHeight,
        width: listViewWidth,
        child: new ListView.builder(
          scrollDirection: (horizontal) ? Axis.horizontal : Axis.vertical,
          controller: intScrollController,
          itemExtent: itemExtent,
          itemCount: itemCount,
          itemBuilder: (BuildContext context, int index) {
            final int value = minValue + index - 1;

            //define special style for selected (middle) element
            final TextStyle itemStyle =
            value == selectedIntValue ? selectedStyle : defaultStyle;

            bool isExtra = index == 0 || index == itemCount - 1;

            return isExtra
                ? new Container() //empty first and last element
                : new Center(
              child: new Text(value.toString(), style: itemStyle),
            );
          },
        ),
      ),
      onNotification: _onIntegerNotification,
    );
  }


  Widget _decimalListView(ThemeData themeData) {
    TextStyle defaultStyle = themeData.textTheme.body1;
    TextStyle selectedStyle =
    themeData.textTheme.headline.copyWith(color: themeData.accentColor);

    int itemCount =
    selectedIntValue == maxValue ? 3 : pow(10, decimalPlaces) + 2;

    return new NotificationListener(
      child: new Container(
        height: listViewHeight,
        width: listViewWidth,
        child: new ListView.builder(
          scrollDirection: (horizontal) ? Axis.horizontal : Axis.vertical,
          controller: decimalScrollController,
          itemExtent: itemExtent,
          itemCount: itemCount,
          itemBuilder: (BuildContext context, int index) {
            final int value = index - 1;

            //define special style for selected (middle) element
            final TextStyle itemStyle =
            value == selectedDecimalValue ? selectedStyle : defaultStyle;

            bool isExtra = index == 0 || index == itemCount - 1;

            return isExtra
                ? new Container() //empty first and last element
                : new Center(
              child: new Text(
                  value.toString().padLeft(decimalPlaces, '0'),
                  style: itemStyle),
            );
          },
        ),
      ),
      onNotification: _onDecimalNotification,
    );
  }

  //
  // ----------------------------- LOGIC -----------------------------
  //

  bool _onIntegerNotification(Notification notification) {
    if (notification is ScrollNotification) {
      //calculate
      int intIndexOfMiddleElement = (horizontal) ? (notification.metrics
          .pixels + listViewWidth / 2) ~/ itemExtent :
      (notification.metrics.pixels + listViewHeight / 2) ~/ itemExtent;
      int intValueInTheMiddle = minValue + intIndexOfMiddleElement - 1;

      if (_userStoppedScrolling(notification, intScrollController)) {
        //center selected value
        animateInt(intValueInTheMiddle);
      }

      //update selection
      if (intValueInTheMiddle != selectedIntValue) {
        num newValue;
        if (decimalPlaces == 0) {
          //return integer value
          newValue = (intValueInTheMiddle);
        } else {
          if (intValueInTheMiddle == maxValue) {
            //if new value is maxValue, then return that value and ignore decimal
            newValue = (intValueInTheMiddle.toDouble());
            animateDecimal(0);
          } else {
            //return integer+decimal
            double decimalPart = _toDecimal(selectedDecimalValue);
            newValue = ((intValueInTheMiddle + decimalPart).toDouble());
          }
        }
        onChanged(newValue);
        setState(() {});
      }
    }
    return true;
  }

  bool _onDecimalNotification(Notification notification) {
    if (notification is ScrollNotification) {
      //calculate middle value
      int indexOfMiddleElement = (horizontal) ? (notification.metrics.pixels +
          listViewWidth / 2) ~/ itemExtent :
      (notification.metrics.pixels + listViewHeight / 2) ~/ itemExtent;
      int decimalValueInTheMiddle = indexOfMiddleElement - 1;

      if (_userStoppedScrolling(notification, decimalScrollController)) {
        //center selected value
        animateDecimal(decimalValueInTheMiddle);
      }

      //update selection
      if (selectedIntValue != maxValue &&
          decimalValueInTheMiddle != selectedDecimalValue) {
        double decimalPart = _toDecimal(decimalValueInTheMiddle);
        double newValue = ((selectedIntValue + decimalPart).toDouble());
        onChanged(newValue);
      }
    }
    return true;
  }

  ///indicates if user has stopped scrolling so we can center value in the middle
  bool _userStoppedScrolling(Notification notification,
      ScrollController scrollController) {
    return notification is UserScrollNotification &&
        notification.direction == ScrollDirection.idle &&
        scrollController.position.activity is! HoldScrollActivity;
  }

  ///converts integer indicator of decimal value to double
  ///e.g. decimalPlaces = 1, value = 4  >>> result = 0.4
  ///     decimalPlaces = 2, value = 12 >>> result = 0.12
  double _toDecimal(int decimalValueAsInteger) {
    return double.parse((decimalValueAsInteger * pow(10, -decimalPlaces))
        .toStringAsFixed(decimalPlaces));
  }

  ///scroll to selected value
  _animate(ScrollController scrollController, double value) {
    scrollController.animateTo(value,
        duration: new Duration(seconds: 1), curve: new ElasticOutCurve());
  }
}

