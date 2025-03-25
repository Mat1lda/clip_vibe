import 'package:flutter/material.dart';

class SaveModel extends ChangeNotifier {
  double? isSaving;

  SaveModel({
    this.isSaving = 0.0,
  });

  updateSaving(progress) {
    isSaving = progress;
    notifyListeners();
  }
}