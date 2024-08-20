import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:splitwise/helpers/form_helper.dart';
import 'package:splitwise/providers/expense_provider.dart';
import 'package:splitwise/providers/group_provider.dart';
import 'package:splitwise/providers/profile_provider.dart';
import 'package:splitwise/services/backend_response.dart';
import 'package:splitwise/services/backend_service.dart';
import 'package:splitwise/themes/app_theme.dart';
import 'package:splitwise/widgets/widgets.dart';

Future<List<BackendResponse>> fetchGroupData(BackendService backendService,
    ProfileProvider profileProvider, int groupId) async {
  final groupIntegrants = await backendService.getGroupIntegrants(groupId);
  final groupExpenses = await backendService.getGroupBalanceExpenses(groupId);
  final individualExpenses =
      await backendService.getIndividualExpenses(groupId);
  final groupDebts = await backendService.getGroupIndividualDebts(
      groupId, profileProvider.profile!.uid);
  return [groupIntegrants, groupExpenses, individualExpenses, groupDebts];
}

class DisplayGroup extends StatefulWidget {
  const DisplayGroup({
    Key? key,
  }) : super(key: key);

  @override
  State<DisplayGroup> createState() => _DisplayGroupState();
}

class _DisplayGroupState extends State<DisplayGroup> {
  final RefreshController refreshController = RefreshController();

  Future<void> _redraw() async {
    setState(() {});
    refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as List<Object?>;
    ProfileProvider profileProvider = arguments[0] as ProfileProvider;
    Map<String, dynamic> groupData = arguments[1] as Map<String, dynamic>;
    final FormHelper formHelper = FormHelper();
    final GroupProvider groupProvider =
        Provider.of<GroupProvider>(context, listen: true);
    final BackendService backendService =
        Provider.of<BackendService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color.fromARGB(255, 9, 107, 187),
        title: Text(groupData["name"]!,
            style: const TextStyle(
                fontSize: 20, fontFamily: "Calibri", color: Colors.white)),
        actions: [
          groupData["admin_id"] == profileProvider.profile!.uid
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    onPressed: () {
                      showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (context) {
                            return CreateNewGroup(
                                profileProvider: profileProvider,
                                groupProvider: groupProvider,
                                values: groupData,
                                formHelper: formHelper);
                          });
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                )
              : Container(),
        ],
      ),
      body: Stack(
        children: [
          const BackgroundExpense(),
          SmartRefresher(
            controller: refreshController,
            onRefresh: _redraw,
            header: const WaterDropHeader(
              complete: Icon(
                Icons.check,
                color: Colors.blue,
              ),
              waterDropColor: Colors.blue,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InfoContainer(groupData: groupData),
                  FunctionalityContainer(
                      groupData: groupData,
                      profileProvider: profileProvider,
                      backendService: backendService),
                  PresupuestoContainer(
                      groupData: groupData,
                      profileProvider: profileProvider,
                      backendService: backendService),
                  DisplayListContainer(
                      backendService: backendService,
                      groupData: groupData,
                      profileProvider: profileProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DisplayListContainer extends StatelessWidget {
  const DisplayListContainer({
    super.key,
    required this.backendService,
    required this.groupData,
    required this.profileProvider,
  });

  final BackendService backendService;
  final Map<String, dynamic> groupData;
  final ProfileProvider profileProvider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Material(
          elevation: 50,
          color: Colors.transparent,
          child: Container(
            height: 600,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey,
                width: 1,
              ),
            ),
            child: DisplayGroupData(
                backendService: backendService,
                groupData: groupData,
                profileProvider: profileProvider),
          ),
        ),
      ),
    );
  }
}

class FunctionalityContainer extends StatelessWidget {
  const FunctionalityContainer({
    super.key,
    required this.groupData,
    required this.profileProvider,
    required this.backendService,
  });

