import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:splitwise/providers/expense_provider.dart';
import 'package:splitwise/providers/profile_provider.dart';
import 'package:splitwise/services/backend_response.dart';
import 'package:splitwise/services/backend_service.dart';
import 'package:splitwise/themes/app_theme.dart';
import 'package:splitwise/widgets/background/background_expense.dart';
import 'package:splitwise/widgets/container_error.dart';
import 'package:splitwise/widgets/widgets.dart';

import '../services/firebase_service.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as List<Object?>;
    final ProfileProvider profileProvider = arguments[0] as ProfileProvider;
    final int groupId = arguments[1] as int;
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
        title:
            const Text('Salda tu Deuda', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          const BackgroundExpense(),
          BodyPaymentScreen(profileProvider: profileProvider, groupId: groupId),
        ],
      ),
    );
  }
}

class BodyPaymentScreen extends StatelessWidget {
  const BodyPaymentScreen({
    required this.profileProvider,
    required this.groupId,
    super.key,
  });
  final ProfileProvider profileProvider;
  final int groupId;

  Future<List<BackendResponse>> fetchPaymentData(BackendService backendService,
      ProfileProvider profileProvider, int groupId) async {
    final groupExpenses = await backendService.getGroupBalanceExpenses(groupId);
    final groupDebts = await backendService.getGroupIndividualDebts(
        groupId, profileProvider.profile!.uid);
    return [groupExpenses, groupDebts];
  }

  @override
  Widget build(BuildContext context) {
    final BackendService backendService =
        Provider.of<BackendService>(context, listen: false);
    return FutureBuilder(
      future: fetchPaymentData(backendService, profileProvider, groupId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SpinKitWave(
              color: Colors.indigo.withOpacity(0.5),
              size: 50,
            ),
          );
        }
        if (snapshot.data == null ||
            snapshot.data![0].statusCode != 200 ||
            snapshot.data![1].statusCode != 200) {
          return ContainerDeError(
            error: "Hubo un Error cargando los grupos",
            resolucion: "Trata de recargar la pagina, sino intenta mas tarde",
            error_message: "Error cargando los grupos",
          );
        }
        final groupExpensesMap = snapshot.data![0].body as Map<String, dynamic>;
        final members =
            groupExpensesMap["members"] as List<Map<String, dynamic>>;
        final Map<String, double> debts =
            snapshot.data![1].body as Map<String, double>;
        // return Container();
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: WrapperExpandablePay(
              members: members,
              profileProvider: profileProvider,
              debts: debts,
              groupId: groupId),
        );
      },
    );
  }
}

class WrapperExpandablePay extends StatelessWidget {
  const WrapperExpandablePay({
    super.key,
    required this.members,
    required this.profileProvider,
    required this.debts,
    required this.groupId,
  });
  final int groupId;
  final ProfileProvider profileProvider;
  final List<Map<String, dynamic>> members;
  final Map<String, double> debts;

  @override
  Widget build(BuildContext context) {
    final ExpenseProvider expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: true);
    expenseProvider.clearUidToPay();

    return ExpandablePayExpense(
      members: members,
      expenseProvider: expenseProvider,
      profileProvider: profileProvider,
      debts: debts,
      groupId: groupId,
    );
  }
}

class ExpandablePayExpense extends StatefulWidget {
  const ExpandablePayExpense({
    required this.members,
    required this.expenseProvider,
    required this.profileProvider,
    required this.debts,
    required this.groupId,
    super.key,
  });
  final int groupId;
  final List<Map<String, dynamic>> members;
  final ExpenseProvider expenseProvider;
  final ProfileProvider profileProvider;
  final Map<String, double> debts;
  @override
  State<ExpandablePayExpense> createState() => _ExpandablePayExpenseState();
}

class _ExpandablePayExpenseState extends State<ExpandablePayExpense> {
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> debtsToPay = [];
    for (var debt in widget.debts.entries) {
      if (debt.value < 0) {
        if (debt.key == widget.profileProvider.profile!.uid) {
          continue;
        }
        var debtValue = debt.value;
        if (debt.value.runtimeType == double) {
          debtValue = debt.value.abs();
        }
        debtsToPay.add({
          "id": debt.key,
          "debt": debtValue,
        });
      }
    }

