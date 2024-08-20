import 'package:flutter/material.dart';
import 'package:splitwise/providers/providers.dart';

class HistoryList extends StatefulWidget {
  const HistoryList(
      {super.key, required this.historyArray, required this.expenseProvider});

  final List<Map<String, dynamic>> historyArray;
  final ExpenseProvider expenseProvider;

  @override
  State<HistoryList> createState() => _ExpenseHistoryListState();
}

class _ExpenseHistoryListState extends State<HistoryList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // physics: const BouncingScrollPhysics(),
      itemCount: widget.historyArray.length,
      itemBuilder: (context, indexList) {
        final acreedor = widget.historyArray[indexList]["creditor"];
        final debtor = widget.historyArray[indexList]["debtor"];

        return Column(
          children: [
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      widget.expenseProvider.isExpanded[indexList] =
                          !widget.expenseProvider.isExpanded[indexList];
                    });
                  },
                  children: [
                    ExpansionPanel(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          double montoTotal =
                              widget.historyArray[indexList]["amount"];

                          return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                " Monto total: $montoTotal",
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 0, 0, 0)),
                              ));
                        },
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        isExpanded:
                            widget.expenseProvider.isExpanded[indexList],
                        body: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: Row(children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Acreedor",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    acreedor["username"],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    acreedor["email"],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Deudor",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    debtor["username"],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    debtor["email"],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ]))
                        //         ListTile(

                        ),
                  ],
                )),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
}