  final Map<String, dynamic> groupData;
  final ProfileProvider profileProvider;
  final BackendService backendService;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Material(
        elevation: 50,
        color: Colors.transparent,
        child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.grey,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      (groupData["admin_id"] == profileProvider.profile!.uid)
                          ? Expanded(
                              child: AddAUser(
                                  profileProvider: profileProvider,
                                  groupData: groupData),
                            )
                          : Container(),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AbandonGroup(
                            backendService: backendService,
                            groupData: groupData,
                            profileProvider: profileProvider),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, "group_history", arguments: [
                      profileProvider,
                      groupData["id"]!,
                      groupData["name"]!
                    ]);
                  },
                  child: const RoundedContainer(
                    color: Colors.white,
                    bold: false,
                    fontsize: 16,
                    width: 350,
                    text: "Historial",
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, "expense_screen",
                            arguments: [
                              profileProvider,
                              groupData["id"]!,
                              groupData["name"]!
                            ]);
                      },
                      child: const RoundedContainer(
                        bold: false,
                        fontsize: 14,
                        width: 175,
                        text: "Agrega un Pago",
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, "payment_screen",
                            arguments: [profileProvider, groupData["id"]!]);
                      },
                      child: const RoundedContainer(
                        bold: false,
                        fontsize: 14,
                        width: 175,
                        text: "Saldar tu Cuenta",
                      ),
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}

class PresupuestoContainer extends StatelessWidget {
  const PresupuestoContainer({
    super.key,
    required this.groupData,
    required this.profileProvider,
    required this.backendService,
  });

  final Map<String, dynamic> groupData;
  final ProfileProvider profileProvider;
  final BackendService backendService;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: backendService.getGroupBudget(groupData["id"]!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SpinKitWave(
              color: Colors.indigo.withOpacity(0.5),
              size: 50,
            ),
          );
        }
        if (snapshot.data == null || snapshot.data!.statusCode != 200) {
          return const Text("");
        }
        print("the data is ${snapshot.data!.body}");
        final totalBudget = snapshot.data!.body["group_budget"];
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Material(
            elevation: 50,
            color: Colors.transparent,
            child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Presupuesto",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  final GroupProvider groupProvider =
                                      Provider.of<GroupProvider>(context,
                                          listen: false);
                                  return AlertDialog(
                                    title: const Text(
                                        'Ingresa el nuevo Presupuesto'),
                                    content: Form(
                                      key: groupProvider.formLoginKey,
                                      child: LoginFormField(
                                          isPassword: false,
                                          text: "Presupuesto",
                                          formValues: groupProvider.formValues,
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Por favor ingresa un presupuesto';
                                            }
                                            if (double.tryParse(value) ==
                                                null) {
                                              return 'Ingresa un presupuesto valido';
                                            }
                                            if (double.parse(value) < 0) {
                                              return 'Ingresa un presupuesto mayor a 0';
                                            }
                                            final totalSpent = snapshot
                                                .data!.body["total_spent"];
                                            if (double.parse(value) <
                                                totalSpent) {
                                              return 'Nuevo presupuesto menor al total gastado';
                                            }
                                            return null;
                                          },
                                          formProperty: "budget"),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (groupProvider.isValidForm() &&
                                              !groupProvider.isLoading) {
                                            groupProvider.setLoading(true);
                                            backendService
                                                .editGroupBudget(
                                              double.parse(groupProvider
                                                  .formValues["budget"]!),
                                              groupData["id"]!,
                                              profileProvider.profile!.uid,
                                            )
                                                .then((response) {
                                              groupProvider.setLoading(false);
                                              if (response.statusCode == 200) {
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                        const SnackBar(
                                                  content: Text(
                                                      'Presupuesto Actualizado'),
                                                ));
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                        const SnackBar(
                                                  content: Text(
                                                      'Hubo un error al actualizar el presupuesto'),
                                                ));
                                              }
                                            });
                                          }
                                        },
                                        child: groupProvider.isLoading
                                            ? const CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              )
                                            : const Text('Aceptar'),
                                      ),
                                    ],
                                  );
                                });
                          },
                          child: const Icon(Icons.edit),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text("Presupuesto Total: ",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text("\$$totalBudget",
                            style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text("Total Gastado: ",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text("\$${snapshot.data!.body["total_spent"]}",
                            style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text("Disponible: ",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text("\$${snapshot.data!.body["dif_budget"]}",
                            style: const TextStyle(
                                fontSize: 15, color: AppTheme.positiveValue)),
                      ],
                    ),
                  ],
                )),
          ),
        );
      },
    );
  }
}