    if (debtsToPay.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.grey.withOpacity(0.8),
              size: 50,
            ),
            Text(
              "No tienes deudas pendientes",
              style: TextStyle(
                color: Colors.grey.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
            fit: FlexFit.loose,
            child: Container(
              decoration: BoxDecoration(
                color:
                    const Color.fromARGB(255, 255, 255, 255).withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Deuda total:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  Text(
                    '\$${widget.expenseProvider.getTotalToPay()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ],
              ),
            )),
        Container(
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width * 1,
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          child: Padding(
              padding: const EdgeInsets.all(8),
              child: Material(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.transparent,
                  child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: debtsToPay.length,
                          itemBuilder: (context, index) {
                            final double debt = debtsToPay[index]["debt"];
                            final Map<String, dynamic> member = widget.members
                                .firstWhere((element) =>
                                    element["id"] == debtsToPay[index]["id"]);
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member["username"],
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromARGB(255, 0, 0, 0)),
                                      ),
                                      Text(
                                        member["email"],
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Color.fromARGB(255, 0, 0, 0)
                                                .withOpacity(0.5)),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Text(
                                    '\$${debt}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 0, 0, 0)),
                                  ),
                                  Checkbox(
                                    value: widget.expenseProvider
                                        .containsUidToPay(member["id"]),
                                    onChanged: (value) {
                                      setState(() {
                                        widget.expenseProvider
                                            .toggleUidToPay(member["id"], debt);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          })))),
        ),
        Flexible(
          fit: FlexFit.loose,
          child: InkWell(
            onTap: () {
              if (widget.expenseProvider.getTotalToPay() == 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Selecciona las deudas a saldar primero')));
                return;
              }
              if (widget.expenseProvider.isLoading == true) {
                return;
              }
              widget.expenseProvider.setLoading(true);
              ConfirmarPago(context, debtsToPay);
              widget.expenseProvider.setLoading(false);
            },
            child: RoundedContainer(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.10,
              text: "Saldar en Efectivo",
              circularProgressIndicator:
                  widget.expenseProvider.isLoading == false
                      ? null
                      : const CircularProgressIndicator(),
            ),
          ),
        ),
        InkWell(
            onTap: () => ConfirmarPago(context, debtsToPay),
            child: MercadoPagoButton(
                debtsToPay: debtsToPay,
                groupId: widget.groupId,
                profileProvider: widget.profileProvider,
                expenseProvider: widget.expenseProvider)),
        const Spacer(),
      ],
    );
  }

  Future<dynamic> ConfirmarPago(
      BuildContext context, List<Map<String, dynamic>> debtsToPay) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Pago'),
          content: Text(
              'Estas seguro de saldar todas estas deudas con un valor total de ${widget.expenseProvider.getTotalToPay()}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                FirebaseApi firebaseApi = FirebaseApi();
                BackendService backendService =
                    Provider.of<BackendService>(context, listen: false);
                String errorResponses = "";
                for (var debt in debtsToPay) {
                  final response = await backendService.payUserDebt(
                    widget.groupId,
                    debt["id"],
                    widget.profileProvider.profile!.uid,
                  );
                  if (response.statusCode != 200) {
                    errorResponses = (response.errorMessage);
                  } else {
                    final BackendResponse responseToken =
                        await backendService.getFirebaseUserToken(debt["id"]);
                    print(
                        "THE RESPONSE TOKEN IS : ${responseToken.body} and status code is : ${responseToken.statusCode}");
                    if (responseToken.statusCode == 200) {
                      final tokens = responseToken.body;
                      print("THE TOKENS ARE : $tokens");
                      print("the debt is : $debt");
                      final body =
                          "Se saldo una deuda con  ${widget.profileProvider.profile!.username} de total ${debt["debt"]}";
                      firebaseApi.sendNotification(
                          title: "Deuda saldada",
                          body: body,
                          token: responseToken.body);
                    }
                  }
                }
                if (errorResponses.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Deuda saldada exitosamente')));
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(errorResponses)));
                }
                // Navigator.of(context).pop();
              },
              child: const Text('Pagar'),
            ),
          ],
        );
      },
    );
  }
}

class MercadoPagoButton extends StatefulWidget {
  const MercadoPagoButton({
    required this.expenseProvider,
    required this.debtsToPay,
    required this.groupId,
    required this.profileProvider,
    super.key,
  });
  final ExpenseProvider expenseProvider;
  final List<Map<String, dynamic>> debtsToPay;
  final int groupId;
  final ProfileProvider profileProvider;
  @override
  State<MercadoPagoButton> createState() => _MercadoPagoButtonState();
}

class _MercadoPagoButtonState extends State<MercadoPagoButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (widget.expenseProvider.getTotalToPay() == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Selecciona las deudas a saldar')));
          return;
        }
        if (widget.expenseProvider.isLoading == true) {
          return;
        }
        widget.expenseProvider.setLoading(true);
        await Future.delayed(const Duration(seconds: 2));
        BackendService backendService =
            Provider.of<BackendService>(context, listen: false);
        String errorResponses = "";
        final FirebaseApi firebaseApi = FirebaseApi();
        for (var debt in widget.debtsToPay) {
          final response = await backendService.payUserDebt(
            widget.groupId,
            debt["id"],
            widget.profileProvider.profile!.uid,
          );
          if (response.statusCode != 200) {
            errorResponses = (response.errorMessage);
          } else {
            final BackendResponse responseToken =
                await backendService.getFirebaseUserToken(debt["id"]);
            if (responseToken.statusCode == 200) {
              final body =
                  "Se saldo una deuda con  ${widget.profileProvider.profile!.username} de total ${debt["total_spent"]}";
              firebaseApi.sendNotification(
                  title: "Deuda saldada",
                  body: body,
                  token: responseToken.body);
            }
          }
        }
        if (errorResponses.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Deuda saldada exitosamente')));
          widget.expenseProvider.setLoading(false);
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(errorResponses)));
        }
        widget.expenseProvider.setLoading(false);
      },
      child: Container(
          height: MediaQuery.of(context).size.height * 0.10,
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[400],
                    borderRadius: const BorderRadius.all(
                      Radius.circular(15),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.blue[100]!,
                        Colors.blue[400]!,
                      ],
                    ),
                  ),
                  child: Center(
                    child: widget.expenseProvider.isLoading == false
                        ? Image.asset(
                            'assets/logo_mercado.png',
                            width: 150,
                            height: 150,
                          )
                        : const CircularProgressIndicator(),
                  ),
                )),
          )),
    );
  }
}
