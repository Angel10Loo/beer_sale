import 'package:beer_sale/model/enums/userRole.dart';
import 'package:beer_sale/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.normal;
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
     Future.microtask(() =>
      Provider.of<UserProvider>(context, listen: false).fetchUsers());
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Usuario es Requerido';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Contrasena es Requerida';
    return null;
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final email = _emailController.text;
      final password = _passwordController.text;
      final name = _nameController.text;
      await Provider.of<UserProvider>(context, listen: false)
          .createUserPlaintext(
        email: email,
        name: name,
        plainPassword: password,
        role: _selectedRole,
        adminUid: "currentAdmin", 
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario Creado con exito!')),
      );

      _formKey.currentState!.reset();
      setState(() => _selectedRole = UserRole.normal);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating user: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardWidth = MediaQuery.of(context).size.width * 0.9;
    final isWide = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear un nuevo usuario', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 700 : cardWidth),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    // ------------------- Form -------------------
                    Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.person_add,
                                  size: 64, color: Colors.deepPurple),
                              const SizedBox(height: 12),
                              Text('Crear Usuario',
                                  style: theme.textTheme.headlineSmall),
                              const SizedBox(height: 24),

                              
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre',
                                  prefixIcon: Icon(Icons.supervised_user_circle_rounded),
                                ),
                              ),

                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Usuario',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 16),
                              

                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Contrasena',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () => setState(
                                        () => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: 16),

                              DropdownButtonFormField<UserRole>(
                                value: _selectedRole,
                                decoration: const InputDecoration(
                                  labelText: 'Rol',
                                  prefixIcon:
                                      Icon(Icons.admin_panel_settings_outlined),
                                ),
                                items: UserRole.values
                                    .map((role) => DropdownMenuItem(
                                          value: role,
                                          child: Text(role.name.toUpperCase()),
                                        ))
                                    .toList(),
                                onChanged: (role) =>
                                    setState(() => _selectedRole = role!),
                              ),
                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _createUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: _loading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          'Crear usuario',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ------------------- List of Users -------------------
                    Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        final users = userProvider.users; // make sure your provider exposes this list
                        if (users.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No hay usuarios aun'),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return  Card(
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  child: ListTile(
    leading: const Icon(Icons.person),
    title: Text(user.email),
    subtitle: Text('Rol: ${user.role.displayName()}'),
    trailing: user.isActive
        ? const Icon(Icons.check_circle, color: Colors.green)
        : const Icon(Icons.block, color: Colors.red),
    onTap: () {
      showDialog(
        context: context,
        builder: (contexDialog) => AlertDialog(
          title: const Text('Editar Usuario'),
          content: Text(
              'Deseas ${user.isActive ? 'desactivar' : 'activar'} este usuario?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contexDialog),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(contexDialog);
                await Provider.of<UserProvider>(context, listen: false)
                    .toggleUserActiveStatus(user);
              },
              child: Text(user.isActive ? 'Desactivar' : 'Activar'),
            ),
          ],
        ),
      );
    },
  ),
);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension on String {
  String displayName() {
    switch (this) {
      case "UserRole.admin":
        return "Admin";
      case "UserRole.normal":
        return "Normal";
    }
    return "";
  }
}
