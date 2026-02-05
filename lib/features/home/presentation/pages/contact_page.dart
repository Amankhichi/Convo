import 'package:convo/features/auth/presentation/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:convo/core/enum/status.dart';
import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/features/home/presentation/bloc/chat_bloc/chat_bloc.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(ChatEvent.contactsLoading());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColor(context),
          appBar: AppBar(
            backgroundColor: AppColors.matchTheme(context),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Contact",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${state.contacts.length} contacts",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          body: state.contactStatus == Status.loading
              ? const Center(child: CircularProgressIndicator())
              : state.contacts.isEmpty
                  ? const Center(child: Text("No contacts found"))
                  : ListView.builder(
                      itemCount: state.contacts.length,
                      padding: const EdgeInsets.all(12),
                      itemBuilder: (context, i) {
                        final user = state.contacts[i];

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Text(
                              user.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            user.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(user.phone),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatPage(user: user),
                              ),
                            );
                          },
                        );
                      },
                    ),
        );
      },
    );
  }
}
