import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:splitwise/helpers/form_helper.dart';
import 'package:splitwise/models/models.dart';
import 'package:splitwise/providers/providers.dart';
import 'package:splitwise/services/backend_response.dart';
import 'package:splitwise/services/backend_service.dart';
import 'package:splitwise/themes/app_theme.dart';
import 'package:splitwise/widgets/background/background.dart';
import 'package:splitwise/widgets/login_field.dart';
import 'package:splitwise/widgets/widgets.dart';

import '../services/firebase_service.dart';

Map<String, bool> createExpenseIntegrantsMap(
    List<Map<String, String>> integrants) {
  Map<String, bool> integrantsMap = {};
  for (var integrant in integrants) {
    integrantsMap[integrant["user_id"]!] = false;
  }
  return integrantsMap;
}

class PostExpenseScreenWrapper extends StatelessWidget {
  const PostExpenseScreenWrapper({Key? key});

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as List<Object?>;

    final ProfileProvider profileProvider = arguments[0] as ProfileProvider;
    final groupId = arguments[1] as int;
    final groupName = arguments[2] as String;

    final expenseId = arguments.length == 3 ? null : arguments[3] as int?;
    return PostExpenseScreen(
        groupId: groupId,
        profileProvider: profileProvider,
        groupName: groupName,
        expenseId: expenseId);
  }
}

class PostExpenseScreen extends StatefulWidget {
  const PostExpenseScreen(
      {Key? key,
      required this.groupId,
      required this.profileProvider,
      required this.groupName,
      this.expenseId})
      : super(key: key);
  final int groupId;
  final int? expenseId;
  final String groupName;
  final ProfileProvider profileProvider;
  @override
  _PostExpenseScreenState createState() => _PostExpenseScreenState();
}

class _PostExpenseScreenState extends State<PostExpenseScreen> {
  final FormHelper formHelper = FormHelper();
  List<Map<String, dynamic>> integrants = [];
  List<String> categories = [];
  List<String> currencies = [];
  bool isLoading = true;
  bool is_error = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final BackendService backendService =
        Provider.of<BackendService>(context, listen: false);
    BackendResponse categoriesResponse = await backendService.getCategories();
    BackendResponse currenciesResponse = await backendService.getCurrency();
    BackendResponse integrantsResponse =
        await backendService.getGroupIntegrants(widget.groupId);

    if (categoriesResponse.statusCode == 200 &&
        currenciesResponse.statusCode == 200 &&
        integrantsResponse.statusCode == 200) {
      setState(() {
        categories = categoriesResponse.body;
        currencies = currenciesResponse.body;
        integrants = integrantsResponse.body;
        isLoading = false;
      });
    } else {
      is_error = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
        title: Text(widget.expenseId != null ? "Editar Gasto" : 'Agregar Gasto',
            style: const TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          const BackgroundExpense(),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : is_error
                  ? const ContainerDeError(
                      error: "Hubo un Error cargando los grupos",
                      resolucion:
                          "Trata de recargar la pagina, sino intenta mas tarde",
                      error_message: "Hubo un error inesperado")
                  : ColumnBody(
                      expenseId: widget.expenseId,
                      profileProvider: widget.profileProvider,
                      categories: categories,
                      currencies: currencies,
                      integrants: integrants,
                      formHelper: formHelper,
                      size: size,
                      groupName: widget.groupName,
                      groupId: widget.groupId,
                    ),
        ],
      ),
    );
  }
}

class ColumnBody extends StatelessWidget {
  const ColumnBody({
    super.key,
    required this.profileProvider,
    required this.categories,
    required this.currencies,
    required this.integrants,
    required this.formHelper,
    required this.size,
    required this.groupId,
    required this.groupName,
    this.expenseId,
  });

  final int groupId;
  final ProfileProvider profileProvider;
  final List<String> categories;
  final List<String> currencies;
  final String groupName;
  final List<Map<String, dynamic>> integrants;
  final FormHelper formHelper;
  final Size size;
  final int? expenseId;
  @override
  Widget build(BuildContext context) {
    final ExpenseProvider expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: true);
    return WrapperColumnBody(
        profileProvider: profileProvider,
        expenseProvider: expenseProvider,
        categories: categories,
        currencies: currencies,
        integrants: integrants,
        formHelper: formHelper,
        expenseId: expenseId,
        groupId: groupId,
        groupName: groupName,
        size: size);
  }
}

