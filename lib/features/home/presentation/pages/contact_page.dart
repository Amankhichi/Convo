import 'package:convo/features/auth/presentation/pages/chat_page.dart';
import 'package:convo/features/home/presentation/widgets/custom_text.dart';
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
    context.read<ChatBloc>().add(ChatEvent.init());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColor(context),
          appBar: AppBar(
            toolbarHeight: 80,
            backgroundColor: AppColors.matchTheme(context),
            elevation: 8, // 👈 Shadow strength
            shadowColor: Colors.black54,

            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, size: 30, color: AppColors.textColor(context)),
            ),

            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Select Contact\n",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor(context),
                    ),
                  ),
                  TextSpan(
                    text: "${state.contacts.length} contacts",
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textColor(context),
                    ),
                  ),
                ],
              ),
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

                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {});
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.matchTheme(context),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              spreadRadius: 0,
                              offset: Offset(0, 3), // 👈 shadow only bottom
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            // vertical: 2,
                            horizontal: 17,
                          ),
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              user.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: user.name,
                                bold: FontWeight.w600,
                                size: 20,
                              ),
                              Text(
                                user.about,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: AppColors.iconColor(context),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatPage(user: user),
                              ),
                            );
                            Divider(thickness: 0.5, color: Colors.black26);
                          },
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
