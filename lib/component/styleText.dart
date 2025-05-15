import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/main.dart';
import 'package:nb_utils/nb_utils.dart';


class StyledText extends StatelessWidget {
  final String text;

  const StyledText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      text,
      // Optional custom styling
      textStyle: TextStyle(
        fontSize: 16.0,
        color: settingsController.isDarkMode.value ? white : black,
      ),
      onTapUrl: (url) {
        // Handle link taps
        // Example: Open the URL in an external browser or WebView
        // launchUrlString(url);
        return true;
      },
      factoryBuilder: () => _StyledHtmlFactory(),
    );
  }
}

// Custom HTML factory to handle image preview on tap
class _StyledHtmlFactory extends WidgetFactory {
  @override
  Widget? buildImageWidget(BuildMetadata meta, ImageSource src) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: Get.context!,
          builder: (context) {
            return Dialog(
              child: Image.network(src.url),
            );
          },
        );
      },
      child: Image.network(src.url),
    );
  }
}
