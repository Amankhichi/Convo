import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:convo/features/home/presentation/bloc/singup_bloc/singup_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SingupBloc, SingupState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Profile"),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 🔹 Avatar Section
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    ClipOval(
                      child: Container(
                        height: 120,
                        width: 120,
                        color: Colors.grey.shade200,
                        child: state.lotti.isNotEmpty
                            ? Lottie.asset(state.lotti, fit: BoxFit.contain)
                            : const Icon(Icons.person, size: 70),
                      ),
                    ),
                    CircleAvatar(
                      radius: 10,
                      backgroundColor:
                          state.online ? Colors.green : Colors.grey,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 🔹 Name
                Text(
                  state.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                // 🔹 About
                Text(
                  state.about.isEmpty ? "Hey there! I’m using ConVO." : state.about,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 24),

                // 🔹 Info Cards
                _infoTile(
                  icon: Icons.person_outline,
                  title: "Nickname",
                  value: state.nickName,
                ),

                _infoTile(
                  icon: Icons.phone,
                  title: "Phone",
                  value: state.phone,
                ),

                _infoTile(
                  icon: Icons.circle,
                  title: "Status",
                  value: state.online ? "Online" : "Offline",
                  valueColor:
                      state.online ? Colors.green : Colors.grey,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(
          value,
          style: TextStyle(color: valueColor),
        ),
      ),
    );
  }
}