class WrapperColumnBody extends StatefulWidget {
  const WrapperColumnBody(
      {super.key,
      required this.profileProvider,
      required this.expenseProvider,
      required this.categories,
      required this.integrants,
      required this.formHelper,
      required this.size,
      required this.currencies,
      required this.groupName,
      required this.groupId,
      this.expenseId});
  final ProfileProvider profileProvider;
  final ExpenseProvider expenseProvider;
  final List<String> categories;
  final List<String> currencies;
  final List<Map<String, dynamic>> integrants;
  final FormHelper formHelper;
  final String groupName;
  final Size size;
  final int groupId;
  final int? expenseId;

  @override
  State<WrapperColumnBody> createState() => _WrapperColumnBodyState();
}

class _WrapperColumnBodyState extends State<WrapperColumnBody> {
  @override
  void initState() {
    super.initState();
    widget.expenseProvider.addIntegrants(widget.integrants);
  }

  enviarNotificacion(bool editar, String nombreGrupo, String nombreGasto,
      double budgetPercentage, String token) async {
    final FirebaseApi firebaseApi = FirebaseApi();
    String message = editar
        ? "Se ha editado un gasto $nombreGasto en el grupo $nombreGrupo"
        : "Se ha añadido un nuevo gasto: $nombreGasto al grupo $nombreGrupo";
    if (budgetPercentage > 85) {
      budgetPercentage = (budgetPercentage).roundToDouble();
      message += " y el presupuesto del grupo esta al $budgetPercentage%";
    }
    print("message is $message");
    firebaseApi.sendNotification(
        title: editar ? "Edicion de Gasto" : "Nuevo Gasto",
        body: message,
        token: token);
  }

  @override
  Widget build(BuildContext context) {
    final BackendService backendService =
        Provider.of<BackendService>(context, listen: false);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: widget.expenseProvider.formLoginKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: ContainerForName(expenseProvider: widget.expenseProvider),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: ContainerForCategory(
                  expenseProvider: widget.expenseProvider,
                  currencies: widget.currencies,
                  categories: widget.categories),
            ),
            const SizedBox(height: 15),
            IntegrantsExpenses(
              profileProvider: widget.profileProvider,
              integrants: widget.expenseProvider.integrants,
              formHelper: widget.formHelper,
              size: widget.size,
              expenseProvider: widget.expenseProvider,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                elevation: 8,
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    print(
                        "the form values are ${widget.expenseProvider.formValues}");
                    if (widget.expenseProvider.isLoading == true) return;
                    if (!widget.expenseProvider.isValidExpense()) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Por favor llena todos los campos'),
                      ));
                      return;
                    }
                    if (!widget.expenseProvider.isValidTypePaidSpent()) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Por favor llena correctamente los campos de Debe y Pagado y Monto total '),
                      ));
                      return;
                    }
                    if (!widget.expenseProvider.isValidPaid()) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'El total valor pagado debe ser igual al monto total'),
                      ));
                      return;
                    }
                    widget.expenseProvider.setLoading(true);
                    final BackendResponse response = widget.expenseId != null
                        ? await backendService.editExpense(
                            widget.expenseProvider.formValues,
                            widget.expenseProvider.integrants,
                            widget.expenseId!,
                            widget.groupId)
                        : await backendService.createExpense(
                            widget.expenseProvider.formValues,
                            widget.expenseProvider.integrants,
                            widget.groupId);
                    widget.expenseProvider.setLoading(false);
                    if (response.statusCode == 201) {
                      final responseToken =
                          await backendService.getGroupToken(widget.groupId);
                      if (responseToken.statusCode == 200) {
                        final tokens = responseToken.body;
                        final budgetExceed = await backendService
                            .getGroupBudgetLeftPercentage(widget.groupId);

                        for (var token in tokens) {
                          enviarNotificacion(
                              widget.expenseId != null,
                              widget.groupName,
                              widget.expenseProvider.formValues["description"],
                              budgetExceed.body,
                              token);
                        }
                      }

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(widget.expenseId != null
                            ? "Gasto Editado"
                            : "Gasto Agregado"),
                      ));
                      Navigator.pop(context);
                    } else {
                      final errorMessage = response.errorMessage;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(errorMessage),
                      ));
                    }
                  },
                  child: Container(
                    height: 45,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 54, 117, 169),
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                    child: Center(
                        child: widget.expenseProvider.isLoading == true
                            ? const SpinKitWave(
                                color: Colors.white,
                                size: 20,
                              )
                            : Text(
                                widget.expenseId != null
                                    ? "Edita el Gasto"
                                    : "Agrega un Gasto",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16))),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContainerForName extends StatelessWidget {
  const ContainerForName({
    super.key,
    required this.expenseProvider,
  });
  final ExpenseProvider expenseProvider;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final FormHelper formHelper = FormHelper();
    return Material(
        elevation: 8,
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.only(left: 10, right: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          height: size.height * 0.1,
          width: size.width * 0.9,
          child: LoginFormField(
              validator: formHelper.isValidName,
              width: size.width * 0.9,
              isPassword: false,
              text: "Nombre del Gasto",
              formValues: expenseProvider.formValues,
              keyboardType: TextInputType.text,
              formProperty: "description"),
        ));
  }
}

