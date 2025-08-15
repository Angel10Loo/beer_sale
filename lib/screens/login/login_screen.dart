// lib/screens/login/login_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';

typedef AuthCallback = Future<bool> Function(String email, String password);

class LoginScreen extends StatefulWidget {
  final AuthCallback onLogin;
  final VoidCallback? onSuccess;
  final VoidCallback? onForgotPassword;

  const LoginScreen({
    Key? key,
    required this.onLogin,
    this.onSuccess,
    this.onForgotPassword,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa tu usuario';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text;
      final success = await widget.onLogin(email, password);

      if (success) {
        widget.onSuccess?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario o contraseña inválidos')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de inicio de sesión: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Left info panel (keeps simple content)
  Widget _infoPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade500, Colors.indigo.shade300],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield_rounded, size: 72, color: Colors.white),
          const SizedBox(height: 16),
          Text('Acceso seguro',
              style: theme.textTheme.titleMedium!.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            'Solo usuarios autorizados por su administrador pueden ingresar',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium!.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // Right form panel — returns a widget that is safe to put inside a scroll view
  Widget _formContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min, // important: don't force max height here
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, size: 40, color: Colors.indigo),
          ),
          const SizedBox(height: 12),
          Text('Bienvenido', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('Inicia sesión para continuar',
              style: theme.textTheme.bodyMedium!.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 20),

          // Form
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: _validatePassword,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _loading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Iniciando...'),
                            ],
                          )
                        : const Text('Iniciar sesión'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          Text(
            'Solo usuarios autorizados por su administrador pueden ingresar',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height - media.padding.vertical;
    final isWide = screenWidth >= 800;

    // Limit card height to 90% of available height but not more than a reasonable cap
    final double cardMaxHeight = min(screenHeight * 0.90, 780);

    final double cardMaxWidth = isWide ? 900 : screenWidth * 0.95;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade700, Colors.indigo.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SizedBox(
              width: cardMaxWidth,
              // critical: cap the height so the card can scroll inside
              height: cardMaxHeight,
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: isWide
                    ? Row(
                        children: [
                          // left panel (fixed fraction)
                          Flexible(
                            flex: 5,
                            child: _infoPanel(theme),
                          ),

                          // right panel: allow internal scrolling if content taller than available
                          Flexible(
                            flex: 7,
                            child: SingleChildScrollView(
                              // ensure scrolling when needed
                              padding: EdgeInsets.zero,
                              child: _formContent(theme),
                            ),
                          ),
                        ],
                      )
                    : // narrow layout: stack vertically and allow scrolling
                    SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // show info panel first (no Expanded here)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                gradient: LinearGradient(
                                  colors: [Colors.indigo.shade500, Colors.indigo.shade300],
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.shield_rounded, size: 64, color: Colors.white),
                                  const SizedBox(height: 12),
                                  Text('Acceso seguro',
                                      style: theme.textTheme.titleMedium!.copyWith(color: Colors.white)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Solo usuarios autorizados por su administrador pueden ingresar',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium!.copyWith(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),

                            // form content
                            _formContent(theme),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
