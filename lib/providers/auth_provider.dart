import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? currentUser;
  String? role;
  DateTime? lastActivity;

  // configuración pública (puedes ajustar)
  int maxFailedAttempts = 3;
  int lockDurationSeconds = 30;

  // datos en memoria (username -> hashedPassword)
  final Map<String, String> _users = {};
  final Map<String, String> _roles = {};

  final Map<String, int> _failedAttempts = {};
  final Map<String, DateTime> _lockedUntil = {};

  static const _kAuthUserKey = 'auth_current_user';

  AuthProvider() {
    // usuarios de ejemplo (passwords hashed)
    _addUser('juan', '1234', 'rider');
    _addUser('maria', 'abcd', 'rider');
    _addUser('admin', 'admin', 'supervisor');
    _loadAuthFromPrefs(); // intentar restaurar sesión previa
  }

  // simple SHA256 hashing
  String _hash(String plain) {
    final bytes = utf8.encode(plain);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _addUser(String username, String password, String userRole) {
    _users[username] = _hash(password);
    _roles[username] = userRole;
  }

  bool isLocked(String username) {
    final until = _lockedUntil[username];
    if (until == null) return false;
    if (DateTime.now().isAfter(until)) {
      _lockedUntil.remove(username);
      _failedAttempts[username] = 0;
      return false;
    }
    return true;
  }

  int lockRemaining(String username) {
    final until = _lockedUntil[username];
    if (until == null) return 0;
    final sec = until.difference(DateTime.now()).inSeconds;
    return sec > 0 ? sec : 0;
  }

  // login maneja bloqueo y conteo
  bool login(String username, String password) {
    username = username.trim().toLowerCase();
    if (isLocked(username)) return false;

    final storedHash = _users[username];
    final providedHash = _hash(password);

    if (storedHash != null && storedHash == providedHash) {
      currentUser = username;
      role = _roles[username];
      _failedAttempts[username] = 0;
      _lockedUntil.remove(username);
      _saveAuthToPrefs();
      notifyListeners();
      return true;
    } else {
      _failedAttempts[username] = (_failedAttempts[username] ?? 0) + 1;
      if (_failedAttempts[username]! >= maxFailedAttempts) {
        _lockedUntil[username] = DateTime.now().add(Duration(seconds: lockDurationSeconds));
      }
      notifyListeners();
      return false;
    }
  }

  void logout() {
    currentUser = null;
    role = null;
    _clearAuthPrefs();
    notifyListeners();
  }

  Future<void> _saveAuthToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (currentUser != null) {
        await prefs.setString(_kAuthUserKey, currentUser!);
      } else {
        await prefs.remove(_kAuthUserKey);
      }
    } catch (_) {}
  }

  Future<void> _clearAuthPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kAuthUserKey);
    } catch (_) {}
  }

  Future<void> _loadAuthFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final u = prefs.getString(_kAuthUserKey);
      if (u != null && _users.containsKey(u)) {
        currentUser = u;
        role = _roles[u];
        notifyListeners();
      }
    } catch (_) {}
  }

  // Compatibilidad: actualizar actividad (no-op / mantiene lastActivity si se desea)
  void updateActivity() {
    // Mantener minimalismo: actualiza lastActivity para compatibilidad,
    // pero no inicia ni depende de ningún temporizador de inactividad.
    lastActivity = DateTime.now();
    // no notifyListeners() necesario, pero lo dejamos por si la UI necesita refrescarse
    notifyListeners();
  }
}
