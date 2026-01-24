// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:yayvo/core/services/storage/user_session_service.dart';
// import 'package:yayvo/features/auth/presentation/pages/login_page.dart';
//
// class ProfileScreen extends ConsumerWidget {
//   const ProfileScreen({super.key});
//
//   Future<void> _confirmAndLogout(BuildContext context, WidgetRef ref) async {
//     final shouldLogout = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Logout'),
//         content: const Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(true),
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );
//
//     if (shouldLogout != true) return;
//
//     try {
//       await ref.read(userSessionServiceProvider).clearSession();
//       // Remove all previous routes and go to LoginScreen
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//         (route) => false,
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Logout failed: ${e.toString()}')));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Profile')),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               const Expanded(
//                 child: Center(
//                   child: Text('Profile', style: TextStyle(fontSize: 20)),
//                 ),
//               ),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   icon: const Icon(Icons.logout),
//                   label: const Text('Logout'),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                   ),
//                   onPressed: () => _confirmAndLogout(context, ref),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
