import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../group/group_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var uuid = Uuid();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Chat App'),
      ),
      body: Center(
        child: TextButton(
            onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('please enter your name'),
                    content: Form(
                      key: formKey,
                      child: TextFormField(
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.length < 3) {
                            return "enter name!";
                          }
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('cancel')),
                      TextButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GroupPage(
                                        name: nameController.text.trim(),
                                        userId: uuid.v1()),
                                  ));
                            }
                          },
                          child: Text('Enter')),
                    ],
                  ),
                ),
            child: const Text('Intitiate Group chat')),
      ),
    );
  }
}
