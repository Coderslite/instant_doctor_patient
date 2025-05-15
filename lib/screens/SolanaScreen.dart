// class AuthorizeButton extends StatefulWidget {
//   const AuthorizeButton({super.key});
//   @override
//   State<AuthorizeButton> createState() => _AuthorizeButtonState();
// }

// class _AuthorizeButtonState extends State<AuthorizeButton> {
//   Object? _output;
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         TextButton(
//           onPressed: () {
//             // 2. Authorize application with wallet.
//             adapter.authorize()
//               .then((result) => setState(() => _output = result.toJson()))
//               .catchError((error) => setState(() => _output = error));
//           },
//           child: const Text('Authorize'),
//         ),
//         if (_output != null)
//           Text(_output.toString()),
//       ],
//     );
//   }
// }