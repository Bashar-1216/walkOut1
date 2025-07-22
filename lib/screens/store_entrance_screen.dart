import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/session_service.dart';
import 'live_cart_screen.dart';

class StoreEntranceScreen extends StatefulWidget {
  const StoreEntranceScreen({super.key});

  @override
  State<StoreEntranceScreen> createState() => _StoreEntranceScreenState();
}

class _StoreEntranceScreenState extends State<StoreEntranceScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final SessionService _sessionService = SessionService();

  bool _isLoading = false;
  String? _userJwtToken;
  int? _currentSessionId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadToken();
    await _prepareSession();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return; // ← guard
    setState(() {
      _userJwtToken = prefs.getString("auth_token");
    });
  }

  Future<void> _prepareSession() async {
    final sessionId = await _sessionService.getActiveSession();
    if (!mounted) return; // ← guard
    setState(() {
      _currentSessionId = sessionId;
    });
  }

  Future<void> _authenticateAndStartSession() async {
    setState(() => _isLoading = true);

    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: "Please authenticate to start shopping",
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (_) {}

    if (!mounted) {
      return;
    }
    setState(() => _isLoading = false);

    if (!authenticated) return;

    int? sessionId = _currentSessionId;
    if (sessionId == null) {
      sessionId = await _sessionService.startSession();
    }

    if (!mounted) return; // ← guard
    if (sessionId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => LiveCartScreen(sessionId: sessionId!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not start session")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Store Entry")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Scan QR at the gate, then confirm entry.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    if (_currentSessionId != null)
                      QrImageView(
                        data: _currentSessionId.toString(),
                        version: QrVersions.auto,
                        size: 220.0,
                      )
                    else
                      const Text(
                        "No active session found.",
                        style: TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.fingerprint, size: 28),
                      label: const Text(
                        "Confirm Entry",
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _userJwtToken != null
                          ? _authenticateAndStartSession
                          : null,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}