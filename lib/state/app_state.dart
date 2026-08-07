/// Global app state — current project selection, backend URL, last-loaded data.
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';

class AppState extends ChangeNotifier {
  ApiClient _api = ApiClient();
  ApiClient get api => _api;

  String? _currentProject;
  String? get currentProject => _currentProject;

  String backendUrl = 'http://100.126.122.39:8765';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('backend_url');
    if (saved != null && saved.isNotEmpty) {
      backendUrl = saved;
      _api = ApiClient(baseUrl: saved);
    }
    notifyListeners();
  }

  Future<void> setBackendUrl(String url) async {
    backendUrl = url;
    _api = ApiClient(baseUrl: url);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('backend_url', url);
    notifyListeners();
  }

  void selectProject(String? id) {
    _currentProject = id;
    notifyListeners();
  }
}
