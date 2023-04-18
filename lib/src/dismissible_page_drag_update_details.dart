part of 'dismissible_page.dart';

/// Details outputted by [DismissiblePage.onDragUpdate] method
@immutable
class DismissiblePageDragUpdateDetails {
  ///
  const DismissiblePageDragUpdateDetails({
    required this.radius,
    required this.opacity,
    this.offset = Offset.zero,
    this.overallDragValue = 0.0,
    this.scale = 1.0,
  });

  final double overallDragValue;
  final double radius;
  final double opacity;
  final double scale;
  final Offset offset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DismissiblePageDragUpdateDetails &&
          runtimeType == other.runtimeType &&
          offset == other.offset;

  @override
  int get hashCode => offset.hashCode;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'overallDragValue': overallDragValue,
        'radius': radius,
        'opacity': opacity,
        'scale': scale,
        'offset': offset,
      };

  @override
  String toString() => toMap().toString();
}
