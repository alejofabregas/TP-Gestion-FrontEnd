import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:splitwise/services/backend_response.dart';
import 'package:splitwise/services/firebase_service.dart';

class BackendService extends ChangeNotifier {
  final String _baseUrl = 'http://10.0.2.2:8721';

  Future<BackendResponse> createUser(Map<String, String> formValues) async {
    try {
      final FirebaseApi firebaseApi = FirebaseApi();
      final token = await firebaseApi.initNotifications();
      print("Token: $token");
      formValues["firebase_token"] = token!;

      final response = await http.post(Uri.parse('$_baseUrl/users'),
          body: json.encode(formValues),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          });

      if (response.statusCode == 200) {
        final BackendResponse backendResponse = BackendResponse(
            statusCode: response.statusCode,
            body: response.body,
            errorMessage: response.body);
        return backendResponse;
      }
      final Map<String, dynamic> jsonData;
      jsonData = json.decode(utf8.decode(response.bodyBytes));

      final BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: jsonData,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> createGroup(Map<String, dynamic> formValues) async {
    try {
      final response = await http.post(Uri.parse('$_baseUrl/groups'),
          body: json.encode(formValues),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          });
      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: response.body,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> addIntegrant(int group_Id, String user_id) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/groups/members/$group_Id/$user_id'),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        },
      );

      BackendResponse backendResponse = BackendResponse(
        statusCode: response.statusCode,
        body: response.body,
        errorMessage: response.body,
      );
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
        statusCode: 500,
        body: e.toString(),
        errorMessage: e.toString(),
      );
      return response;
    }
  }

  Future<BackendResponse> userGroups(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/groups/member/$userId'), headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      });

      final List<dynamic> jsonData;
      jsonData = json.decode(utf8.decode(response.bodyBytes));
      final List<Map<String, dynamic>> decodedResp =
          jsonData.map((dynamic item) => item as Map<String, dynamic>).toList();
      final List<Map<String, dynamic>> filteredResp = decodedResp
          .where((Map<String, dynamic> item) => item['pending'] == false)
          .toList();
      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: filteredResp,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> getGroupIntegrants(int groupId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/groups/members/$groupId'), headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      });
      final List<dynamic> jsonData;
      jsonData = json.decode(utf8.decode(response.bodyBytes));
      final List<Map<String, dynamic>> decodedResp =
          jsonData.map((dynamic item) => item as Map<String, dynamic>).toList();

      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: decodedResp,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> getUser(String id) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/users/$id'), headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      });

      Map<String, dynamic> decodedResp =
          json.decode(utf8.decode(response.bodyBytes));
      BackendResponse backendResponse = BackendResponse(
        statusCode: response.statusCode,
        body: decodedResp,
        errorMessage: response.body,
      );
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
        statusCode: 500,
        body: e.toString(),
        errorMessage: e.toString(),
      );
      return response;
    }
  }

  Future<BackendResponse> editUser(String newUser, String id) async {
    try {
      final Map<String, String> map = {
        "new_username": newUser,
        "user_id": id,
      };
      final response = await http.patch(Uri.parse('$_baseUrl/users'),
          body: json.encode(map),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          });
      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: response.body,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> editGroup(
      Map<String, dynamic> formValues, int group_id) async {
    try {
      final response = await http.patch(Uri.parse('$_baseUrl/groups/$group_id'),
          body: json.encode(formValues),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          });
      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: response.body,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> getMatchingUsernameOrEmail(
      String userIdentification) async {
    try {
      final response = await http.get(
          Uri.parse('$_baseUrl/users/identification/$userIdentification'),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          });
      final List<dynamic> jsonData;
      jsonData = json.decode(utf8.decode(response.bodyBytes));

      final List<Map<String, dynamic>> decodedResp =
          jsonData.map((dynamic item) => item as Map<String, dynamic>).toList();

      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: decodedResp,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> userInvitations(String userIdentification) async {
    try {
      final response = await http.get(
          Uri.parse('$_baseUrl/groups/member/$userIdentification'),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          });

      if (response.body is Map<String, dynamic>) {
        BackendResponse backendResponse = BackendResponse(
            statusCode: response.statusCode,
            body: [],
            errorMessage: response.body);
        return backendResponse;
      }
      ;
      final List<dynamic> jsonData;
      jsonData = json.decode(utf8.decode(response.bodyBytes));

      final List<Map<String, dynamic>> decodedResp =
          jsonData.map((dynamic item) => item as Map<String, dynamic>).toList();

      final List<Map<String, dynamic>> filteredResp = decodedResp
          .where((Map<String, dynamic> item) => item['pending'] == true)
          .toList();
      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: filteredResp,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> acceptInvitation(int groupId, String userId) async {
    try {
      final response = await http.patch(
          Uri.parse('$_baseUrl/groups/members/$groupId/$userId'),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          });

      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: response.body,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> declineInvitation(int groupId, String userId) async {
    try {
      final response = await http.delete(
          Uri.parse('$_baseUrl/groups/members/$groupId/$userId'),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          });

      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: response.body,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> removeUserFromGroup(
      int groupId, String userId) async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl/groups/$groupId/$userId'), headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      });

      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: response.body,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> nameGroupAdmin(
      int groupId, String userId, String adminid) async {
    try {
      final response = await http.patch(
          Uri.parse('$_baseUrl/groups/admins/$groupId/$adminid'),
          body: json.encode({'new_admin_id': userId}),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          });
      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: response.body,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> getIndividualExpenses(
    int groupId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/expenses/individual/$groupId'),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        },
      );

      List<dynamic> jsonData;
      jsonData = json.decode(utf8.decode(response.bodyBytes));

      jsonData =
          (jsonData).map((item) => item as Map<String, dynamic>).toList();

      BackendResponse backendResponse = BackendResponse(
        statusCode: 200,
        body: jsonData,
        errorMessage: "No hay",
      );

      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
        statusCode: 500,
        body: e.toString(),
        errorMessage: e.toString(),
      );
      return response;
    }
  }

  Future<BackendResponse> getGroupBalanceExpenses(
    int groupId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/expenses/balance/$groupId'),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        },
      );

      final Map<String, dynamic> jsonData =
          json.decode(utf8.decode(response.bodyBytes));

      jsonData["members"] = (jsonData["members"] as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();

      BackendResponse backendResponse = BackendResponse(
        statusCode: 200,
        body: jsonData,
        errorMessage: "No hay",
      );

      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
        statusCode: 500,
        body: e.toString(),
        errorMessage: e.toString(),
      );
      return response;
    }
  }

  Future<BackendResponse> getCategories() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/expenses/options/categories'), headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      });

      final List<dynamic> jsonData;
      jsonData = json.decode(utf8.decode(response.bodyBytes));

      final List<String> decodedResp = jsonData.cast<String>().toList();

      BackendResponse backendResponse = BackendResponse(
          statusCode: 200, body: decodedResp, errorMessage: "No hay");
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> getCurrency() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/expenses/options/currencies'), headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      });

      final List<dynamic> jsonData;
      jsonData = json.decode(utf8.decode(response.bodyBytes));
      final List<String> decodedResp = jsonData.cast<String>().toList();

      BackendResponse backendResponse = BackendResponse(
          statusCode: 200, body: decodedResp, errorMessage: "No hay");
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> getGroupIndividualDebts(
      int groupId, String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/expenses/debts/$groupId/$userId'),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        },
      );

      final List<dynamic> jsonData;
      jsonData = json.decode(utf8.decode(response.bodyBytes));
      final List<Map<String, dynamic>> decodedResp =
          jsonData.map((dynamic item) => item as Map<String, dynamic>).toList();
      Map<String, double> debtsUid = {};
      for (final debt in decodedResp) {
        if (debt["debtor_id"] != userId) {
          if (!debtsUid.containsKey(debt["debtor_id"])) {
            debtsUid[debt["debtor_id"]] = 0.0;
          }
          debtsUid[debt["debtor_id"]] =
              debtsUid[debt["debtor_id"]]! + debt["amount_owed"];
        }
        if (debt["creditor_id"] != userId) {
          if (!debtsUid.containsKey(debt["creditor_id"])) {
            debtsUid[debt["creditor_id"]] = 0.0;
          }
          debtsUid[debt["creditor_id"]] =
              debtsUid[debt["creditor_id"]]! - debt["amount_owed"];
        }
      }
      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: debtsUid,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> createExpense(Map<String, dynamic> formValues,
      List<Map<String, dynamic>> integrants, int groupId) async {
    try {
      final checkedIntegrants =
          integrants.where((integrant) => integrant["check"] == true).toList();
      formValues["participants"] = checkedIntegrants;
      print("the form values is $formValues");
      final response = await http.post(Uri.parse('$_baseUrl/expenses/$groupId'),
          body: json.encode(formValues),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          });
      if (response.statusCode != 201) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        return BackendResponse(
            statusCode: 400,
            body: decodedData,
            errorMessage: decodedData["error"]);
      }
      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: response.body,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> editExpense(Map<String, dynamic> formValues,
      List<Map<String, dynamic>> integrants, int expenseId, int groupId) async {
    try {
      final checkedIntegrants =
          integrants.where((integrant) => integrant["check"] == true).toList();
      formValues["participants"] = checkedIntegrants;
      final response = await http.put(
          Uri.parse('$_baseUrl/expenses/$groupId/$expenseId'),
          body: json.encode(formValues),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          });

      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: response.body,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> getUserGroupDebts(
      String userId, String groupId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/expenses/debts/$groupId/$userId'),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        },
      );

      final List<dynamic> jsonData;
      jsonData = json.decode(utf8.decode(response.bodyBytes));
      final List<Map<String, dynamic>> decodedResp =
          jsonData.map((dynamic item) => item as Map<String, dynamic>).toList();

      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: decodedResp,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> payUserDebt(
      int groupId, String userId, String debtId) async {
    try {
      final response = await http.patch(
          Uri.parse('$_baseUrl/expenses/debts/$groupId/$userId'),
          body: json.encode({"debtor_id": debtId}),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          });

      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: response.body,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> deleteFirebaseToken(String userId) async {
    try {
      final response = await http.delete(
          Uri.parse('$_baseUrl/users/firebase_token/$userId'),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          });
      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: response.body,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> getGroupHistory(int groupId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/expenses/history/$groupId'),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        },
      );

      if (response.statusCode == 400) {
        BackendResponse response = BackendResponse(
            statusCode: 400, body: [], errorMessage: "No hay Pagos");
        return response;
      }

      final Map<String, dynamic> jsonData =
          json.decode(utf8.decode(response.bodyBytes));

      double totalSpent = jsonData['total_spent'].toDouble();
      List<Map<String, dynamic>> payments = (jsonData['payments'] as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();

      List<Map<String, dynamic>> decodedResp = [];
      for (Map<String, dynamic> payment in payments) {
        Map<String, dynamic> debtor = payment['debtor'];
        Map<String, dynamic> creditor = payment['creditor'];
        double amount = payment['amount'].toDouble();
        String date = payment['date'];

        decodedResp.add({
          'debtor': debtor,
          'creditor': creditor,
          'amount': amount,
          'date': date,
        });
      }

      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: {
            'total_spent': totalSpent,
            'payments': decodedResp,
          },
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> getGroupCategoriesHistory(
      List<String> categories, int groupId) async {
    try {
      // Convert the categories list to a query parameter string
      String queryParams =
          categories.map((category) => 'categories=$category').join('&');
      // Build the complete URL with query parameters
      final url =
          Uri.parse('$_baseUrl/expenses/categories/$groupId?$queryParams');
      final response = await http.get(url, headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      });
      print("the status code is ${response.statusCode}");
      if (response.statusCode == 404) {
        BackendResponse response = BackendResponse(
            statusCode: 400, body: [], errorMessage: "No hay gastos");
        return response;
      }
      List<Map<String, dynamic>> expenses = (jsonDecode(response.body) as List)
          .where((item) => item is Map<String, dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList();

      double totalSpent = 0;
      List<Map<String, dynamic>> arrayIndividualExpenses = [];

      for (Map<String, dynamic> expense in expenses) {
        int id = expense['id'];
        int groupId = expense['group_id'];
        totalSpent += expense['total_spent'].toDouble();
        String category = expense['category'];
        String currency = expense['currency'];
        String description = expense['description'];
        List<Map<String, dynamic>> participants =
            (expense['participants'] as List)
                .map((item) => item as Map<String, dynamic>)
                .toList();

        arrayIndividualExpenses.add({
          'id': id,
          'group_id': groupId,
          'total_spent': totalSpent,
          'category': category,
          'currency': currency,
          'description': description,
          'participants': participants,
        });
      }

      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: {
            'total_spent': totalSpent,
            'arrayIndividualExpenses': arrayIndividualExpenses,
          },
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      print("El error es $e");
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> getGroupBudget(int groupId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/groups/$groupId/budget'), headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      });
      Map<String, dynamic> jsonData =
          json.decode(utf8.decode(response.bodyBytes));
      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: jsonData,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> editGroupBudget(
      double newBudget, int groupId, String userId) async {
    try {
      final response = await http.patch(
          Uri.parse('$_baseUrl/groups/$groupId/$userId/budget'),
          body: json.encode({"new_budget": newBudget}),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          });
      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: response.body,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      print("El error es $e");
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> getFirebaseUserToken(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/users/firebase_token/$userId'), headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      });
      final String token = json.decode(utf8.decode(response.bodyBytes));
      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: token,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> getGroupBudgetLeftPercentage(int groupId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/groups/$groupId/budget'), headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      });
      Map<String, dynamic> jsonData =
          json.decode(utf8.decode(response.bodyBytes));
      final total = jsonData['group_budget'];
      final spent = jsonData['total_spent'];
      final totalSpentPercentage = (spent / total) * 100;
      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: totalSpentPercentage,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> patchFirebaseToken(
      String userId, String token) async {
    try {
      final response = await http.patch(
          Uri.parse('$_baseUrl/users/firebase_token/$userId'),
          body: json.encode({"firebase_token": token}),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          });
      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: response.body,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      print("El error es $e");
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }

  Future<BackendResponse> getGroupToken(int groupId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/groups/$groupId/firebase_token'), headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      });
      final List<dynamic> jsonData;
      jsonData = json.decode(utf8.decode(response.bodyBytes));
      final List<String> decodedResp = jsonData.cast<String>().toList();
      BackendResponse backendResponse = BackendResponse(
          statusCode: response.statusCode,
          body: decodedResp,
          errorMessage: response.body);
      return backendResponse;
    } catch (e) {
      BackendResponse response = BackendResponse(
          statusCode: 500, body: e.toString(), errorMessage: e.toString());
      return response;
    }
  }
}
