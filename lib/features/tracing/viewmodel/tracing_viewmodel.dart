import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/tracing/viewmodel/activity_item.dart';
import 'package:play_craft_kids/features/tracing/widgets/letter_path_data.dart';
import 'package:play_craft_kids/features/tracing/widgets/letter_info.dart';
import 'package:play_craft_kids/features/tracing/widgets/color_info.dart';

enum TracingStatus { idle, tracing, paused, passed, summary, failed }

enum ActivityType { animals, colors }

class TracingProvider extends ChangeNotifier {
  ActivityItem? _currentItem;
  int _categoryId = 1;
  List<ActivityItem> _currentSequence = [];

  String _currentLetter = 'A';
  int _currentLetterIndex = 0;
  ActivityType _activityType = ActivityType.animals;

  TracingStatus _status = TracingStatus.idle;

  List<Offset> _allDrawnPoints = [];
  List<Offset> _currentStroke = [];
  List<List<Offset>> _completedStrokes = [];

  // Empty list to satisfy painter, we no longer track wrong points
  final List<Offset> _wrongPoints = [];

  double _coverageRatio = 0.0;
  // double _accuracyRatio = 1.0;
  int _stars = 0;
  int _scorePercentage = 0;

  final Stopwatch _stopwatch = Stopwatch();

  Size _canvasSize = const Size(300, 300);

  // Track reference points per stroke
  List<List<Offset>> _strokeReferencePoints = [];
  int _activeStrokeIndex = 0;

  static const double _onPathThreshold = 44.0;
  static const double _startPointThreshold = 45.0;
  // static const double _passCoverageThreshold = 0.82;

  int get categoryId => _categoryId;
  ActivityItem? get currentItem => _currentItem;
  String get currentLetter => _currentLetter;
  int get currentLetterIndex => _currentLetterIndex;
  ActivityType get activityType => _activityType;
  TracingStatus get status => _status;
  List<List<Offset>> get completedStrokes => _completedStrokes;
  List<Offset> get currentStroke => _currentStroke;
  List<Offset> get wrongPoints => _wrongPoints;
  double get coverageRatio => _coverageRatio;
  int get stars => _stars;
  int get scorePercentage => _scorePercentage;

