import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ValueNotifier<bool> {
  AuthController({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync(),
      super(false);

  static const _accessTokenKey = 'auth.accessToken';
  static const _refreshTokenKey = 'auth.refreshToken';
  static const _userIdKey = 'auth.userId';
  static const _nicknameKey = 'auth.nickname';

  final SharedPreferencesAsync _preferences;

  String? _accessToken;
  String? _refreshToken;
  int? _userId;
  String? _nickname;
  bool _isRestoring = false;
  bool _isInitialized = false;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  int? get userId => _userId;
  String? get nickname => _nickname;
  bool get isLoggedIn => value;
  bool get isRestoring => _isRestoring;
  bool get isInitialized => _isInitialized;

  Future<void> login({
    required String accessToken,
    required String refreshToken,
    required int userId,
    required String nickname,
  }) async {
    await _preferences.setString(_accessTokenKey, accessToken);
    // TODO: For production mobile release, refreshToken should be stored in secure storage.
    await _preferences.setString(_refreshTokenKey, refreshToken);
    await _preferences.setInt(_userIdKey, userId);
    await _preferences.setString(_nicknameKey, nickname);

    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _userId = userId;
    _nickname = nickname;
    _setLoggedIn(true);
  }

  Future<void> restoreSession() async {
    _isRestoring = true;
    notifyListeners();

    try {
      final accessToken = await _preferences.getString(_accessTokenKey);
      final refreshToken = await _preferences.getString(_refreshTokenKey);
      final userId = await _preferences.getInt(_userIdKey);
      final nickname = await _preferences.getString(_nicknameKey);
      final hasTokens =
          accessToken?.isNotEmpty == true && refreshToken?.isNotEmpty == true;

      _accessToken = hasTokens ? accessToken : null;
      _refreshToken = hasTokens ? refreshToken : null;
      _userId = hasTokens ? userId : null;
      _nickname = hasTokens ? nickname : null;
      _setLoggedIn(hasTokens);
    } catch (error) {
      debugPrint('Auth session restore failed: $error');
      _clearMemory();
      _setLoggedIn(false);
    } finally {
      _isRestoring = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _preferences.clear(
        allowList: {
          _accessTokenKey,
          _refreshTokenKey,
          _userIdKey,
          _nicknameKey,
        },
      );
    } finally {
      _clearMemory();
      _setLoggedIn(false);
    }
  }

  void _clearMemory() {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _nickname = null;
  }

  void _setLoggedIn(bool isLoggedIn) {
    if (value == isLoggedIn) {
      notifyListeners();
      return;
    }
    value = isLoggedIn;
  }
}

final mockAuthController = AuthController();
