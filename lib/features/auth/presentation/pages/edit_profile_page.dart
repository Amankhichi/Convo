import 'package:convo/core/payload/user_payload.dart';
import 'package:convo/features/auth/presentation/bloc/bloc/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class EditProfilePage extends StatefulWidget {

  final int userId;
  final String name;
  final String phone;
  final String about;
  final String profile;

  const EditProfilePage({
    super.key,
    required this.userId,
    required this.name,
    required this.phone,
    required this.about,
    required this.profile,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController aboutController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.name);
    phoneController = TextEditingController(text: widget.phone);
    aboutController = TextEditingController(text: widget.about);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  // void updateProfile() {

  //   final payload = UserPayload(
  //     id: widget.userId,
  //     nickName: nameController.text.trim(),
  //     phone: phoneController.text.trim(),
  //     about: aboutController.text.trim(),
  //     profile: widget.profile,
  //     online: true,
  //   );

  //   context.read<UserBloc>().add(
  //     UpdateUserEvent(payload),
  //   );
  // }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xff0F172A),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff0F172A),
        centerTitle: true,
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

    body: BlocBuilder<LoginBloc, LoginState>(

  builder: (context, state) {

    // final isLoading = state is UpdateUserLoading;

    // // SUCCESS
    // if (state is UpdateUserSuccess) {

    //   WidgetsBinding.instance.addPostFrameCallback((_) {

    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text("Profile updated successfully"),
    //       ),
    //     );

    //     Navigator.pop(context, true);
    //   });
    // }

    // // ERROR
    // if (state is UpdateUserError) {

    //   WidgetsBinding.instance.addPostFrameCallback((_) {

    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(state.message),
    //       ),
    //     );
    //   });
    // }

    return SingleChildScrollView(

      padding: const EdgeInsets.all(20),

      child: Column(
        children: [

          const SizedBox(height: 20),

          Stack(
            children: [

              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white12,
                backgroundImage:
                    widget.profile.isNotEmpty
                        ? NetworkImage(widget.profile)
                        : null,
                child: widget.profile.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      )
                    : null,
              ),

              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          _buildTextField(
            controller: nameController,
            hint: "Enter name",
            label: "Name",
            icon: Icons.person,
          ),

          const SizedBox(height: 20),

          _buildTextField(
            controller: phoneController,
            hint: "Enter phone",
            label: "Phone",
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 20),

          _buildTextField(
            controller: aboutController,
            hint: "Write about yourself",
            label: "About",
            icon: Icons.info,
            maxLines: 4,
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 55,

            child: ElevatedButton(

              onPressed:(){},
                  // isLoading
                  //     ? null
                  //     : updateProfile,

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),

              child: isLoading

                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )

                  : const Text(
                      "Save Changes",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: Icon(icon, color: Colors.white70),
            filled: true,
            fillColor: const Color(0xff1E293B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