class InfoContainer extends StatelessWidget {
  const InfoContainer({
    super.key,
    required this.groupData,
  });

  final Map<String, dynamic> groupData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Material(
        elevation: 8,
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color.fromARGB(255, 93, 92, 92),
                width: 1,
              ),
              color: Colors.white),
          height: 100,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Text(
              groupData["description"]!,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}

class AddAUser extends StatelessWidget {
  const AddAUser({
    super.key,
    required this.profileProvider,
    required this.groupData,
  });

  final ProfileProvider profileProvider;
  final Map<String, dynamic> groupData;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, "add_integrant",
          arguments: [profileProvider, groupData["id"]!]),
      child: Material(
        color: Colors.transparent,
        elevation: 8,
        child: Container(
          height: 45,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 39, 99, 148),
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          child: const Center(
              child: Text("Agrega un Integrante",
                  style: TextStyle(color: Colors.white, fontSize: 16))),
        ),
      ),
    );
  }
}

class DisplayGroupData extends StatefulWidget {
  const DisplayGroupData({
    super.key,
    required this.backendService,
    required this.groupData,
    required this.profileProvider,
  });

  final BackendService backendService;
  final Map<String, dynamic> groupData;
  final ProfileProvider profileProvider;

  @override
  State<DisplayGroupData> createState() => _DisplayGroupDataState();
}

class _DisplayGroupDataState extends State<DisplayGroupData> {
  int _currentPage = 0;
  final List<String> searchTypes = ["Integrantes", "Gastos"];

