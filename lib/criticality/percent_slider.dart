import 'package:flutter/material.dart';

///Multi percent bar slider from left to right. A variation of https://gist.github.com/yeasin50/fc597892b500b12e2b2fb0a9d5ba53bb
class PercentSlider extends StatefulWidget {
  const PercentSlider(
      {super.key,
      required this.size,
      this.min = 0,
      this.max = 100,
      required this.onSliderUpdate,
      required this.barColors,
      this.tooltip,
      this.sliderColor = Colors.grey,
      this.sliderPressedColor = Colors.blueGrey,
      required this.initialValues});

  ///Size of the sliders
  final Size size;

  ///minimum value on slider
  final int min;

  ///maximum value on slider
  final int max;

  ///color of the sliders normally
  final Color sliderColor;

  ///initial values for the sliders. Percentage position of the slider on the bar from
  ///left to right. Should have [initialValues.length] = [barColors.length] - 1
  final List<int> initialValues;

  ///color of the sliders when selected
  final Color sliderPressedColor;

  ///colors of the range bars from left to right. Should have [barColors.length] = [initialValues.length] + 1
  final List<Color> barColors;

  ///function to run when slider updates
  final Function(List<int?> posList) onSliderUpdate;

  ///tool tip messages. Length must match the amount of percent bars
  final List<String>? tooltip;

  int get range => max - min;

  @override
  State<StatefulWidget> createState() => _PercentSliderState();
}

class _PercentSliderState extends State<PercentSlider> {
  //slider values
  List<int?> percentList = [];

  List<int> initialValuesDuplicateList = [];

  bool isDragging = false;

  ///the active slider
  int activeSliderNumber = 0;

  @override
  void initState() {
    super.initState();
    initialValuesDuplicateList = widget.initialValues;
    if (widget.initialValues.length != widget.barColors.length - 1) {
      throw Exception(
          "Unexpected lengths for [widget.initialValues] and [widget.barColors]. {[initialValues.length] == [barColors.length] - 1} must be true");
    }
    if (widget.tooltip != null &&
        widget.tooltip!.length != widget.barColors.length) {
      throw Exception(
          "Mismatch between [widget.tooltip.length] and number of percent bars.");
    }
  }

  void _updateSlider(double dx, double maxWidth) {
    final int tapValue = (dx / maxWidth * widget.range).round();
    if (tapValue < widget.min || tapValue > widget.max) {
      return;
    }

    int lowerLimit = (activeSliderNumber != 0)
        ? percentList[activeSliderNumber - 1]!
        : widget.min;
    int upperLimit = (activeSliderNumber != percentList.length - 1)
        ? percentList[activeSliderNumber + 1]!
        : widget.max;
    if (activeSliderNumber >= 0 && activeSliderNumber < percentList.length) {
      setState(() {
        isDragging = true;
        percentList[activeSliderNumber] =
            tapValue.clamp(lowerLimit, upperLimit);
      });
    }

    //pass value on main widget
    widget.onSliderUpdate(_calculateDistributions());
  }

  /// calculate slider layout position
  double _calculateSliderPosition({
    required double maxWidth,
    required int percent,
  }) {
    // x is slider original position on width:maxWidth

    return (maxWidth * (percent / (widget.range)) - widget.size.width / 2);
  }

  /// calculate the percent distributions from slider values
  List<int> _calculateDistributions() {
    List<int> distributions = [];
    //check if [widget.initialValues] has been changed. Kind of a hack,should use better method for handling value update (e.g. Consumer widget) later
    if (widget.initialValues != initialValuesDuplicateList) {
      //if changed, update [percentList]
      initialValuesDuplicateList = widget.initialValues;
      percentList = List.of(widget.initialValues);
    }
    distributions.add(percentList.first! - widget.min);
    for (int i = 1; i < percentList.length; i++) {
      distributions.add(percentList[i]! - percentList[i - 1]!);
    }
    distributions.add(widget.max - percentList.last!);
    return distributions;
  }

  /// select ActiveSlider, fixed overLap issue
  void _selectSlider({
    required double maxWidth,
    required double tapPosition,
  }) {
    final maxArea = widget.size.width / 2; //maxWidth * tapSpacesArea;

    for (int i = 0; i < percentList.length; i++) {
      if ((tapPosition -
                  _calculateSliderPosition(
                      maxWidth: maxWidth, percent: percentList[i]!))
              .abs() <
          maxArea) {
        setState(() {
          isDragging = true;
          activeSliderNumber = i;
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.size.height * 3,
          child: LayoutBuilder(builder: (context, constraints) {
            final maxWidth = constraints.maxWidth - 10;
            if (percentList.length != widget.initialValues.length) {
              percentList =
                  List<int?>.filled(widget.initialValues.length, null);
            }
            for (int i = 0; i < percentList.length; i++) {
              percentList[i] = percentList[i] ?? widget.initialValues[i];
            }
            return Stack(
              alignment: Alignment.center,
              children: [
                //bars
                Padding(
                  padding: EdgeInsets.only(
                      top: widget.size.height * 0.2,
                      bottom: widget.size.height * 0.2,
                      right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: () {
                      List<int> distributions = _calculateDistributions();
                      List<Widget> widgetList = [];
                      for (int i = 0; i < distributions.length; i++) {
                        widgetList.add(Flexible(
                          flex: distributions[i],
                          child: Tooltip(
                              message: (widget.tooltip != null && !isDragging)
                                  ? '${widget.tooltip![i]}: ${distributions[i]}'
                                  : '',
                              child: Container(
                                color: widget.barColors[i],
                              )),
                        ));
                      }
                      return widgetList;
                    }(),
                  ),
                ),
                //sliders
                ...() {
                  List<Widget> widgetList = [];
                  for (int i = 0; i < percentList.length; i++) {
                    widgetList.add(Positioned(
                      left: _calculateSliderPosition(
                          maxWidth: maxWidth, percent: percentList[i]!),
                      child: Container(
                        height: activeSliderNumber == i
                            ? widget.size.height * 5
                            : widget.size.height * 4,
                        width: widget.size.width,
                        color: (activeSliderNumber == i)
                            ? widget.sliderPressedColor
                            : widget.sliderColor,
                      ),
                    ));
                  }
                  return widgetList;
                }(),
                GestureDetector(
                  onTapDown: (details) {
                    _selectSlider(
                        maxWidth: maxWidth,
                        tapPosition: details.localPosition.dx);
                  },
                  onPanUpdate: (details) {
                    _updateSlider(details.localPosition.dx, maxWidth);
                  },
                  onTapCancel: () {
                    setState(() {
                      isDragging = false;
                    });
                  },
                  onTapUp: (details) {
                    setState(() {
                      isDragging = false;
                    });
                  },
                  onPanCancel: () {
                    setState(() {
                      isDragging = false;
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      isDragging = false;
                    });
                  },
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
