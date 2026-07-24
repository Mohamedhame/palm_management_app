import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _hasConnection = true;

  bool get hasConnection => _hasConnection;

  NetworkProvider() {
    _initializeConnectivity();
  }

  void _initializeConnectivity() {
    // المتابعة المستمرة للتغيرات في الخلفية أثناء عمل التطبيق
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      checkConnection();
    });
  }

  // دالة فحص صريحة ينتظرها الـ Splash Screen
  Future<bool> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      
      if (results.contains(ConnectivityResult.none) || results.isEmpty) {
        _hasConnection = false;
      } else {
        // فحص وصول إنترنت حقيقي
        _hasConnection = await _checkRealInternetAccess();
      }
    } catch (_) {
      _hasConnection = false;
    }

    notifyListeners();
    return _hasConnection;
  }

  Future<bool> _checkRealInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
          
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}