  Widget body(
      List<Map<String, dynamic>> members,
      Map<int, List<Map<String, dynamic>>> expenseMap,
      ExpenseProvider expenseProvider,
      List<Map<String, dynamic>> groupIntegrants,
      Map<String, dynamic> groupDebts) {
    final ExpenseProvider expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    expenseProvider.initIsExpanded(members.length);
    return Expanded(
        child: _currentPage == 0
            ? GroupIntegrantsList(
                integrants: groupIntegrants,
                groupData: widget.groupData,
                profileProvider: widget.profileProvider,
              )
            : BalanceIntegrantsList(
                members: members,
                groupDebts: groupDebts,
                profileProvider: widget.profileProvider,
                groupData: widget.groupData,
                expenseProvider: expenseProvider,
              ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            2,
            (index) => GestureDetector(
              onTap: () {
                setState(() {
                  _currentPage = index;
                });
              },
              child: ContainerForSearchTypes(
                currentPage: _currentPage,
                searchTypes: searchTypes,
                index: index,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        FutureBuilder(
          future: fetchGroupData(
            widget.backendService,
            widget.profileProvider,
            widget.groupData["id"]!,
          ),
          builder: (context, snapshot) {
            // BackendResponse? groupIntegrants;
            // BackendResponse? groupExpenses;
            // BackendResponse? groupHistory;
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(
                child: SpinKitWave(
                  color: Colors.indigo.withOpacity(0.5),
                  size: 50,
                ),
              );
            if (snapshot.data == null ||
                snapshot.data![0].statusCode != 200 ||
                snapshot.data![1].statusCode != 200 ||
                snapshot.data![2].statusCode != 200 ||
                snapshot.data![3].statusCode != 200) {
              return ContainerDeError(
                error: "Hubo un Error cargando los grupos",
                resolucion:
                    "Trata de recargar la pagina, sino intenta mas tarde",
                error_message: snapshot.data![0].errorMessage,
              );
            }
            if (snapshot.data![0].body.isEmpty) {
              return const ContainerDeError(
                error: "No Hay Integrantes",
                resolucion:
                    "Agrega integrantes para empezar a compartir gastos",
              );
            }
            final groupIntegrants =
                snapshot.data![0].body as List<Map<String, dynamic>>;

            final groupExpensesMap =
                snapshot.data![1].body as Map<String, dynamic>;
            final groupHistory =
                snapshot.data![2].body as List<Map<String, dynamic>>;
            final groupDebts = snapshot.data![3].body as Map<String, double>;
            final members =
                groupExpensesMap["members"] as List<Map<String, dynamic>>;
            final expenseMap = Map<int, List<Map<String, dynamic>>>();
            for (final expense in groupHistory) {
              final expenseId = expense["expense_id"] as int;
              if (!expenseMap.containsKey(expenseId)) {
                expenseMap[expenseId] = [];
              }
              expenseMap[expenseId]!.add(expense);
            }

            final ExpenseProvider expenseProvider =
                Provider.of<ExpenseProvider>(context, listen: false);

            expenseProvider.initIsExpanded(expenseMap.keys.length);
            return body(members, expenseMap, expenseProvider, groupIntegrants,
                groupDebts);
          },
        ),
      ],
    );
  }
}

class ExpensePaid extends StatelessWidget {
  const ExpensePaid(
      {super.key,
      required this.profileProvider,
      required this.groupData,
      required this.integrant});
  final Map<String, dynamic> integrant;
  final Map<String, dynamic> groupData;
  final ProfileProvider profileProvider;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Saldar Cuenta'),
      content: Text(
          '¿Estas seguro de saldar la cuenta con ${integrant["username"]} con valor con ${integrant["balance"]} ?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class BalanceIntegrantsList extends StatefulWidget {
  const BalanceIntegrantsList({
    super.key,
    required this.members,
    required this.groupDebts,
    required this.profileProvider,
    required this.groupData,
    required this.expenseProvider,
  });

  final List<Map<String, dynamic>> members;
  final Map<String, dynamic> groupDebts;
  final ProfileProvider profileProvider;
  final Map<String, dynamic> groupData;
  final ExpenseProvider expenseProvider;
  @override
  State<BalanceIntegrantsList> createState() => _BalanceIntegrantsListState();
}

class _BalanceIntegrantsListState extends State<BalanceIntegrantsList> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (_, i) => const Divider(
        thickness: 1,
        color: Colors.black,
      ),
      // physics: const BouncingScrollPhysics(),
      itemCount: widget.members.length,
      itemBuilder: (context, indexList) {
        bool debes = false;
        if (widget.members[indexList]["id"] !=
            widget.profileProvider.profile!.uid) {
          debes = widget.groupDebts[widget.members[indexList]["id"]] > 0;
        }
        return ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                widget.expenseProvider.isExpanded[indexList] =
                    !widget.expenseProvider.isExpanded[indexList];
              });
            },
            children: [
              ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: widget.members[indexList]["id"] ==
                              widget.profileProvider.profile!.uid
                          ? const Text(
                              "Tu",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.members[indexList]["username"],
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  widget.members[indexList]["email"],
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withOpacity(0.5)),
                                ),
                              ],
                            ));
                },
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                isExpanded: widget.expenseProvider.isExpanded[indexList],
                body: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Balance total en el grupo",
                                    style: TextStyle(fontSize: 14)),
                                widget.members[indexList]["id"] ==
                                        widget.profileProvider.profile!.uid
                                    ? Text(
                                        widget.members[indexList]["balance"]
                                            .toStringAsFixed(2),
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: widget.members[indexList]
                                                        ["balance"] <
                                                    0
                                                ? AppTheme.negativeValue
                                                : widget.members[indexList]
                                                            ["balance"] ==
                                                        0
                                                    ? Colors.black
                                                    : AppTheme.positiveValue),
                                      )
                                    : Text(
                                        widget.members[indexList]["balance"]
                                            .toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: widget.members[indexList]
                                                          ["id"] ==
                                                      widget.profileProvider
                                                          .profile!.uid &&
                                                  widget.members[indexList]
                                                          ["balance"] >
                                                      0
                                              ? AppTheme.positiveValue
                                              : widget.members[indexList]
                                                          ["balance"] <
                                                      0
                                                  ? AppTheme.negativeValue
                                                  : widget.members[indexList]
                                                              ["balance"] ==
                                                          0
                                                      ? Colors.black
                                                      : AppTheme.positiveValue,
                                        ),
                                      )
                              ])),
                      widget.members[indexList]["id"] !=
                              widget.profileProvider.profile!.uid
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(debes ? "Te debe " : "Le debes",
                                      style: const TextStyle(
                                          fontSize: 15, fontFamily: "Calibri")),
                                  Text(
                                    (widget.groupDebts[widget.members[indexList]
                                            ["id"]]!)
                                        .abs()
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: widget.groupDebts[widget
                                                  .members[indexList]["id"]]! <
                                              0
                                          ? const Color.fromARGB(
                                              255, 148, 42, 34)
                                          : widget.groupDebts[
                                                      widget.members[indexList]
                                                          ["id"]]! ==
                                                  0
                                              ? Colors.black
                                              : const Color.fromARGB(
                                                  255, 34, 138, 18),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                    ]),
              )
            ]);
      },
    );

    // return ListView.separated(
    //   separatorBuilder: (_, i) => const Divider(
    //     thickness: 1,
    //     color: Colors.black,
    //   ),
    //   physics: const BouncingScrollPhysics(),
    //   itemCount: widget.members.length,
    //   itemBuilder: (context, index) {
    //     return InkWell(
    //       onTap: () {
    //         if (widget.profileProvider.profile!.uid !=
    //                 widget.members[index]["id"] &&
    //             widget.members[index]["balance"] > 0) {
    //           showDialog(
    //               barrierDismissible: true,
    //               context: context,
    //               builder: (context) {
    //                 return ExpensePaid(
    //                   profileProvider: widget.profileProvider,
    //                   groupData: widget.groupData,
    //                   integrant: widget.members[index],
    //                 );
    //               });
    //         }
    //       },
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //         children: [
    //           SizedBox(
    //             width: 200,
    //             child: ListTile(
    //               title: widget.profileProvider.profile!.uid ==
    //                       widget.members[index]["id"]
    //                   ? const Text("Tu",aer
    //                       style: TextStyle(fontSize: 20, fontFamily: "Calibri"))
    //                   : Text(widget.members[index]["username"],
    //                       style: const TextStyle(
    //                           fontSize: 20, fontFamily: "Calibri")),
    //               subtitle: widget.profileProvider.profile!.uid ==
    //                       widget.members[index]["id"]
    //                   ? Container()
    //                   : Text(widget.members[index]["email"],
    //                       style: const TextStyle(
    //                           fontSize: 14, fontFamily: "Calibri")),
    //             ),
    //           ),
    //           const Spacer(),
    //           widget.members[index]["id"] == widget.profileProvider.profile!.uid
    //               ? const SizedBox(
    //                   width: 46,
    //                 )
    //               : Column(
    //                   children: [
    //                     const Text("Contigo", style: TextStyle(fontSize: 14)),
    //                   ],
    //                 ),
    //           const SizedBox(
    //             width: 20,
    //           ),
    //           Column(
    //             children: [
    //               const Text("Balance", style: TextStyle(fontSize: 14)),
    //               widget.members[index]["id"] ==
    //                       widget.profileProvider.profile!.uid
    //                   ? Text(
    //                       widget.members[index]["balance"].toString(),
    //                       style: TextStyle(
    //                         fontSize: 14,
    //                         color: widget.members[index]["balance"] < 0
    //                             ? Colors.red
    //                             : widget.members[index]["balance"] == 0
    //                                 ? Colors.black
    //                                 : const Color.fromARGB(255, 34, 255, 0),
    //                       ),
    //                     )
    //                   : Text(
    //                       widget.members[index]["balance"].toString(),
    //                       style: TextStyle(
    //                         fontSize: 14,
    //                         color: widget.members[index]["id"] ==
    //                                     widget.profileProvider.profile!.uid &&
    //                                 widget.members[index]["balance"] > 0
    //                             ? const Color.fromARGB(255, 34, 255, 0)
    //                             : widget.members[index]["balance"] < 0
    //                                 ? Colors.red
    //                                 : widget.members[index]["balance"] == 0
    //                                     ? Colors.black
    //                                     : const Color.fromARGB(255, 34, 255, 0),
    //                       ),
    //                     ),
    //             ],
    //           ),
    //         ],
    //       ),
    //     );
    //   },
    // );
  }
}

