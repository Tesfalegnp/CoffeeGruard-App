import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState
    extends State<UserManagementScreen> {

  String selectedRole = "all";

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AdminProvider>(context, listen: false)
            .loadUsers());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context);

    final users = selectedRole == "all"
        ? provider.users
        : provider.users
            .where((u) => u["role"] == selectedRole)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Management"),
        backgroundColor: Colors.green,
      ),

      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [

                // ===== FILTER =====
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: DropdownButton<String>(
                    value: selectedRole,
                    items: const [
                      DropdownMenuItem(value: "all", child: Text("All")),
                      DropdownMenuItem(value: "farmer", child: Text("Farmer")),
                      DropdownMenuItem(value: "expert", child: Text("Expert")),
                      DropdownMenuItem(value: "admin", child: Text("Admin")),
                    ],
                    onChanged: (v) {
                      setState(() => selectedRole = v!);
                    },
                  ),
                ),

                // ===== LIST =====
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (_, i) {
                      final u = users[i];

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(u["role"][0].toUpperCase()),
                          ),
                          title: Text(u["email"] ?? ""),
                          subtitle: Text("Role: ${u["role"]}"),

                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == "toggle") {
                                await provider.toggleUserStatus(
                                    u["id"], u["is_active"] ?? true);
                              } else if (value == "delete") {
                                await provider.deleteUser(u["id"]);
                              } else {
                                await provider.changeRole(u["id"], value);
                              }
                            },
                            itemBuilder: (_) => [

                              const PopupMenuItem(
                                  value: "farmer", child: Text("Make Farmer")),
                              const PopupMenuItem(
                                  value: "expert", child: Text("Make Expert")),
                              const PopupMenuItem(
                                  value: "admin", child: Text("Make Admin")),

                              const PopupMenuDivider(),

                              PopupMenuItem(
                                  value: "toggle",
                                  child: Text(
                                      u["is_active"] == true
                                          ? "Deactivate"
                                          : "Activate")),

                              const PopupMenuItem(
                                  value: "delete",
                                  child: Text("Delete")),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}