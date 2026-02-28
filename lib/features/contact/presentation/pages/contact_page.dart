import 'package:convo/core/const.dart/slide_page_route.dart';
import 'package:convo/features/chat/presentation/pages/chat_page.dart';
import 'package:convo/features/chat/presentation/pages/voice_call_page.dart';
import 'package:convo/features/contact/presentation/bloc/bloc/contact_bloc.dart';
import 'package:convo/features/contact/presentation/pages/create_group_page.dart';
import 'package:convo/features/contact/presentation/widgets/build_Action_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:convo/core/const.dart/app_colors.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  bool isSearching = false;
  String searchQuery = "";
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ContactBloc>().add(ContactEvent.init());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactBloc, ContactState>(
      builder: (context, state) {
        final filteredContacts = state.contacts.where((user) {
          return user.name.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.backgroundColor(context),

          appBar: AppBar(
            backgroundColor: AppColors.invertTextColor(context),
            elevation: 6,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, color: AppColors.textColor(context)),
            ),
            title: isSearching
                ? TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: "Search contact...",
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Select Contact",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor(context),
                        ),
                      ),
                      Text(
                        "${state.contacts.length} contacts",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textColor(context),
                        ),
                      ),
                    ],
                  ),
            actions: [
              IconButton(
                icon: Icon(
                  isSearching ? Icons.close : Icons.search,
                  color: AppColors.textColor(context),
                ),
                onPressed: () {
                  setState(() {
                    if (isSearching) {
                      searchQuery = "";
                      searchController.clear();
                    }
                    isSearching = !isSearching;
                  });
                },
              ),
            ],
          ),

          body: Column(
            children: [
              if (!isSearching)
                Container(
                  margin: const EdgeInsets.all(14),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.invertTextColor(context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      BuildActionTitleWidget(
                        icon: Icons.group,
                        title: "Create Group",
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (contect) => CreateGroupPage(),
                            ),
                          );
                        },
                      ),
                      BuildActionTitleWidget(
                        icon: Icons.person_add,
                        title: "New Contact",
                      ),
                      BuildActionTitleWidget(
                        icon: Icons.campaign,
                        title: "New Channel",
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: filteredContacts.isEmpty
                    ? const Center(child: Text("No contacts found"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        itemCount: filteredContacts.length,
                        itemBuilder: (context, index) {
                          final user = filteredContacts[index];

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.invertTextColor(context),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  user.name[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                user.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.iconColor(context),
                                ),
                              ),
                              subtitle: Text(
                                user.about,
                                style: TextStyle(
                                  color: AppColors.iconColor(context),
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.call,
                                  color: AppColors.iconColor(context),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                  context,
                                  SlidePageRoute(
                                    page: VoiceCallPage(user: user),
                                    beginOffset: const Offset(
                                      1,
                                      0,
                                    ), 
                                  ),
                                );
                                },
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  SlidePageRoute(
                                    page: ChatPage(user: user),
                                    beginOffset: const Offset(
                                      -1,
                                      0,
                                    ), 
                                  ),
                                );
                              },
                            ),
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
