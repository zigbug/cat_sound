import 'package:flutter/material.dart';
import '../models/breakpoint.dart';
import '../widgets/triangle_painter_widget.dart';

/// Виджет слайдера с точками останова
class AudioSliderWidget extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final List<Breakpoint> breakpoints;
  final Function(Duration) onSeek;
  final Function(int, Duration) onBreakpointDragged;

  const AudioSliderWidget({
    super.key,
    required this.position,
    required this.duration,
    required this.breakpoints,
    required this.onSeek,
    required this.onBreakpointDragged,
  });

  @override
  State<AudioSliderWidget> createState() => _AudioSliderWidgetState();
}

class _AudioSliderWidgetState extends State<AudioSliderWidget> {
  int? _draggingBreakpointIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sliderTrackWidth = constraints.maxWidth - 48;

        return Stack(
          children: [
            Slider(
              min: 0,
              max: widget.duration.inSeconds.toDouble(),
              value: widget.position.inSeconds.toDouble(),
              onChanged: (double value) async {
                widget.onSeek(Duration(seconds: value.toInt()));
              },
            ),
            ...widget.breakpoints.asMap().entries.map((entry) {
              final index = entry.key;
              final breakpoint = entry.value;
              final breakpointPosition =
                  breakpoint.position.inSeconds.toDouble();

              final percent = widget.duration.inSeconds == 0
                  ? 0
                  : breakpointPosition / widget.duration.inSeconds;

              final triangleLeftPosition = sliderTrackWidth * percent + 14;
              final constrainedPosition =
                  triangleLeftPosition.clamp(0.0, sliderTrackWidth + 14);

              return Positioned(
                left: constrainedPosition,
                child: GestureDetector(
                  onHorizontalDragStart: (details) {
                    setState(() {
                      _draggingBreakpointIndex = index;
                    });
                  },
                  onHorizontalDragUpdate: (details) {
                    final renderBox = context.findRenderObject() as RenderBox;
                    final localPosition =
                        renderBox.globalToLocal(details.globalPosition).dx;

                    final newPositionPercent = localPosition / sliderTrackWidth;
                    final newPosition = Duration(
                        seconds:
                            (widget.duration.inSeconds * newPositionPercent)
                                .toInt());

                    setState(() {});

                    widget.onBreakpointDragged(index, newPosition);
                  },
                  onHorizontalDragEnd: (details) {
                    setState(() {
                      _draggingBreakpointIndex = null;
                    });
                  },
                  child: TrianglePainterWidget(
                    strokeColor: _draggingBreakpointIndex == index
                        ? Colors.red
                        : Colors.blue,
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
