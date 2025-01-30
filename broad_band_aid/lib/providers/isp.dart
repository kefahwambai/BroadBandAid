import 'package:flutter/material.dart';
import '../models/isp_plan.dart';
import '../services/api.dart';

class ISPProvider extends ChangeNotifier {
  List<ISPPlan> _plans = [];
  bool _isLoading = false;
  String _error = '';

  List<ISPPlan> get plans => _plans;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchPlans() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _plans = await ApiService.fetchISPPlans();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
