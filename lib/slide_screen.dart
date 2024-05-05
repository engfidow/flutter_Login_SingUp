import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:loginsinup/CircularSlider.dart';

class SlideScreen extends StatefulWidget {
  const SlideScreen({super.key});

  @override
  State<SlideScreen> createState() => _SlideScreenState();
}

class _SlideScreenState extends State<SlideScreen> {
  double _horizontalSliderValue1 = 50;
  double _horizontalSliderValue2 = 50;
  double _verticalSliderValue1 = 50;
  double _verticalSliderValue2 = 50;
  double _circularSliderValue = 9;
  bool isToggled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Wrap your Column in a Center widget to center everything
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Slider(
              value: _horizontalSliderValue1,
              min: 0,
              max: 100,
              onChanged: (value) {
                setState(() {
                  _horizontalSliderValue1 = value;
                });
              },
            ),
            // Ensuring the Row is centered
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // Center the row contents
              children: [
                RotatedBox(
                  quarterTurns: 3,
                  child: Slider(
                    value: _verticalSliderValue1,
                    min: 0,
                    max: 100,
                    onChanged: (value) {
                      setState(() {
                        _verticalSliderValue1 = value;
                      });
                    },
                  ),
                ),
                FlutterSwitch(
                  height: 50.0,
                  width: 100.0,
                  padding: 4.0,
                  toggleSize: 25.0,
                  borderRadius: 25.0,
                  activeColor: Colors.green,
                  value: isToggled,
                  onToggle: (value) {
                    setState(() {
                      isToggled = value;
                    });
                  },
                ),
                RotatedBox(
                  quarterTurns: 3,
                  child: Slider(
                    value: _verticalSliderValue2,
                    min: 0,
                    max: 100,
                    onChanged: (value) {
                      setState(() {
                        _verticalSliderValue2 = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            Slider(
              value: _horizontalSliderValue2,
              min: 0,
              max: 100,
              onChanged: (value) {
                setState(() {
                  _horizontalSliderValue2 = value;
                });
              },
            ),
            // Placeholder for Circular Slider
            // You will need to replace this with your circular slider implementation
            Padding(
              padding: EdgeInsets.only(top: 30), // Add some spacing
              child: CircularSlider(
                value: _circularSliderValue,
                min: 0,
                max: 100,
                onChanged: (newValue) {
                  setState(() {
                    _circularSliderValue = newValue;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
