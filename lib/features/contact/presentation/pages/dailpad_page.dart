import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:convo/const.dart/app_colors.dart';
import 'package:convo/const.dart/slide_page_route.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:convo/features/chat/presentation/pages/voice_call_page.dart';
import 'package:convo/features/contact/presentation/bloc/bloc/contact_bloc.dart';

class DialpadPage extends StatefulWidget {
  const DialpadPage({super.key});

  @override
  State<DialpadPage> createState() => _DialpadPageState();
}

class _DialpadPageState extends State<DialpadPage> {
  String enteredNumber = "";

  void _onKeyPress(String value) {
    setState(() {
      enteredNumber += value;
    });
  }

  void _onBackspace() {
    if (enteredNumber.isNotEmpty) {
      setState(() {
        enteredNumber = enteredNumber.substring(0, enteredNumber.length - 1);
      });
    }
  }

  void _initiateCall(UserModel targetUser) {
    Navigator.push(
      context,
      SlidePageRoute(
        page: VoiceCallPage(user: targetUser),
        beginOffset: const Offset(0, 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF1A1515,
      ), // Matches the deep dark background from your clip
      body: SafeArea(
        child: BlocBuilder<ContactBloc, ContactState>(
          builder: (context, state) {
            // Filter list matching entered numbers reactively
            final matchedContacts = state.contacts.where((user) {
              if (enteredNumber.isEmpty)
                return true; // Show recent/all when empty
              final clearPhone = (user.phone ?? "").replaceAll(
                RegExp(r'\D'),
                '',
              );
              return clearPhone.contains(enteredNumber) ||
                  user.name.toLowerCase().contains(enteredNumber.toLowerCase());
            }).toList();

            return Column(
              children: [
                // 1. DYNAMIC MATCHED CONTACTS LIST (Top Area)
                Expanded(
                  child: matchedContacts.isEmpty
                      ? Center(
                          child: Text(
                            enteredNumber.isEmpty
                                ? "No logs"
                                : "No matching contacts",
                            style: const TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: matchedContacts.length,
                          itemBuilder: (context, index) {
                            final user = matchedContacts[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 4,
                              ),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.8,
                                ),
                                child: Text(
                                  user.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                user.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                user.phone,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.phone_outlined,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                onPressed: () => _initiateCall(user),
                              ),
                              onTap: () => _initiateCall(user),
                            );
                          },
                        ),
                ),

                // 2. INPUT DISPLAY & BACKSPACE BAR
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Options Menu dot placeholder seen on the left side
                      IconButton(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white54,
                        ),
                        onPressed: () {},
                      ),
                      // Main input string
                      Expanded(
                        child: Text(
                          enteredNumber,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Backspace button visible only when text exists
                      Opacity(
                        opacity: enteredNumber.isNotEmpty ? 1.0 : 0.0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.backspace_outlined,
                            color: Colors.white70,
                          ),
                          onPressed: enteredNumber.isNotEmpty
                              ? _onBackspace
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. DIALPAD BOARD CONTAINER
                Container(
                  color: const Color(
                    0xFF241E1E,
                  ), // Slightly lighter container backdrop from the video clip
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildKey("1", "⌕"),
                          _buildKey("2", "ABC"),
                          _buildKey("3", "DEF"),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildKey("4", "GHI"),
                          _buildKey("5", "JKL"),
                          _buildKey("6", "MNO"),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildKey("7", "PQRS"),
                          _buildKey("8", "TUV"),
                          _buildKey("9", "WXYZ"),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildKey("*", ""),
                          _buildKey("0", "+"),
                          _buildKey("#", ""),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 4. CALL BUTTON ROW
                      GestureDetector(
                        onTap: () {
                          if (enteredNumber.isNotEmpty) {
                            // Look up if number belongs to an existing user layout config
                            UserModel targetUser;
                            try {
                              targetUser = state.contacts.firstWhere(
                                (u) => (u.phone )
                                    .replaceAll(RegExp(r'\D'), '')
                                    .contains(enteredNumber),
                              );
                            } catch (_) {
                              targetUser = UserModel(
                                id: 1,
                                name: enteredNumber,
                                phone: enteredNumber,
                                profile: "",
                                about: "Unknown Dialed Number", nickname: 'user', online: false,
                              );
                            }
                            _initiateCall(targetUser);
                          }
                        },
                        child: Container(
                          width: 140,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4CAF50,
                            ), // True Android Green call action pill shape
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.call, color: Colors.white, size: 22),
                              SizedBox(width: 8),
                              Text(
                                "Call",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Helper template for standard device oval keys
  Widget _buildKey(String primaryDigit, String alphaLabel) {
    return InkWell(
      onTap: () => _onKeyPress(primaryDigit),
      onLongPress: () {
        if (primaryDigit == "0") _onKeyPress("+");
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 58,
        width: 100, // Oval width ratio matching your video clip layout
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              primaryDigit,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (alphaLabel.isNotEmpty)
              Text(
                alphaLabel,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white38,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