class IntegrantsExpenses extends StatefulWidget {
  const IntegrantsExpenses({
    super.key,
    required this.integrants,
    required this.formHelper,
    required this.size,
    required this.expenseProvider,
    required this.profileProvider,
  });
  final ProfileProvider profileProvider;
  final ExpenseProvider expenseProvider;
  final List<Map<String, dynamic>> integrants;
  final FormHelper formHelper;
  final Size size;

  @override
  State<IntegrantsExpenses> createState() => _IntegrantsExpensesState();
}

class _IntegrantsExpensesState extends State<IntegrantsExpenses> {
  bool _isExpanded = false;
  bool checkAll = false;
  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Material(
            elevation: 8,
            color: Colors.transparent,
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ExpansionPanelList(
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    children: [
                      ExpansionPanel(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                'Agregar Integrantes',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 0, 0, 0)),
                              ));
                        },
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        isExpanded: _isExpanded,
                        body: Column(
                          children: [
                            ListTile(
                                title: const Text(
                                  'Agregar a Todos',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 0, 0, 0)),
                                ),
                                trailing: Checkbox(
                                  value: checkAll,
                                  onChanged: (value) {
                                    setState(() {
                                      checkAll = value!;
                                      widget.expenseProvider.setAllCheck(value);
                                    });
                                  },
                                )),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  widget.expenseProvider.integrants.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 5),
                                  child: ListTile(
                                    title: Text(
                                      widget.profileProvider.profile!.uid ==
                                              widget.expenseProvider
                                                  .integrants[index]["user_id"]
                                          ? "Tu"
                                          : widget.expenseProvider
                                              .integrants[index]["username"]!,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: Text(
                                      widget.profileProvider.profile!.uid ==
                                              widget.expenseProvider
                                                  .integrants[index]["user_id"]
                                          ? ""
                                          : widget.expenseProvider
                                              .integrants[index]["email"]!,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: Checkbox(
                                      value: widget.expenseProvider
                                          .integrants[index]["check"],
                                      onChanged: (value) {
                                        setState(() {
                                          widget.expenseProvider
                                              .setCheck(index, value!);
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            // AddIntegrantsForExpenses(widget: widget)
                          ],
                        ),
                      ),
                    ])),
          ),
        ),
        Material(
          elevation: 15,
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 218, 218, 218),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ExpensesWithIntegrants(
              size: size,
              profileProvider: widget.profileProvider,
              expenseProvider: widget.expenseProvider,
              integrants: widget.integrants,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class ExpensesWithIntegrants extends StatefulWidget {
  const ExpensesWithIntegrants({
    super.key,
    required this.size,
    required this.profileProvider,
    required this.expenseProvider,
    required this.integrants,
  });

  final ExpenseProvider expenseProvider;
  final ProfileProvider profileProvider;
  final List<Map<String, dynamic>> integrants;
  final Size size;

  @override
  State<ExpensesWithIntegrants> createState() => _ExpensesWithIntegrantsState();
}

class _ExpensesWithIntegrantsState extends State<ExpensesWithIntegrants> {
  @override
  Widget build(BuildContext context) {
    final getOneTrueIntegrant = widget.expenseProvider.integrants
        .where((integrant) => integrant["check"] == true)
        .toList();
    final formHelper = FormHelper();
    return getOneTrueIntegrant.length == 0
        ? Container()
        : Column(
            children: [
              SizedBox(height: widget.size.height * 0.02),
              Row(
                children: [
                  const Spacer(),
                  Material(
                    elevation: 8,
                    color: Colors.transparent,
                    child: Container(
                      width: 150,
                      height: 55,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CheckboxListTile(
                        title: const Text(
                          'Dividir Gasto',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        value: widget.expenseProvider.isEquallyDivided,
                        onChanged: (value) {
                          setState(() {
                            widget.expenseProvider.setEquallyDivided(value!);
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: widget.size.width * 0.05),
                ],
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: widget.expenseProvider.integrants.length,
                itemBuilder: (context, index) {
                  return widget.expenseProvider.integrants[index]["check"] ==
                          true
                      ? Row(
                          children: [
                            SizedBox(
                              width: widget.size.width * 0.27,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.profileProvider.profile!.uid ==
                                            widget.integrants[index]["user_id"]
                                        ? "Tu"
                                        : widget.integrants[index]["username"]!,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                      widget.profileProvider.profile!.uid ==
                                              widget.integrants[index]
                                                  ["user_id"]
                                          ? ""
                                          : widget.integrants[index]["email"]!,
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.4),
                                        fontSize: 12,
                                      )),
                                ],
                              ),
                            ),
                            SizedBox(width: widget.size.width * 0.2),
                            LoginFormField(
                                validator: formHelper.isValidExpense,
                                width: widget.size.width * 0.15,
                                isPassword: false,
                                text: "Pagado",
                                formValues:
                                    widget.expenseProvider.integrants[index],
                                keyboardType: TextInputType.number,
                                formProperty: "paid"),
                            SizedBox(width: widget.size.width * 0.05),
                            widget.expenseProvider.isEquallyDivided == true
                                ? Column(
                                    children: [
                                      const Text(
                                        "Debe",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        widget.expenseProvider
                                            .integrants[index]["spent"]
                                            .toString(),
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.4),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  )
                                : LoginFormField(
                                    validator: formHelper.isValidExpense,
                                    width: widget.size.width * 0.15,
                                    isPassword: false,
                                    text: "Debe",
                                    formValues: widget
                                        .expenseProvider.integrants[index],
                                    keyboardType: TextInputType.number,
                                    formProperty: "spent"),
                          ],
                        )
                      : Container();
                },
              ),
            ],
          );
  }
}

class AddIntegrantsForExpenses extends StatelessWidget {
  const AddIntegrantsForExpenses({
    super.key,
    required this.widget,
  });

  final IntegrantsExpenses widget;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        widget.expenseProvider.submit();
      },
      child: const Text('Agregar',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }
}

class ContainerForCategory extends StatefulWidget {
  const ContainerForCategory({
    super.key,
    required this.expenseProvider,
    required this.categories,
    required this.currencies,
  });

  final ExpenseProvider expenseProvider;
  final List<String> categories;
  final List<String> currencies;

  @override
  State<ContainerForCategory> createState() => _ContainerForCategoryState();
}

class _ContainerForCategoryState extends State<ContainerForCategory> {
  final FormHelper formHelper = FormHelper();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Material(
      elevation: 8,
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        height: size.height * 0.1,
        width: size.width * 0.9,
        child: Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: SizedBox(
                width: size.width * 0.4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Categoria",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                    DropdownButton<String>(
                      borderRadius: BorderRadius.circular(10),
                      dropdownColor: const Color.fromARGB(255, 255, 255, 255),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      iconEnabledColor: const Color.fromARGB(255, 0, 0, 0),
                      iconDisabledColor:
                          const Color.fromARGB(255, 103, 123, 235),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          widget.expenseProvider.formValues["category"] =
                              newValue;
                        });
                      },
                      hint: Text(
                        "Categoria",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.3),
                          letterSpacing: 0,
                        ),
                      ),
                      menuMaxHeight: 300,
                      elevation: 8,
                      value: widget.expenseProvider.formValues["category"],
                      items: widget.categories.map((String trainingType) {
                        return DropdownMenuItem<String>(
                          value: trainingType,
                          child: Text(
                            trainingType,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              letterSpacing: 0,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: size.width * 0.05),
            Flexible(
              fit: FlexFit.loose,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "Moneda",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  DropdownButton<String>(
                    borderRadius: BorderRadius.circular(10),
                    dropdownColor: const Color.fromARGB(255, 255, 255, 255),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    iconEnabledColor: const Color.fromARGB(255, 0, 0, 0),
                    iconDisabledColor: const Color.fromARGB(255, 103, 123, 235),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        widget.expenseProvider.formValues["currency"] =
                            newValue;
                      });
                    },
                    hint: Text(
                      "Moneda",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.3),
                        letterSpacing: 0,
                      ),
                    ),
                    menuMaxHeight: 300,
                    elevation: 8,
                    value: widget.expenseProvider.formValues["currency"],
                    items: widget.currencies.map((String trainingType) {
                      return DropdownMenuItem<String>(
                        value: trainingType,
                        child: Text(
                          trainingType,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            letterSpacing: 0,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(width: size.width * 0.15),
            Flexible(
              fit: FlexFit.loose,
              child: LoginFormField(
                  validator: formHelper.isValidExpense,
                  width: size.width * 0.4,
                  isPassword: false,
                  text: "Monto",
                  formValues: widget.expenseProvider.formValues,
                  keyboardType: TextInputType.number,
                  formProperty: "total_spent"),
            ),
          ],
        ),
      ),
    );
  }
}
