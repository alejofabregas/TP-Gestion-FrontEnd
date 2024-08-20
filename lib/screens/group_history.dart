import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:splitwise/services/backend_response.dart';
import 'package:splitwise/services/backend_service.dart';
import 'package:splitwise/widgets/widgets.dart';

import '../providers/providers.dart';

class GroupHistoryScreen extends StatefulWidget {
  GroupHistoryScreen({Key? key}) : super(key: key);

  @override
  State<GroupHistoryScreen> createState() => _GroupHistoryScreenState();
}

class _GroupHistoryScreenState extends State<GroupHistoryScreen> {
  int _currentPage = 0;

  final List<String> searchTypes = ["Pagos", "Gastos"];

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as List<Object?>;
    final ProfileProvider profileProvider = arguments[0] as ProfileProvider;
    final GroupProvider groupProvider =
        Provider.of<GroupProvider>(context, listen: true);
    final BackendService backendService =
        Provider.of<BackendService>(context, listen: false);
    final int groupId = arguments[1] as int;
    final String groupName = arguments[2] as String;
    return Scaffold(
        appBar: AppBar(
          title: Text("Historial del Grupo",
              style: const TextStyle(
                  fontSize: 20, fontFamily: "Calibri", color: Colors.white)),
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
        ),
        body: Stack(
          children: [
            BackgroundExpense(),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
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
                  PagesForHistory(
                    backendService: backendService,
                    groupId: groupId,
                    groupName: groupName,
                    groupProvider: groupProvider,
                    currentPage: _currentPage,
                    profileProvider: profileProvider,
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

class PagesForHistory extends StatelessWidget {
  const PagesForHistory({
    super.key,
    required this.backendService,
    required this.groupId,
    required this.groupProvider,
    required this.profileProvider,
    required this.currentPage,
    required this.groupName,
  });
  final int groupId;
  final BackendService backendService;
  final GroupProvider groupProvider;
  final ProfileProvider profileProvider;
  final int currentPage;
  final String groupName;
  @override
  Widget build(BuildContext context) {
    final selectedCategories = groupProvider.categories.keys.where((category) {
      return groupProvider.categories[category] == true;
    }).toList();
    return Column(
      children: [
        currentPage == 1
            ? ExpandableFilter(
                groupProvider: groupProvider,
                profileProvider: profileProvider,
                backendService: backendService,
              )
            : Container(),
        const SizedBox(height: 10),
        FutureBuilder(
            future: currentPage == 0
                ? backendService.getGroupHistory(groupId)
                : backendService.getGroupCategoriesHistory(
                    selectedCategories, groupId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SpinKitWave(
                    color: Colors.indigo.withOpacity(0.5),
                    size: 50,
                  ),
                );
              }
              if (snapshot.data!.statusCode == 400) {
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      Icon(
                        Icons.search,
                        size: 100,
                        color: const Color.fromARGB(255, 15, 15, 15)
                            .withOpacity(0.4),
                      ),
                      Text(
                          currentPage == 0
                              ? "No se encontraron Pagos"
                              : 'No se encontraron resultados para esa Categoria',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 3, 3, 3)
                                  .withOpacity(0.4)))
                    ]));
              }

              if (snapshot.data == null || snapshot.data!.statusCode != 200) {
                return ContainerDeError(
                  error: currentPage == 0
                      ? "Hubo un Error cargando los Pagos"
                      : "Hubo un Error cargando los gastos",
                  resolucion:
                      "Trata de recargar la pagina, sino intenta mas tarde",
                  error_message: snapshot.data!.errorMessage,
                );
              }

              final ExpenseProvider expenseProvider =
                  Provider.of<ExpenseProvider>(context, listen: false);
              return currentPage == 0
                  ? PagosBody(
                      snapshot,
                      expenseProvider,
                    )
                  : GastosBody(snapshot, expenseProvider, groupId,
                      profileProvider, groupName);
            }),
      ],
    );
  }

  Padding PagosBody(AsyncSnapshot<BackendResponse<dynamic>> snapshot,
      ExpenseProvider expenseProvider) {
    final groupHistory = snapshot.data!.body;
    var payments = groupHistory['payments'] as List<Map<String, dynamic>>;
    expenseProvider.initIsExpanded(payments.length);
    return Padding(
      padding: const EdgeInsets.all(10),
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
          child: HistoryList(
            historyArray: payments,
            expenseProvider: expenseProvider,
          ),
        ),
      ),
    );
  }

  Padding GastosBody(
      AsyncSnapshot<BackendResponse<dynamic>> snapshot,
      ExpenseProvider expenseProvider,
      int groupId,
      ProfileProvider profileProvider,
      String groupName) {
    final groupHistory = snapshot.data!.body;
    var expenses =
        groupHistory['arrayIndividualExpenses'] as List<Map<String, dynamic>>;

    expenses.sort((a, b) => a['id'].compareTo(b['id']));

    expenseProvider.initIsExpanded(expenses.length);
    return Padding(
      padding: const EdgeInsets.all(10),
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
          child: ExpenseHistoryList(
            groupName: groupName,
            arrayExpenses: expenses,
            expenseProvider: expenseProvider,
            groupId: groupId,
            profileProvider: profileProvider,
          ),
        ),
      ),
    );
  }
}

class ExpandableFilter extends StatefulWidget {
  final GroupProvider groupProvider;
  final ProfileProvider profileProvider;
  final BackendService backendService;

  const ExpandableFilter({
    required this.groupProvider,
    required this.profileProvider,
    required this.backendService,
  });

  @override
  _ExpandableFilterState createState() => _ExpandableFilterState();
}

class _ExpandableFilterState extends State<ExpandableFilter> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Material(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.transparent,
              child: ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  children: [
                    ExpansionPanel(
                      isExpanded: _isExpanded,
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Filtrar por Categorias',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        );
                      },
                      body: Column(
                        children: [
                          Column(
                            children: widget.groupProvider.categories.keys
                                .map((category) {
                              return CheckboxListTile(
                                title: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                value:
                                    widget.groupProvider.categories[category],
                                onChanged: (value) {
                                  setState(() {
                                    widget.groupProvider.categories[category] =
                                        value!;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                widget.groupProvider.setCategory();
                              });
                            },
                            child: RoundedContainer(
                              text: 'Filtrar',
                              height: 75,
                              width: 200,
                              fontsize: 20,
                              color: Colors.indigo[300]!,
                              circularProgressIndicator: null,
                              bold: true,
                            ),
                          ),
                        ],
                      ),
                    )
                  ]))),
    );
  }
}
