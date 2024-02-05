// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class Accordion extends StatefulWidget {
  final List<AccordionItem> items;

  const Accordion({super.key, required this.items});

  @override
  _AccordionState createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ExpansionPanelList(
        elevation: 1,
        expandedHeaderPadding: const EdgeInsets.all(0),
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            widget.items[index].isExpanded = !isExpanded;
          });
        },
        dividerColor: context.iconColor,
        children: widget.items.map<ExpansionPanel>((AccordionItem item) {
          return ExpansionPanel(
            canTapOnHeader: true,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: item.header,
              );
            },
            body: item.content,
            isExpanded: item.isExpanded,
          );
        }).toList(),
      ),
    );
  }
}

class AccordionItem {
  Widget header;
  Widget content;
  bool isExpanded;

  AccordionItem({
    required this.header,
    required this.content,
    this.isExpanded = false,
  });
}