class GroupIntegrantsList extends StatelessWidget {
  const GroupIntegrantsList(
      {super.key,
      required this.integrants,
      required this.groupData,
      required this.profileProvider

      // required this.widget,
      });

  final Map<String, dynamic> groupData;
  final ProfileProvider profileProvider;
  final List<Map<String, dynamic>> integrants;
  // final DisplayGroupData widget;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (_, i) => const Divider(
        thickness: 1,
        color: Colors.black,
      ),
      // physics: const BouncingScrollPhysics(),
      itemCount: integrants.length,
      itemBuilder: (_, i) {
        final user = integrants[i]["user"];
        final pending = integrants[i]["pending"];

        return IntegrantsName(
          name: user['username'],
          email: user['email'],
          uid: user['id'],
          profileProvider: profileProvider,
          groupId: groupData["id"] as int,
          pending: pending,
          isAdmin: groupData["admin_id"] == profileProvider.profile!.uid,
          isUserAdmin: groupData["admin_id"] == user['id'],
        );
      },
    );
  }
}

class IntegrantsName extends StatelessWidget {
  const IntegrantsName({
    super.key,
    required this.name,
    required this.email,
    required this.uid,
    required this.profileProvider,
    required this.isAdmin,
    required this.groupId,
    required this.pending,
    required this.isUserAdmin,
  });
  final bool isUserAdmin;
  final String name;
  final bool isAdmin;
  final String email;
  final String uid;
  final int groupId;
  final ProfileProvider profileProvider;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final BackendService backendService =
        Provider.of<BackendService>(context, listen: false);
    return (profileProvider.profile!.uid != uid)
        ? (isAdmin && !pending)
            ? Slidable(
                startActionPane: ActionPane(
                  motion: const StretchMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                elevation: 20,
                                title: const Text(
                                    "Quiere nombrar al usuario como administrador"),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadiusDirectional.circular(15)),
                                content: const Text(
                                    "¿Estas seguro de nombrar a este usuario como un administrador del grupo?"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancelar',
                                          style: TextStyle(color: Colors.red))),
                                  TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        final response =
                                            await backendService.nameGroupAdmin(
                                                groupId,
                                                uid,
                                                profileProvider.profile!.uid);
                                        if (response.statusCode != 200) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text(
                                                'Hubo un error al nombrar al usuario como administrador'),
                                          ));
                                        }
                                      },
                                      child: const Text('Acept'))
                                ],
                              );
                            });
                      },
                      backgroundColor: const Color.fromARGB(255, 11, 145, 255),
                      foregroundColor: Colors.white,
                      icon: Icons.admin_panel_settings,
                      label: "Admin",
                    ),
                  ],
                ),
                endActionPane: ActionPane(
                  motion: const StretchMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                elevation: 20,
                                title: const Text("Eliminar usuario de Grupo"),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadiusDirectional.circular(15)),
                                content: const Text(
                                    "¿Estas seguro de eliminar este usuario del grupo?"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancelar',
                                          style: TextStyle(color: Colors.red))),
                                  TextButton(
                                      onPressed: () async {
                                        final response = await backendService
                                            .removeUserFromGroup(groupId, uid);
                                        Navigator.pop(context);
                                        if (response.statusCode != 200) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text(
                                                'Hubo un error al eliminar al usuario del grupo'),
                                          ));
                                        }
                                      },
                                      child: const Text('Acept'))
                                ],
                              );
                            });
                      },
                      backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: "Delete",
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(name,
                      style:
                          const TextStyle(fontSize: 20, fontFamily: "Calibri")),
                  subtitle: Text(email),
                ),
              )
            : ListTile(
                title: Text(name,
                    style:
                        const TextStyle(fontSize: 20, fontFamily: "Calibri")),
                subtitle: Text(email),
                trailing: pending == true
                    ? const Icon(Icons.pending_actions)
                    : (isUserAdmin == true)
                        ? const Icon(Icons.admin_panel_settings)
                        : null,
              )
        : ListTile(
            title: const Row(
              children: [
                Text("Tu",
                    style: TextStyle(fontSize: 20, fontFamily: "Calibri")),
                Icon(Icons.person),
              ],
            ),
            trailing: (isAdmin == true)
                ? const Icon(Icons.admin_panel_settings)
                : null,
          );
  }
}
