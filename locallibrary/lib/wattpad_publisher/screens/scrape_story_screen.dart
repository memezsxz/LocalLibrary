// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// class AddStoryScreen extends StatelessWidget {
//   const AddStoryScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       appBar: AppBar(
//         title: const Text('Add Story'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () => Navigator.of(context).maybePop(),
//           ),
//         ],
//       ),
//       body: const Center(child: Text('…wizard content goes here…')),
//     );
//   }
// }
//
// class AddStoryDialog {
//   static bool _isOpen = false;
//
//   static Future<void> open(BuildContext context) async {
//     if (_isOpen) return; // already open → ignore
//     _isOpen = true;
//
//     try {
//       final w = MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width / 10);
//       final h = MediaQuery.of(context).size.height - (MediaQuery.of(context).size.height / 10);
//       await showGeneralDialog(
//         context: context,
//         barrierDismissible: false,
//         barrierLabel: 'Add Story',
//         barrierColor: Colors.black54,
//         pageBuilder: (ctx, a1, a2) {
//           return Center(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(maxWidth: w, maxHeight: h),
//               child: Material(
//                 elevation: 16,
//                 clipBehavior: Clip.antiAlias,
//                 borderRadius: BorderRadius.circular(16),
//                 child: const _DialogFrame(child: AddStoryScreen()),
//               ),
//             ),
//           );
//         },
//       );
//     } finally {
//       _isOpen = false; // reset when dialog closes
//     }
//   }
// }
//
// // Gives ESC/⌘W handling + safe close.
// class _DialogFrame extends StatelessWidget {
//   final Widget child;
//
//   const _DialogFrame({required this.child});
//
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: true,
//       child: Shortcuts(
//         shortcuts: const {
//           SingleActivator(LogicalKeyboardKey.escape): ActivateIntent(),
//           SingleActivator(LogicalKeyboardKey.keyW, meta: true):
//               ActivateIntent(),
//         },
//         child: Actions(
//           actions: {
//             ActivateIntent: CallbackAction<ActivateIntent>(
//               onInvoke: (e) {
//                 Navigator.of(context).maybePop();
//                 return null;
//               },
//             ),
//           },
//           child: child,
//         ),
//       ),
//     );
//   }
// }