  String get formattedTime {
    final elapsed = _stopwatch.elapsed;
    final mins = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void setTracingItem(
      ActivityItem item, List<ActivityItem> sequence, int categoryId) {
    _currentItem = item;
    _currentSequence = sequence;
    _categoryId = categoryId;
    _currentLetter = item.letter.toUpperCase();
    _currentLetterIndex =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.indexOf(_currentLetter);
    if (_currentLetterIndex == -1) {
      _currentLetterIndex = 0;
      _currentLetter = 'A';
    }
    _resetState();
    _recomputeReference();
    notifyListeners();
  }

  void setLetter(String letter) {
    _currentLetter = letter.toUpperCase();
    _currentLetterIndex =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.indexOf(_currentLetter);
    if (_currentLetterIndex == -1) {
      _currentLetterIndex = 0;
      _currentLetter = 'A';
    }
    _resetState();
    _recomputeReference();
    notifyListeners();
  }

  void setActivityType(ActivityType type) {
    _activityType = type;
    notifyListeners();
  }

  Size get canvasSize => _canvasSize;
  int get activeStrokeIndex => _activeStrokeIndex;

  bool get canGoNext =>
      _status == TracingStatus.summary || _status == TracingStatus.passed;
  bool get isPaused =>
      _status == TracingStatus.paused && _allDrawnPoints.isNotEmpty;

  void setCanvasSize(Size size) {
    if (size == _canvasSize) return;
    _canvasSize = size;
    _recomputeReference();
    notifyListeners();
  }

  void _recomputeReference() {
    final strokes = LetterPathData.getStrokes(_currentLetter);
    _strokeReferencePoints =
        strokes.map((s) => LetterPathData.scale(s, _canvasSize)).toList();
    _activeStrokeIndex = 0;
  }

  void onPanStart(Offset position) {
    if (_status == TracingStatus.passed || _status == TracingStatus.failed) {
      return;
    }
    if (_activeStrokeIndex >= _strokeReferencePoints.length) return;

    final currentStrokeRef = _strokeReferencePoints[_activeStrokeIndex];
    if (currentStrokeRef.isEmpty) return;

    // Must start near the beginning of the stroke
    final distToStart = (position - currentStrokeRef.first).distance;
    if (distToStart > _startPointThreshold) {
      return;
    }

    if (_activeStrokeIndex == 0 &&
        _currentStroke.isEmpty &&
        !_stopwatch.isRunning) {
      _stopwatch.start();
    }

    _currentStroke = [];
    _status = TracingStatus.tracing;

    _processPoint(position);
    notifyListeners();
  }

  void onPanUpdate(Offset position) {
    if (_status != TracingStatus.tracing) return;
    _processPoint(position);
    notifyListeners();
  }

  void onPanEnd() {
    if (_status != TracingStatus.tracing) return;

    _checkStrokeCompletion();

    if (_status == TracingStatus.tracing) {
      // Stroke wasn't completed and they lifted their finger.
      // Clear the current stroke so they have to try again from the start.
      _currentStroke = [];
      _status = TracingStatus.idle;
    }

    notifyListeners();
  }

  void _processPoint(Offset position) {
    if (_activeStrokeIndex >= _strokeReferencePoints.length) return;
    final currentStrokeRef = _strokeReferencePoints[_activeStrokeIndex];

    final dist = LetterPathData.nearestDistance(position, currentStrokeRef);
    if (dist > _onPathThreshold) return;

    // Find closest index on path to current finger position
    int closestIndex = 0;
    double minDist = double.infinity;
    for (int i = 0; i < currentStrokeRef.length; i++) {
      final d = (position - currentStrokeRef[i]).distance;
      if (d < minDist) {
        minDist = d;
        closestIndex = i;
      }
    }

    // Find furthest index currently drawn
    int currentMaxIndex = -1;
    if (_currentStroke.isNotEmpty) {
      double md = double.infinity;
      for (int i = 0; i < currentStrokeRef.length; i++) {
        final d = (_currentStroke.last - currentStrokeRef[i]).distance;
        if (d < md) {
          md = d;
          currentMaxIndex = i;
        }
      }
    }

    // Fast-drag tolerance (approx 60-80 pixels)
    int maxJump = 40;

    if (closestIndex > currentMaxIndex &&
        closestIndex <= currentMaxIndex + maxJump) {
      _currentStroke = List.from(currentStrokeRef.sublist(0, closestIndex + 1));
    } else if (currentMaxIndex == -1) {
      if (closestIndex <= maxJump) {
        _currentStroke = List.from(
          currentStrokeRef.sublist(0, closestIndex + 1),
        );
      }
    }

    _checkStrokeCompletion();
  }

  void _checkStrokeCompletion() {
    if (_activeStrokeIndex >= _strokeReferencePoints.length) return;
    final currentStrokeRef = _strokeReferencePoints[_activeStrokeIndex];
    if (_currentStroke.isEmpty) return;

    final distToEnd = (_currentStroke.last - currentStrokeRef.last).distance;
    final coverage = _currentStroke.length / currentStrokeRef.length;

    // Must reach the end and cover at least half
    if (distToEnd <= _onPathThreshold && coverage >= 0.50) {
      // Force perfect full-shape save
      _completedStrokes.add(List.from(currentStrokeRef));
      _allDrawnPoints.addAll(currentStrokeRef);
      _currentStroke = [];
      _activeStrokeIndex++;

      if (_activeStrokeIndex >= _strokeReferencePoints.length) {
        _stopwatch.stop();
        _calculateScore();
        _coverageRatio = 1.0;
        _status = TracingStatus.passed;
        // Navigation is now handled by UI listening to passed status
      } else {
        _status = TracingStatus.idle;
      }
    }
  }

  void _calculateScore() {
    final secs = _stopwatch.elapsed.inSeconds;
    if (secs <= 10) {
      _stars = 3;
      _scorePercentage = 100;
    } else if (secs <= 20) {
      _stars = 2;
      _scorePercentage = 80;
    } else {
      _stars = 1;
      _scorePercentage = 60;
    }
  }

  List<String> get _oldCurrentSequence {
    if (_activityType == ActivityType.animals) {
      return LetterInfo.getLetterData().keys.toList();
    } else {
      return ColorInfo.getColorData().map((e) => e.letter).toList();
    }
  }

  void nextLetter() {
    if (!canGoNext) return;

    if (_currentSequence.isNotEmpty && _currentItem != null) {
      int currentIndex =
          _currentSequence.indexWhere((e) => e.id == _currentItem!.id);
      if (currentIndex == -1) currentIndex = 0;
      int nextIndex = (currentIndex + 1) % _currentSequence.length;
      setTracingItem(
          _currentSequence[nextIndex], _currentSequence, _categoryId);
      return;
    }

    // Fallback for old way
    final sequence = _oldCurrentSequence;
    int currentIndex = sequence.indexOf(_currentLetter);
    if (currentIndex == -1) currentIndex = 0;

    int nextIndex = (currentIndex + 1) % sequence.length;
    _currentLetter = sequence[nextIndex];
    _currentLetterIndex =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.indexOf(_currentLetter);

    _resetState();
    _recomputeReference();
    notifyListeners();
  }

  void previousLetter() {
    if (_currentSequence.isNotEmpty && _currentItem != null) {
      int currentIndex =
          _currentSequence.indexWhere((e) => e.id == _currentItem!.id);
      if (currentIndex == -1) currentIndex = 0;
      int prevIndex = (currentIndex - 1 + _currentSequence.length) %
          _currentSequence.length;
      setTracingItem(
          _currentSequence[prevIndex], _currentSequence, _categoryId);
      return;
    }

    // Fallback for old way
    final sequence = _oldCurrentSequence;
    int currentIndex = sequence.indexOf(_currentLetter);
    if (currentIndex == -1) currentIndex = 0;

    int prevIndex = (currentIndex - 1 + sequence.length) % sequence.length;
    _currentLetter = sequence[prevIndex];
    _currentLetterIndex =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.indexOf(_currentLetter);

    _resetState();
    _recomputeReference();
    notifyListeners();
  }

  void retry() {
    _resetState();
    notifyListeners();
  }

  void _resetState() {
    _status = TracingStatus.idle;
    _allDrawnPoints = [];
    _currentStroke = [];
    _completedStrokes = [];
    _activeStrokeIndex = 0;
    _coverageRatio = 0.0;
    _stars = 0;
    _scorePercentage = 0;
    _stopwatch.reset();
  }
}
