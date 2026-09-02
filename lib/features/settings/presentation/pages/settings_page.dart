import 'package:convo/app/router/route_names.dart';
import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/core/widgets/app_scaffold.dart';
import 'package:convo/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:convo/features/authentication/presentation/bloc/auth_event.dart';
import 'package:convo/features/authentication/presentation/bloc/auth_state.dart';
import 'package:convo/injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LoggedOutState) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              RouteNames.login,
              (route) => false,
            );
          } else if (state is AccountDeletedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Account deleted successfully")),
            );
            Navigator.of(context).pushNamedAndRemoveUntil(
              RouteNames.login,
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return AppScaffold(
            appBar: AppBar(title: const Text("Settings")),
            body: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline, color: AppColors.primary),
                      title: const Text("Account & Profile"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.of(context).pushNamed(RouteNames.profile),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.notifications_none, color: AppColors.primary),
                      title: const Text("Notifications"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.security, color: AppColors.primary),
                      title: const Text("Privacy & Security"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {},
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: AppColors.primary),
                      title: const Text(
                        "Logout",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onTap: isLoading ? null : () => _showLogoutConfirmation(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: Colors.red),
                      title: const Text(
                        "Delete Account",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      onTap: isLoading ? null : () => _showDeleteAccountConfirmation(context),
                    ),
                  ],
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
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
