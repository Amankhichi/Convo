import 'package:convo/app/config/api_config.dart';
import 'package:convo/app/router/route_names.dart';
import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/core/widgets/app_scaffold.dart';
import 'package:convo/features/chats/domain/repositories/chat_repository.dart';
import 'package:convo/features/contacts/domain/entities/contact_entity.dart';
import 'package:convo/features/contacts/presentation/bloc/contacts_bloc.dart';
import 'package:convo/features/contacts/presentation/bloc/contacts_event.dart';
import 'package:convo/features/contacts/presentation/bloc/contacts_state.dart';
import 'package:convo/injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = "";
  final Set<int> _processedUsers = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _precreateChatIds(List<ContactEntity> contacts) {
    final chatRepository = sl<ChatRepository>();
    for (var contact in contacts) {
      if (contact.id > 0 && !_processedUsers.contains(contact.id)) {
        _processedUsers.add(contact.id);
        final cachedChatId = chatRepository.getCachedChatId(contact.id);
        if (cachedChatId == null) {
          chatRepository.getOrCreateChatId(contact.id).catchError((_) => 0);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => sl<ContactsBloc>()..add(const SyncContactsEvent()),
      child: BlocConsumer<ContactsBloc, ContactsState>(
        listener: (context, state) {
          if (state is ContactsLoaded) {
            _precreateChatIds(state.contacts);
          }
        },
        builder: (context, state) {
          List<ContactEntity> contactsList = [];
          if (state is ContactsLoaded) {
            contactsList = state.contacts;
          }

          final filteredContacts = contactsList.where((c) {
            if (_searchQuery.isEmpty) return true;
            final query = _searchQuery.toLowerCase();
            return c.name.toLowerCase().contains(query) ||
                c.phoneNumber.contains(query) ||
                c.about.toLowerCase().contains(query);
          }).toList();

          return AppScaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: _isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: TextStyle(color: AppColors.textColor(context)),
                      decoration: const InputDecoration(
                        hintText: "Search contacts...",
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim();
                        });
                      },
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Select Contact",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${contactsList.length} contacts",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.greyText(context),
                          ),
                        ),
                      ],
                    ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isSearching ? Icons.close : Icons.search,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_isSearching) {
                        _isSearching = false;
                        _searchQuery = "";
                        _searchController.clear();
                      } else {
                        _isSearching = true;
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                  tooltip: "Sync Contacts",
                  onPressed: () {
                    context.read<ContactsBloc>().add(const SyncContactsEvent());
                  },
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<ContactsBloc>().add(const SyncContactsEvent());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isSearching) ...[
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.15),
                          child: const Icon(
                            Icons.group_add,
                            color: AppColors.primary,
                          ),
                        ),
                        title: const Text(
                          "New group",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.15),
                          child: const Icon(
                            Icons.person_add,
                            color: AppColors.primary,
                          ),
                        ),
                        title: const Text(
                          "New contact",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.qr_code_scanner,
                          color: AppColors.primary,
                        ),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Text(
                          "Contacts on ConVo",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.greyText(context),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],

                    if (state is ContactsLoading && contactsList.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else if (state is ContactsError && contactsList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<ContactsBloc>().add(
                                    const SyncContactsEvent(),
                                  );
                                },
                                child: const Text("Retry Sync"),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (filteredContacts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Text(
                            "No contacts found",
                            style: TextStyle(
                              color: AppColors.greyText(context),
                            ),
                          ),
                        ),
                      )
                    else
                      ...filteredContacts.map((contact) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primary,
                                backgroundImage: contact.profileImage.isNotEmpty
                                    ? NetworkImage(ApiConfig.sanitizeUrl(contact.profileImage))
                                    : null,
                                child: contact.profileImage.isEmpty
                                    ? Text(
                                        contact.name.isNotEmpty
                                            ? contact.name[0].toUpperCase()
                                            : "?",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      )
                                    : null,
                              ),
                              if (contact.online)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 13,
                                    height: 13,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark
                                            ? const Color(0xFF0F172A)
                                            : Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            contact.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.textColor(context),
                            ),
                          ),
                          subtitle: Text(
                            contact.about.isNotEmpty
                                ? contact.about
                                : contact.fullPhoneNumber,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.greyText(context),
                            ),
                          ),
                          trailing: contact.online
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "ONLINE",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () async {
                            final chatRepo = sl<ChatRepository>();
                            int? chatId = chatRepo.getCachedChatId(contact.id);

                            if (chatId == null || chatId <= 0) {
                              try {
                                chatId = await chatRepo.getOrCreateChatId(
                                  contact.id,
                                );
                              } catch (_) {}
                            }

                            if (!mounted) return;
                            Navigator.of(context).pushNamed(
                              RouteNames.chat,
                              arguments: {
                                "chatId": chatId ?? 0,
                                "targetUserId": contact.id,
                                "contactName": contact.name,
                                "contactPhone": contact.fullPhoneNumber,
                                "contactImage": contact.profileImage,
                                "contactAbout": contact.about,
                                "online": contact.online,
                              },
                            );
                          },
                        );
                      }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
