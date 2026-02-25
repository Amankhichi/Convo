import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/core/custom/custom_text.dart';
import 'package:convo/core/enum/status.dart';
import 'package:convo/features/auth/presentation/bloc/bloc/login_bloc.dart';
import 'package:convo/features/chat/presentation/pages/chat_page.dart';
import 'package:convo/features/home/presentation/bloc/home/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class HomeChatListWidget extends StatelessWidget {
  const HomeChatListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  return state.homeChatsStatus == Status.loading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: state.homePageChats.length,
                          itemBuilder: (context, index) {
                            final chat = state.homePageChats[index];
                            final profile = context
                                .read<LoginBloc>()
                                .state
                                .profile!;
                            final bool isMe = profile.id == chat.senderId;
                            final user = isMe ? chat.receiver : chat.sender;
                            return ListTile(
                              onTap: () {
                                Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          ChatPage(user:user),
                      transitionsBuilder: (_, a, __, c) => SlideTransition(
                        position: Tween(
                          begin: const Offset(-1, 0),
                          end: Offset.zero,
                        ).animate(a),
                        child: c,
                      ),
                    ),
                  );
                              },
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                radius: 35,
                                child: ClipOval(
                                  child: Lottie.asset(user.lotti),
                                ),
                              ),
                              title: Text(user.name,style: TextStyle(fontWeight: FontWeight.w600,color: AppColors.textColor(context),)),
                              subtitle: Text(chat.message,style: TextStyle(color: Colors.grey),),
                              trailing: CustomText(
                                text: DateFormat(
                                  'hh:mm a',
                                ).format(chat.createdAt),
                                bold: FontWeight.w800,
                                size: 12,
                              ),
                            );
                          },
                        );
                },
              );
           
  }
}