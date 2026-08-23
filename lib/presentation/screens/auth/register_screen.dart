// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:taskflow/presentation/providers/auth_provider.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();

//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   Future<void> _register() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     final authProvider = context.read<AuthProvider>();

//     final success = await authProvider.register(
//       email: _emailController.text.trim(),
//       password: _passwordController.text,
//     );

//     if (!mounted) return;

//     setState(() {
//       _isLoading = false;
//     });

//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Account created successfully. Please sign in.'),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );

//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             authProvider.errorMessage ?? 'Failed to create account.',
//           ),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: theme.colorScheme.surface,
//       appBar: AppBar(title: const Text('Create Account'), centerTitle: true),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 430),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Icon
//                     Center(
//                       child: Container(
//                         width: 72,
//                         height: 72,
//                         decoration: BoxDecoration(
//                           color: theme.colorScheme.primary,
//                           borderRadius: BorderRadius.circular(20),
//                           boxShadow: [
//                             BoxShadow(
//                               color: theme.colorScheme.primary.withValues(
//                                 alpha: 0.20,
//                               ),
//                               blurRadius: 18,
//                               offset: const Offset(0, 8),
//                             ),
//                           ],
//                         ),
//                         child: Icon(
//                           Icons.person_add_alt_1_rounded,
//                           size: 38,
//                           color: theme.colorScheme.onPrimary,
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 24),

//                     Text(
//                       'Create your account',
//                       textAlign: TextAlign.center,
//                       style: theme.textTheme.headlineMedium?.copyWith(
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),

//                     const SizedBox(height: 8),

//                     Text(
//                       'Join TaskFlow and start managing your work.',
//                       textAlign: TextAlign.center,
//                       style: theme.textTheme.bodyMedium?.copyWith(
//                         color: theme.colorScheme.onSurfaceVariant,
//                         height: 1.5,
//                       ),
//                     ),

//                     const SizedBox(height: 32),

//                     // Name
//                     Text(
//                       'Full name',
//                       style: theme.textTheme.labelLarge?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),

//                     const SizedBox(height: 8),

//                     TextFormField(
//                       controller: _nameController,
//                       textInputAction: TextInputAction.next,
//                       decoration: InputDecoration(
//                         hintText: 'Enter your full name',
//                         prefixIcon: const Icon(Icons.person_outline_rounded),
//                         filled: true,
//                         fillColor: theme.colorScheme.surfaceContainerHighest
//                             .withValues(alpha: 0.35),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(
//                             color: theme.colorScheme.outline.withValues(
//                               alpha: 0.25,
//                             ),
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(
//                             color: theme.colorScheme.primary,
//                             width: 1.5,
//                           ),
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Name is required';
//                         }

//                         if (value.trim().length < 2) {
//                           return 'Enter a valid name';
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 18),

//                     // Email
//                     Text(
//                       'Email',
//                       style: theme.textTheme.labelLarge?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),

//                     const SizedBox(height: 8),

//                     TextFormField(
//                       controller: _emailController,
//                       keyboardType: TextInputType.emailAddress,
//                       textInputAction: TextInputAction.next,
//                       decoration: InputDecoration(
//                         hintText: 'Enter your email',
//                         prefixIcon: const Icon(Icons.email_outlined),
//                         filled: true,
//                         fillColor: theme.colorScheme.surfaceContainerHighest
//                             .withValues(alpha: 0.35),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(
//                             color: theme.colorScheme.outline.withValues(
//                               alpha: 0.25,
//                             ),
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(
//                             color: theme.colorScheme.primary,
//                             width: 1.5,
//                           ),
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Email is required';
//                         }

//                         if (!value.contains('@')) {
//                           return 'Enter a valid email';
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 18),

//                     // Password
//                     Text(
//                       'Password',
//                       style: theme.textTheme.labelLarge?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),

//                     const SizedBox(height: 8),

//                     TextFormField(
//                       controller: _passwordController,
//                       obscureText: _obscurePassword,
//                       textInputAction: TextInputAction.next,
//                       decoration: InputDecoration(
//                         hintText: 'Create a password',
//                         prefixIcon: const Icon(Icons.lock_outline_rounded),
//                         suffixIcon: IconButton(
//                           tooltip: _obscurePassword
//                               ? 'Show password'
//                               : 'Hide password',
//                           onPressed: () {
//                             setState(() {
//                               _obscurePassword = !_obscurePassword;
//                             });
//                           },
//                           icon: Icon(
//                             _obscurePassword
//                                 ? Icons.visibility_outlined
//                                 : Icons.visibility_off_outlined,
//                           ),
//                         ),
//                         filled: true,
//                         fillColor: theme.colorScheme.surfaceContainerHighest
//                             .withValues(alpha: 0.35),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(
//                             color: theme.colorScheme.outline.withValues(
//                               alpha: 0.25,
//                             ),
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(
//                             color: theme.colorScheme.primary,
//                             width: 1.5,
//                           ),
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Password is required';
//                         }

//                         if (value.length < 8) {
//                           return 'Password must be at least 8 characters';
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 18),

