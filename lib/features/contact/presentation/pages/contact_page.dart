import 'package:convo/const.dart/app_loading.dart';
import 'package:convo/const.dart/slide_page_route.dart';
import 'package:convo/features/chat/presentation/pages/chat_page.dart';
import 'package:convo/features/chat/presentation/pages/voice_call_page.dart';
import 'package:convo/features/contact/presentation/bloc/bloc/contact_bloc.dart';
import 'package:convo/features/contact/presentation/pages/create_group_page.dart';
import 'package:convo/features/contact/presentation/pages/dailpad_page.dart';
import 'package:convo/features/contact/presentation/widgets/build_Action_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:convo/const.dart/app_colors.dart';

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

  // --- INSTANT APP CALL ROUTING ---
  void _navigateToCallScreen(BuildContext context, dynamic user) {
    Navigator.push(
      context,
      SlidePageRoute(
        page: VoiceCallPage(user: user),
        beginOffset: const Offset(0, 1), // Smooth bottom-to-top transition for calling
      ),
    );
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
         appBar: PremiumAppBar(
  title: isSearching ? "" : "Select Contact",
  // Displays the contact count as a subtitle when not searching
  subtitle: isSearching ? null : "${state.contacts.length} contacts",
  showBack: true,
  actions: [
    // If searching, show the TextField directly inside the actions block alongside the close button
    if (isSearching)
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(left: 50.0, right: 8.0),
          child: TextField(
            controller: searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Search contact...",
              hintStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
        ),
      ),
    
    // Search toggle button (Changes icon between Search and Close)
    IconButton(
      icon: Icon(
        isSearching ? Icons.close : Icons.search,
        color: Colors.white,
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
                  margin: const EdgeInsets.all(10),
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
                              builder: (context) => const CreateGroupPage(),
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
                    ? Center(child: AppLoader())
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                  color: AppColors.iconColor,
                                ),
                              ),
                              subtitle: Text(
                                user.about,
                                style: TextStyle(color: AppColors.iconColor),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.call,
                                  color: AppColors.iconColor,
                                ),
                                onPressed: () {
                                  // Instantly triggers your custom application call layout screen
                                  _navigateToCallScreen(context, user);
                                },
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  SlidePageRoute(
                                    page: ChatPage(user: user),
                                    beginOffset: const Offset(-1, 0),
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
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.dialpad, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DialpadPage(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}