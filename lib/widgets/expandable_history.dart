import 'package:flutter/material.dart';

class ExpandableHistory extends StatefulWidget {
  const ExpandableHistory({
    required this.expense,
    super.key,
  });
  final Map<String, dynamic> expense;

  @override
  State<ExpandableHistory> createState() => _ExpandableHistoryState();
}

class _ExpandableHistoryState extends State<ExpandableHistory> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        children: [
          ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Gasto Id: ${widget.expense["id"]} con total ${widget.expense["total_debt"]}',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0)),
                    ));
              },
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              isExpanded: _isExpanded,
              body: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.expense["users"].length,
                itemBuilder: (context, index) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: ListTile(
                    title: Text(
                      widget.expense["users"][index]["username"]!,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      widget.expense["users"][index]["email"]!,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Text(
                      widget.expense["users"][index]["debt"]!,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              )),
        ]);
  }
}