//                     // Confirm password
//                     Text(
//                       'Confirm password',
//                       style: theme.textTheme.labelLarge?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),

//                     const SizedBox(height: 8),

//                     TextFormField(
//                       controller: _confirmPasswordController,
//                       obscureText: _obscureConfirmPassword,
//                       textInputAction: TextInputAction.done,
//                       onFieldSubmitted: (_) {
//                         if (!_isLoading) {
//                           _register();
//                         }
//                       },
//                       decoration: InputDecoration(
//                         hintText: 'Confirm your password',
//                         prefixIcon: const Icon(Icons.lock_outline_rounded),
//                         suffixIcon: IconButton(
//                           tooltip: _obscureConfirmPassword
//                               ? 'Show password'
//                               : 'Hide password',
//                           onPressed: () {
//                             setState(() {
//                               _obscureConfirmPassword =
//                                   !_obscureConfirmPassword;
//                             });
//                           },
//                           icon: Icon(
//                             _obscureConfirmPassword
//                                 ? Icons.visibility_outlined
//                                 : Icons.visibility_off_outlined,
//                           ),
//                         ),
//                         filled: true,
//                         fillColor: theme.colorScheme.surfaceContainerHighest
//                             .withValues(alpha: 0.35),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(
//                             color: theme.colorScheme.outline.withValues(
//                               alpha: 0.25,
//                             ),
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(
//                             color: theme.colorScheme.primary,
//                             width: 1.5,
//                           ),
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please confirm your password';
//                         }

//                         if (value != _passwordController.text) {
//                           return 'Passwords do not match';
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 28),

//                     // Create account button
//                     SizedBox(
//                       height: 54,
//                       child: ElevatedButton.icon(
//                         onPressed: _isLoading ? null : _register,
//                         icon: _isLoading
//                             ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2.2,
//                                 ),
//                               )
//                             : const Icon(Icons.person_add_alt_1_rounded),
//                         label: Text(
//                           _isLoading ? 'Creating account...' : 'Create account',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           elevation: 5,
//                           shadowColor: theme.colorScheme.primary.withValues(
//                             alpha: 0.35,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 18),

//                     TextButton(
//                       onPressed: _isLoading
//                           ? null
//                           : () {
//                               Navigator.pop(context);
//                             },
//                       child: const Text('Already have an account? Sign in'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskflow/presentation/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully. Please sign in.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Failed to create account.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FC),
      // appBar: AppBar(
      //   title: const Text(
      //     'Create Account',
      //     style: TextStyle(
      //       color: Color(0xFF241B2F),
      //       fontWeight: FontWeight.w600,
      //     ),
      //   ),
      //   centerTitle: true,
      //   backgroundColor: const Color(0xFFF6F3FC),
      //   foregroundColor: const Color(0xFF241B2F),
      //   elevation: 0,
      // ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9E1F7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 38,
                          color: Color(0xFF6C4AB6),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Create your account',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF241B2F),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Join TaskFlow and start managing your work.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF6F6878),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Name
                    Text(
                      'Full name',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF241B2F),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFF6C4AB6),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2DCEB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF6C4AB6),
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }

                        if (value.trim().length < 2) {
                          return 'Enter a valid name';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Email
                    Text(
                      'Email',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF241B2F),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Color(0xFF6C4AB6),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2DCEB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF6C4AB6),
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }

                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Password
                    Text(
                      'Password',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF241B2F),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Create a password',
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF6C4AB6),
                        ),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF6C4AB6),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2DCEB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF6C4AB6),
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }

                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Confirm password
                    Text(
                      'Confirm password',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF241B2F),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!_isLoading) {
                          _register();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Confirm your password',
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF6C4AB6),
                        ),
                        suffixIcon: IconButton(
                          tooltip: _obscureConfirmPassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF6C4AB6),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2DCEB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF6C4AB6),
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }

                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    // Create account button
                    SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _register,
                        icon: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.person_add_alt_1_rounded),
                        label: Text(
                          _isLoading ? 'Creating account...' : 'Create account',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C4AB6),
                          foregroundColor: Colors.white,
                          elevation: 5,
                          shadowColor: const Color(
                            0xFF6C4AB6,
                          ).withValues(alpha: 0.30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      child: const Text(
                        'Already have an account? Sign in',
                        style: TextStyle(
                          color: Color(0xFF6C4AB6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
