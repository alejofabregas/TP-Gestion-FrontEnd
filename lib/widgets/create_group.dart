import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:splitwise/helpers/display.dart';
import 'package:splitwise/services/backend_response.dart';
import 'package:splitwise/widgets/login_field.dart';

import '../helpers/form_helper.dart';
import '../providers/providers.dart';
import '../services/services.dart';

class CreateNewGroup extends StatelessWidget {
  const CreateNewGroup({
    required this.groupProvider,
    required this.formHelper,
    required this.profileProvider,
    this.values,
    super.key,
  });

  final Map<String, dynamic>? values;
  final FormHelper formHelper;
  final GroupProvider groupProvider;
  final ProfileProvider profileProvider;

  @override
  Widget build(BuildContext context) {
    final BackendService backendService =
        Provider.of<BackendService>(context, listen: false);
    return AlertDialog(
      elevation: 20,
      title: Text(values == null ? "Crear un nuevo grupo" : "Editar el grupo"),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.circular(15)),
      content: Form(
        key: groupProvider.formLoginKey,
        // autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoginFormField(
                isPassword: false,
                text: 'Ingresa el Nombre',
                formProperty: 'name',
                formValues: groupProvider.formValues,
                validator: formHelper.isValidGroupName,
              ),
              LoginFormField(
                isPassword: false,
                text: 'Ingresa el Presupuesto',
                formProperty: 'budget',
                formValues: groupProvider.formValues,
                validator: formHelper.isValidBudget,
                keyboardType: TextInputType.number,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.2,
                child: LoginFormField(
                  isPassword: false,
                  text: 'Ingresa la descripcion',
                  formProperty: 'description',
                  formValues: groupProvider.formValues,
                  validator: formHelper.isValidGroupName,
                  maxLines: 7,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar', style: TextStyle(color: Colors.red))),
        TextButton(
            onPressed: () async {
              if (!groupProvider.isValidForm()) {
                return;
              }
              Map<String, dynamic> backendValues = values == null
                  ? {
                      'user_id': profileProvider.profile!.uid,
                      'id': values != null ? values!['id']! as int : '',
                      'name': groupProvider.formValues['name']!,
                      'budget': groupProvider.formValues['budget']!,
                      'description': groupProvider.formValues['description']!,
                    }
                  : {
                      'admin_id': profileProvider.profile!.uid,
                      'new_name': groupProvider.formValues['name']!,
                      'new_description':
                          groupProvider.formValues['description']!,
                    };

              Navigator.pop(context);
              BackendResponse response;
              values == null
                  ? response = await backendService.createGroup(backendValues)
                  : response = await backendService.editGroup(
                      backendValues, values!['id']! as int);
              if ((values != null && response.statusCode != 200) ||
                  (values == null && response.statusCode != 201)) {
                final text = values == null ? "creando" : "editando";
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Hubo un error $text el grupo'),
                ));
              }
            },
            child: const Text('Aceptar'))
      ],
    );
  }
}
