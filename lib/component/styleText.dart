// import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:html/parser.dart' show parse;
// import 'package:instant_doctor/main.dart';
// import 'package:nb_utils/nb_utils.dart';

// class StyledText extends StatelessWidget {
//   final String htmlContent;

//   const StyledText(this.htmlContent, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     final cleanedHtml = _preprocessHtml(htmlContent);

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Html(
//         data: cleanedHtml,
//         style: {
//           "body": Style(
//             fontSize: FontSize(16),
//             color: settingsController.isDarkMode.value
//                 ? white
//                 : const Color(0xFF334155),
//             lineHeight: const LineHeight(1.6),
//             fontFamily: 'Helvetica Neue',
//           ),
//           "h1": Style(
//             fontSize: FontSize(24),
//             fontWeight: FontWeight.bold,
//             color: settingsController.isDarkMode.value ? white : Colors.black87,
//           ),
//           "h2": Style(
//             fontSize: FontSize(22),
//             fontWeight: FontWeight.bold,
//             color: settingsController.isDarkMode.value ? white : Colors.black87,
//           ),
//           "h3": Style(
//             fontSize: FontSize(20),
//             fontWeight: FontWeight.w600,
//           ),
//           "p": Style(
//             margin: Margins.only(bottom: 12),
//           ),
//           "a": Style(
//             color: const Color(0xFF00AEEF),
//             textDecoration: TextDecoration.underline,
//           ),
//           "img": Style(
//             margin: Margins.symmetric(vertical: 12),
//           ),
//           ".tip-card": Style(
//             padding: HtmlPaddings.all(20),
//             margin: Margins.only(bottom: 16),
//             backgroundColor: context.cardColor,
//             border: Border.all(color: const Color(0xFF00AEEF), width: 1),
//           ),
//         },
//       ),
//     );
//   }

//   /// Sanitize and clean the HTML input (remove scripts, bad layout styles, etc.)
//   String _preprocessHtml(String html) {
//     try {
//       final document = parse(html);
//       document.querySelectorAll('script, head').forEach((e) => e.remove());
//       document.querySelectorAll('.header').forEach((e) => e.remove());
//       document.querySelectorAll('.hero-image').forEach((e) => e.remove());
//       document.querySelectorAll('.blog-header').forEach((e) => e.remove());
//       document.querySelectorAll('.footer').forEach((e) => e.remove());

//       for (final element in document.querySelectorAll('[style]')) {
//         final style = element.attributes['style']!;
//         final cleaned = style
//             .replaceAll(RegExp(r'position\s*:\s*[^;]+;?'), '')
//             .replaceAll(RegExp(r'float\s*:\s*[^;]+;?'), '')
//             .replaceAll(RegExp(r'width\s*:\s*[^;]+;?'), '')
//             .replaceAll(RegExp(r'height\s*:\s*[^;]+;?'), '')
//             .trim();
//         if (cleaned.isEmpty) {
//           element.attributes.remove('style');
//         } else {
//           element.attributes['style'] = cleaned;
//         }
//       }
//       return document.body?.innerHtml ?? html;
//     } catch (e) {
//       return html;
//     }
//   }
// }
