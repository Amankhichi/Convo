import 'package:convo/app/router/route_names.dart';
import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/core/constants/storage_keys.dart';
import 'package:convo/core/storage/local_storage.dart';
import 'package:convo/core/widgets/app_scaffold.dart';
import 'package:convo/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:convo/features/authentication/presentation/bloc/auth_event.dart';
import 'package:convo/features/authentication/presentation/bloc/auth_state.dart';
import 'package:convo/injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<AuthBloc>().add(LogoutEvent());
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text(
          "Delete Account",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to permanently delete your account? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<AuthBloc>().add(DeleteAccountEvent());
            },
            child: const Text("Delete Account"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localStorage = sl<LocalStorage>();
    final name = localStorage.getString(StorageKeys.name) ?? "ConVo User";
    final phone = localStorage.getString(StorageKeys.phone) ?? "Not available";
    final about =
        localStorage.getString(StorageKeys.about) ??
        "Hey there! I am using ConVo.";

    final image = localStorage.getString(StorageKeys.profileImage) ?? "";

    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LoggedOutState) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(RouteNames.login, (route) => false);
          } else if (state is AccountDeletedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Account deleted successfully")),
            );
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(RouteNames.login, (route) => false);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return AppScaffold(
            appBar: AppBar(title: const Text("Profile")),
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary,
                        backgroundImage: image.isNotEmpty
                            ? NetworkImage(image)
                            : null,
                        child: image.isEmpty
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : "?",
                                style: const TextStyle(
                                  fontSize: 44,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        phone,
                        style: TextStyle(color: AppColors.greyText(context)),
                      ),
                      const SizedBox(height: 24),
                      ListTile(
                        leading: const Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                        ),
                        title: const Text("About"),
                        subtitle: Text(about),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.lock_outline,
                          color: AppColors.primary,
                        ),
                        title: const Text("Privacy"),
                        subtitle: const Text("End-to-end encrypted"),
                      ),
                      const SizedBox(height: 32),

                      /// Logout Button
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: AppColors.primary,
                        ),
                        title: const Text(
                          "Logout",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: isLoading
                            ? null
                            : () => _showLogoutConfirmation(context),
                      ),

                      const Divider(),

                      /// Delete Account Button
                      ListTile(
                        leading: const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                        title: const Text(
                          "Delete Account",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.red,
                        ),
                        onTap: isLoading
                            ? null
                            : () => _showDeleteAccountConfirmation(context),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
