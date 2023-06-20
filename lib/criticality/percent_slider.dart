import 'package:flutter/material.dart';

class PercentSlider extends StatefulWidget {
  const PercentSlider({
    super.key,
    required this.initialPercentList,
    required this.colorList,
    required this.height,
    required this.width,
    this.toolTipList,
    required this.onChanged,
  });

  ///List of initial percents as integers
  final List<int> initialPercentList;

  ///List of colors for ranges from left to right
  final List<Color> colorList;

  ///height of slider
  final double height;

  ///width of slider
  final double width;

  ///List of the names for the ranges, from left to right. No tool tips if this is null
  final List<String>? toolTipList;

  ///Function to run when sliders are moved
  final void Function(int sliderId, List<int> newPercentList) onChanged;

  @override
  State<PercentSlider> createState() => _PercentSliderState();
}

class _PercentSliderState extends State<PercentSlider> {
  List<int> percentList = [30, 25, 20, 15, 10]; //random 5 values
  List<String>? toolTipList;
  @override
  void initState() {
    super.initState();
    percentList = widget.initialPercentList;
    toolTipList = widget.toolTipList;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: widget.height,
            width: widget.width,
            child: Expanded(
                child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Builder(builder: (context) {
                    return Row(
                      children: () {
                        List<Widget> widgetList = [];
                        for (int i = 0; i < percentList.length; i++) {
                          widgetList.add(Flexible(
                            flex: percentList[i],
                            child: widget.toolTipList == null
                                ? Container(color: widget.colorList[i])
                                : Tooltip(
                                    message:
                                        '${widget.toolTipList![i]}: ${percentList[i]}%',
                                    child:
                                        Container(color: widget.colorList[i]),
                                  ),
                          ));
                        }
                        return widgetList;
                      }(),
                    );
                  }),
                ),
                ...() {
                  List<Widget> widgetList = [];
                  for (int i = 0; i < percentList.length - 1; i++) {
                    widgetList.add(SliderHandle(
                      value: () {
                        int sum = 0;
                        for (int k = 0; k <= i; k++) {
                          sum += widget.initialPercentList[k];
                        }
                        return sum;
                      }(),
                      onChanged: ((valueChange) {
                        int actualChange = valueChange.clamp(
                            -1 * percentList[i], percentList[i + 1]);
                        percentList[i] += actualChange;
                        percentList[i + 1] -= actualChange;
                        widget.onChanged(percentList[i], percentList);
                        setState(() {});
                        return actualChange;
                      }),
                      backIndex: i,
                      forwardIndex: i + 1,
                      barSize: Size(widget.width, widget.height),
                      width: 20,
                      height: 100,
                    ));
                  }
                  return widgetList;
                }()
              ],
            )),
          ),
        ]);
  }
}

///Slider handles for Percent Slider
class SliderHandle extends StatefulWidget {
  SliderHandle(
      {super.key,
      required this.backIndex,
      required this.forwardIndex,
      required this.value,
      this.color = Colors.grey,
      this.pressedColor = Colors.blueGrey,
      required this.barSize,
      required this.onChanged,
      required this.width,
      required this.height});

  ///The 'percent' from the left where the slider handle is located.
  int value;

  ///Size of the percent slider bar
  final Size barSize;

  ///width of the slider handle
  final double width;

  ///height of the slider handle
  final double height;

  ///color of the slider handle
  final Color color;

  ///color of the slider handle when pressed
  final Color pressedColor;

  ///the range to the left of the slider handle
  final int backIndex;

  ///the range  to the right of the slider handle
  final int forwardIndex;

  ///the function to run when slider is moved. Returns the value to change this.value by
  final int Function(int valueChange) onChanged;
  @override
  State<SliderHandle> createState() => _SliderHandleState();
}

class _SliderHandleState extends State<SliderHandle> {
  ///initial position of slider when panning
  double initial = 0.0;

  ///if slider handle is pressed
  bool pressed = false;
  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: (widget.barSize.height - widget.height) / 2,
        left: (widget.value * (widget.barSize.width / 100) - widget.width / 2),
        height: widget.height,
        width: widget.width,
        child: GestureDetector(
          child: Container(color: pressed ? widget.pressedColor : widget.color),
          onPanStart: (DragStartDetails details) {
            initial = details.globalPosition.dx;
            setState(() {
              pressed = true;
            });
          },
          onPanUpdate: (DragUpdateDetails details) {
            double distance = details.globalPosition.dx - initial;
            int valueChange = (distance / widget.barSize.width * 100).round();
            print('valueChange: ${valueChange}');
            setState(() {
              widget.value += widget.onChanged(valueChange);
            });
            initial = details.globalPosition.dx;
          },
          onPanEnd: (DragEndDetails details) {
            initial = 0;
            setState(() {
              pressed = false;
            });
          },
        ));
  }
}
