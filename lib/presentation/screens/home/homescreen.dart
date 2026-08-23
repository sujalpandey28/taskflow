// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:taskflow/presentation/screens/notification/notifications_screen.dart';
// import 'package:taskflow/presentation/screens/projects/project_list.dart';

// import '../../providers/auth_provider.dart';
// import '../auth/login_screen.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = context.watch<AuthProvider>();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('TaskFlow'),
//         actions: [
//           IconButton(
//             onPressed: () async {
//               await context.read<AuthProvider>().logout();

//               if (!context.mounted) return;

//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (_) => const LoginScreen()),
//                 (route) => false,
//               );
//             },
//             icon: const Icon(Icons.logout),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Welcome to TaskFlow',
//                 style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 24),

//               Text('Email: ${authProvider.email ?? 'Unknown'}'),

//               const SizedBox(height: 8),

//               Text('Organization: ${authProvider.orgId ?? 'Unknown'}'),

//               const SizedBox(height: 8),

//               Text('Role: ${authProvider.role ?? 'Unknown'}'),

//               const SizedBox(height: 32),

//               if (authProvider.isAdmin)
//                 const Card(
//                   child: ListTile(
//                     leading: Icon(Icons.admin_panel_settings),
//                     title: Text('Organization Admin'),
//                     subtitle: Text('You have administrative permissions.'),
//                   ),
//                 )
//               else
//                 const Card(
//                   child: ListTile(
//                     leading: Icon(Icons.person),
//                     title: Text('Organization Member'),
//                     subtitle: Text('You have member permissions.'),
//                   ),
//                 ),

//               const SizedBox(height: 24),

//               const Text(
//                 'Projects',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 12),

//               Card(
//                 child: ListTile(
//                   leading: const Icon(Icons.folder),
//                   title: const Text('Projects'),
//                   subtitle: const Text('View and manage organization projects'),
//                   trailing: const Icon(Icons.chevron_right),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const ProjectListScreen(),
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               const SizedBox(height: 12),

//               Card(
//                 child: ListTile(
//                   onTap: () {
//                     final authProvider = context.read<AuthProvider>();

//                     final userId = authProvider.userId;

//                     if (userId == null) {
//                       return;
//                     }

//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => NotificationsScreen(userId: userId),
//                       ),
//                     );
//                   },
//                   leading: Icon(Icons.notifications),
//                   title: Text('Notifications'),
//                   subtitle: Text('View your notifications'),
//                   trailing: Icon(Icons.chevron_right),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskflow/presentation/screens/notification/notifications_screen.dart';
import 'package:taskflow/presentation/screens/projects/project_list.dart';
import 'package:taskflow/presentation/screens/qa/qa_screens.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color primaryColor = Color(0xFF6C4AB6);
  static const Color pageBackground = Color(0xFFF6F3FC);
  static const Color darkText = Color(0xFF241B2F);
  static const Color secondaryText = Color(0xFF6F6878);
  static const Color lightPurple = Color(0xFFE9E1F7);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        elevation: 0,
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(Icons.task_alt_rounded, color: primaryColor, size: 28),
            SizedBox(width: 10),
            Text(
              'TaskFlow',
              style: TextStyle(color: darkText, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthProvider>().logout();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded, color: darkText),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            const Text(
              'Welcome back!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Here’s what’s happening with your workspace.',
              style: const TextStyle(fontSize: 15, color: secondaryText),
            ),

            const SizedBox(height: 24),

            // User information card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2DCEB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: lightPurple,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: primaryColor,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.email ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Organization: ${authProvider.orgId ?? 'Unknown'}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: secondaryText,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: lightPurple,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            authProvider.isAdmin
                                ? 'Organization Admin'
                                : 'Organization Member',
                            style: const TextStyle(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Workspace',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),

            const SizedBox(height: 12),

            // Projects
            _HomeActionCard(
              icon: Icons.folder_outlined,
              title: 'Projects',
              subtitle: 'View and manage organization projects',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProjectListScreen()),
                );
              },
            ),

            const SizedBox(height: 12),

            // Notifications
            _HomeActionCard(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              subtitle: 'View your latest notifications',
              onTap: () {
                final userId = authProvider.userId;

                if (userId == null) {
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationsScreen(userId: userId),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _HomeActionCard(
              icon: Icons.science_outlined,
              title: 'QA Simulation',
              subtitle: 'Test loading, offline and error scenarios',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QaSimulationScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  static const Color primaryColor = Color(0xFF6C4AB6);
  static const Color darkText = Color(0xFF241B2F);
  static const Color secondaryText = Color(0xFF6F6878);
  static const Color lightPurple = Color(0xFFE9E1F7);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2DCEB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: lightPurple,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: primaryColor, size: 25),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right_rounded, color: secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}
