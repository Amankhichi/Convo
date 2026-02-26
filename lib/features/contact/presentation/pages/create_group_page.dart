import 'package:convo/features/contact/presentation/bloc/bloc/contact_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:convo/core/const.dart/app_colors.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {

  final TextEditingController groupNameController = TextEditingController();
  final List<dynamic> selectedUsers = [];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactBloc, ContactState>(
      builder: (context, state) {

        return Scaffold(
          backgroundColor: AppColors.backgroundColor(context),

          appBar: AppBar(
            title: const Text("Create Group"),
            backgroundColor: AppColors.matchTheme(context),
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  if (groupNameController.text.isEmpty ||
                      selectedUsers.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Enter group name & select members"),
                      ),
                    );
                    return;
                  }

                  print("Group Name: ${groupNameController.text}");
                  print("Members: ${selectedUsers.length}");

                  Navigator.pop(context);
                },
              )
            ],
          ),

          body: Column(
            children: [

              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.matchTheme(context),
                child: Row(
                  children: [

                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.group,
                              color: Colors.white, size: 30),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.primary,
                            child: const Icon(Icons.camera_alt,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: TextField(
                        controller: groupNameController,
                        decoration: const InputDecoration(
                          hintText: "Group Name",
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Select Members",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textColor(context),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: ListView.builder(
                  itemCount: state.contacts.length,
                  itemBuilder: (context, index) {
                    final user = state.contacts[index];
                    final isSelected =
                        selectedUsers.contains(user);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white),
                        ),
                      ),
                      title: Text(user.name),
                      subtitle: Text(user.about),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: Colors.green)
                          : const Icon(Icons.circle_outlined),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedUsers.remove(user);
                          } else {
                            selectedUsers.add(user);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}