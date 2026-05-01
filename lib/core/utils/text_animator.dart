import 'dart:async';
import 'package:flutter/material.dart';

class TextAnimator {
  Timer? _timer;
  String _displayedText = '';
  int _currentIndex = 0;
  
  String get displayedText => _displayedText;
  
  void animateText({
    required String fullText,
    required VoidCallback onUpdate,
    Duration speed = const Duration(milliseconds: 20),
    VoidCallback? onComplete,
  }) {
    _timer?.cancel();
    _displayedText = '';
    _currentIndex = 0;
    onUpdate();
    
    _timer = Timer.periodic(speed, (timer) {
      if (_currentIndex < fullText.length) {
        _displayedText += fullText[_currentIndex];
        _currentIndex++;
        onUpdate();
      } else {
        timer.cancel();
        onComplete?.call();
      }
    });
  }
  
  void dispose() {
    _timer?.cancel();
  }
}