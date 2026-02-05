import 'package:convo/core/enum/status.dart';
import 'package:convo/features/auth/presentation/pages/chat_page.dart';
import 'package:convo/features/home/presentation/bloc/chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/features/home/presentation/widgets/custom_icon.dart';
import 'package:convo/features/home/presentation/widgets/custom_text.dart';

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
            toolbarHeight: 80,
            backgroundColor: AppColors.matchTheme(context),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: CustomIcon(icon: Icons.arrow_back, size: 30),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: "Select Contact",
                  size: 24,
                  bold: FontWeight.bold,
                ),
                const SizedBox(height: 4),
                Text(
                  "${state.contacts.length} contacts",
                  style: TextStyle(
                    color: AppColors.textColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          /// BODY
body: state.contactStatus == Status.loading
    ? Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      )
    : state.contacts.isEmpty
        ? const Center(
            child: Text(
              "No contacts found",
              style: TextStyle(color: Colors.grey),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.contacts.length,
            itemBuilder: (context, i) {
              final contactItem = state.contacts[i];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatPage(contactItem.id.toString()),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(contactItem.id.toString(),style: TextStyle(color: Colors.white),),
                      /// 👤 Avatar
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          contactItem.lotti,
                          // contactItem.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      /// 📇 Name & Phone
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contactItem.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              contactItem.phone,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
