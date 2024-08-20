import 'package:flutter/material.dart';
import 'package:splitwise/providers/providers.dart';

class ExpenseHistoryList extends StatefulWidget {
  const ExpenseHistoryList(
      {super.key,
      required this.arrayExpenses,
      required this.expenseProvider,
      required this.groupId,
      required this.groupName,
      required this.profileProvider});

  final List<Map<String, dynamic>> arrayExpenses;
  final ExpenseProvider expenseProvider;
  final String groupName;
  final int groupId;
  final ProfileProvider profileProvider;

  @override
  State<ExpenseHistoryList> createState() => _ExpenseHistoryListState();
}

class _ExpenseHistoryListState extends State<ExpenseHistoryList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // physics: const BouncingScrollPhysics(),
      itemCount: widget.arrayExpenses.length,
      itemBuilder: (context, indexList) {
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
                          print("${widget.arrayExpenses[indexList]}");
                          return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                widget.arrayExpenses[indexList]["description"],
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
                        body: ListView.separated(
                            separatorBuilder: (_, i) => const Divider(
                                  thickness: 1,
                                  color: Colors.black,
                                ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget
                                .arrayExpenses[indexList]["participants"]
                                .length,
                            itemBuilder: (context, index2) {
                              double montoTotal = 0;
                              final List<Map<String, dynamic>> participants =
                                  widget.arrayExpenses[indexList]
                                      ["participants"];
                              for (final participant in participants) {
                                if (participant["total_spent"].runtimeType ==
                                    int) {
                                  participant["total_spent"] =
                                      (participant["total_spent"] as int)
                                          .toDouble();
                                } else if (participant["total_spent"]
                                        .runtimeType ==
                                    String) {
                                  participant["total_spent"] = double.parse(
                                      participant["total_spent"] as String);
                                }
                                montoTotal += participant["total_spent"];
                              }
                              final user = widget.arrayExpenses[indexList]
                                  ["participants"][index2];
                              // final debe = widget
                              //         .expenseMap[keys[indexList]]![index2]
                              //     ["total_spent"];
                              // final paid = widget
                              //         .expenseMap[keys[indexList]]![index2]
                              //     ["total_paid"];
                              return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 5),
                                  child: Column(
                                    children: [
                                      index2 == 0
                                          ? Text(
                                              "Total de Gasto: \$${montoTotal.round()}",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold))
                                          : const SizedBox(),
                                      const SizedBox(height: 20),
                                      Row(children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user["username"],
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              user["email"],
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "Debe",
                                              style: TextStyle(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              user["total_spent"].toString(),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "Pagado",
                                              style: TextStyle(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              user["total_paid"].toString(),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ]),
                                      const SizedBox(width: 20),
                                      index2 ==
                                              widget
                                                      .arrayExpenses[indexList]
                                                          ["participants"]
                                                      .length -
                                                  1
                                          ? EditarGastoContainer(
                                              profileProvider:
                                                  widget.profileProvider,
                                              groupId: widget.groupId,
                                              groupName: widget.groupName,
                                              expenseId: widget
                                                      .arrayExpenses[indexList]
                                                  ["id"],
                                            )
                                          : const SizedBox()
                                    ],
                                  ));
                            } //         ListTile(

                            )),
                  ],
                )),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
}

class EditarGastoContainer extends StatelessWidget {
  const EditarGastoContainer({
    super.key,
    required this.profileProvider,
    required this.groupId,
    required this.expenseId,
    required this.groupName,
  });

  final ProfileProvider profileProvider;
  final int groupId;
  final int expenseId;
  final String groupName;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Material(
            elevation: 50,
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, "expense_screen", arguments: [
                  profileProvider,
                  groupId,
                  groupName,
                  expenseId
                ]);
              },
              child: Container(
                  height: 50,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: const Text(
                      "Editar Este Gasto",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  )),
            )));
  }
}
