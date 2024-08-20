import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:splitwise/helpers/display.dart';
import 'package:splitwise/helpers/form_helper.dart';
import 'package:splitwise/models/models.dart';
import 'package:splitwise/providers/login_form.dart';
import 'package:splitwise/providers/profile_provider.dart';
import 'package:splitwise/services/backend_service.dart';
import 'package:splitwise/services/firebase_service.dart';
import 'package:splitwise/services/services.dart';
import 'package:splitwise/widgets/widgets.dart';
import 'package:splitwise/providers/providers.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FormHelper formHelper = FormHelper();
  bool aceptar = false;
  @override
  Widget build(BuildContext context) {
    final BackendService backendService =
        Provider.of<BackendService>(context, listen: false);
    final loginForm = Provider.of<LoginFormProvider>(context);
    final loadingProvider = Provider.of<LoadingProvider>(context, listen: true);
    ProfileProvider profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;

    return PopScope(
      child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              const BackgroundStart(),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: loginForm.register == true
                              ? size.height * 0.1
                              : size.height * 0.2),
                      const Text(
                        'Maestro Splitter',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontFamily: 'Calibri',
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: 300,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Form(
                              key: loginForm.formLoginKey,
                              child: Column(
                                children: [
                                  loginForm.register == true
                                      ? Column(
                                          children: [
                                            LoginFormField(
                                              isPassword: false,
                                              text: 'Nombre de Usuario',
                                              formProperty: 'name',
                                              formValues: loginForm.formValues,
                                              validator: formHelper.isValidName,
                                            ),
                                            SizedBox(
                                                height: size.height * 0.02),
                                          ],
                                        )
                                      : const SizedBox(height: 0),
                                  LoginFormField(
                                    isPassword: false,
                                    text: 'Email',
                                    formProperty: 'email',
                                    keyboardType: TextInputType.emailAddress,
                                    formValues: loginForm.formValues,
                                    validator: formHelper.isValidEmail,
                                  ),
                                  loginForm.register != true
                                      ? const SizedBox(height: 0)
                                      : Column(
                                          children: [
                                            SizedBox(
                                                height: size.height * 0.02),
                                            LoginFormField(
                                              isPassword: false,
                                              text: 'Alias de Mercado Pago',
                                              formProperty: 'mp_alias',
                                              formValues: loginForm.formValues,
                                              validator: formHelper.isValidName,
                                            ),
                                          ],
                                        ),
                                  SizedBox(height: size.height * 0.02),
                                  LoginFormField(
                                    isPassword: true,
                                    text: 'Contraseña',
                                    formProperty: 'password',
                                    formValues: loginForm.formValues,
                                    validator: formHelper.isValidPassword,
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      FocusScope.of(context).unfocus();
                                      if (!loginForm.isValidForm() ||
                                          loadingProvider.isLoading) {
                                        return;
                                      }
                                      loadingProvider.isLoading = true;
                                      await authServiceLogin(context, loginForm,
                                          profileProvider, backendService);
                                      loadingProvider.isLoading =
                                          false; // Move this line inside authServiceLogin
                                    },
                                    child: Consumer<LoadingProvider>(
                                      builder: (context, loadingProvider, _) {
                                        return loadingProvider.isLoading ==
                                                false
                                            ? RoundedContainer(
                                                text: (loginForm.register ==
                                                        false)
                                                    ? "Login"
                                                    : "Registrarme",
                                                color: Colors.blue)
                                            : const RoundedContainer(
                                                circularProgressIndicator:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 3.0,
                                                  color: Colors.white,
                                                ),
                                                color: Colors.blue);
                                      },
                                    ),
                                  ),
                                  RegisterButton(login_provider: loginForm)
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}

class RegisterButton extends StatelessWidget {
  const RegisterButton({
    required this.login_provider,
    super.key,
  });
  final LoginFormProvider login_provider;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey;
          }
          return const Color.fromARGB(
              255, 158, 158, 158); // Use your preferred color
        }),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      onPressed: () {
        login_provider.register = !login_provider.register;
      },
      child: Text(
        (login_provider.register) ? 'Login' : "Registrarme",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

Future<void> authServiceLogin(
    BuildContext context,
    LoginFormProvider loginFormProvider,
    ProfileProvider profileProvider,
    BackendService backendService) async {
  // Simulating a delay to mimic an asynchronous operation (e.g., API call)
  // hardodear un registro en firebase
  // await Future.delayed(const Duration(seconds: 2));
  String message = "";
  try {
    String userName = "";
    if (loginFormProvider.register == false) {
      message = "Error logeando un usuario";
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: loginFormProvider.formValues['email']!,
        password: loginFormProvider.formValues['password']!,
      );
      final response =
          await backendService.getUser(FirebaseAuth.instance.currentUser!.uid);

      final FirebaseApi firebaseApi = FirebaseApi();
      final token = await firebaseApi.initNotifications();
      if (token != null) {
        await backendService.patchFirebaseToken(
            FirebaseAuth.instance.currentUser!.uid, token);
      }

      // print(response.body);
      if (response.statusCode != 200) {
        FirebaseAuth.instance.currentUser!.delete();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Error logeando un usuario, por favor intenta de nuevo'),
        ));
        return;
      }
      userName = response.body['username'];
    } else {
      message = "Error registrando un usuario";
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: loginFormProvider.formValues['email']!,
        password: loginFormProvider.formValues['password']!,
      );
      Map<String, String> backendValues = {
        "id": userCredential.user!.uid,
        "username": loginFormProvider.formValues['name']!,
        "email": loginFormProvider.formValues['email']!,
        "mp_alias": loginFormProvider.formValues['mp_alias']!,
      };
      final response = await backendService.createUser(backendValues);
      userName = loginFormProvider.formValues['name']!;
      if (response.statusCode != 201) {
        final error = response.body as Map<String, dynamic>;
        final errorMessage = error['error'];
        FirebaseAuth.instance.currentUser!.delete();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
        ));
        return;
      }
    }
    profileProvider.setProfile(Profile.fromUser(
        FirebaseAuth.instance.currentUser!,
        userName,
        loginFormProvider.formValues['email']!));
    Navigator.pushReplacementNamed(context, 'home_page',
        arguments: [profileProvider]);
  } on FirebaseAuthException catch (e) {
    print(e);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(e.message!),
    ));
  } on Exception catch (e) {
    displayDialogAndroid(context, message, e.toString());
  }
}
