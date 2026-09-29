import 'package:flutter/material.dart';

class CameraFilterOverlay extends StatelessWidget {
  final String filterName;
  final Widget child;

  const CameraFilterOverlay({
    super.key,
    required this.filterName,
    required this.child,
  });

  List<double>? _getColorMatrix(String filter) {
    switch (filter.toUpperCase()) {
      case 'VINTAGE':
        return const <double>[
          0.9, 0.5, 0.1, 0.0, 0.0,
          0.3, 0.8, 0.1, 0.0, 0.0,
          0.2, 0.3, 0.5, 0.0, 0.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ];
      case 'WARM':
        return const <double>[
          1.1, 0.0, 0.0, 0.0, 0.0,
          0.0, 1.0, 0.0, 0.0, 0.0,
          0.0, 0.0, 0.8, 0.0, 0.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ];
      case 'COOL':
        return const <double>[
          0.8, 0.0, 0.0, 0.0, 0.0,
          0.0, 1.0, 0.0, 0.0, 0.0,
          0.0, 0.0, 1.2, 0.0, 0.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ];
      case 'B&W':
        return const <double>[
          0.33, 0.59, 0.11, 0.0, 0.0,
          0.33, 0.59, 0.11, 0.0, 0.0,
          0.33, 0.59, 0.11, 0.0, 0.0,
          0.0,  0.0,  0.0,  1.0, 0.0,
        ];
      case 'DRAMA':
        return const <double>[
          1.3, -0.1, -0.1, 0.0, -10.0,
          -0.1, 1.3, -0.1, 0.0, -10.0,
          -0.1, -0.1, 1.3, 0.0, -10.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ];
      case 'FADE':
        return const <double>[
          0.8, 0.1, 0.1, 0.0, 20.0,
          0.1, 0.8, 0.1, 0.0, 20.0,
          0.1, 0.1, 0.8, 0.0, 20.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ];
      case 'BRIGHT':
        return const <double>[
          1.15, 0.0, 0.0, 0.0, 15.0,
          0.0, 1.15, 0.0, 0.0, 15.0,
          0.0, 0.0, 1.15, 0.0, 15.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ];
      case 'NORMAL':
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final matrix = _getColorMatrix(filterName);
    if (matrix == null) {
      return child;
    }

    return ColorFiltered(
      colorFilter: ColorFilter.matrix(matrix),
      child: child,
    );
  }
}
