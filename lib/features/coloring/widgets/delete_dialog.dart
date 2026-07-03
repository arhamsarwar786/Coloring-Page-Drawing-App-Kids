import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/home/components/Kids_game_home_screen.dart';
import 'package:play_craft_kids/shared/components/sticker_icon_button.dart';

class DeleteDialog extends StatelessWidget {
  final VoidCallback onConfirm; // Delete ka action yahan se aayega
  final VoidCallback ontap;
  const DeleteDialog({super.key, required this.onConfirm, required this.ontap});

  @override
  Widget build(BuildContext context) {
    // final provider = widget.provider;

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Dialog ke andar click band na ho
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 300,
                  height: 220,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xff6EC6D0),
                    borderRadius: BorderRadius.circular(36.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1E4CE),
                      borderRadius: BorderRadius.circular(26.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DialogHeaderBanner(text: "DELETE ?".toUpperCase()),

                        SizedBox(height: 10),
                        const Text(
                          "Do you really want to Delete ?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Regular",
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),

                        // const Text(
                        //   "DELETE ?",
                        //   style: TextStyle(
                        //     fontSize: 24,
                        //     fontFamily: "Regular",
                        //     fontWeight: FontWeight.bold,
                        //     color: Color(0xFF7B3FE4),
                        //   ),
                        // ),

                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // No Button
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff3b9499),
                              ),
                              child: const Text(
                                "NO",
                              ),
                            ),
                            // Yes Button
                            ElevatedButton(
                              onPressed: () {
                                ontap();
                                // onConfirm(); // Delete logic trigger
                                Navigator.pop(context); // Dialog close
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: const Text("YES"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Close Button
                Positioned(
                  top: -10,
                  right: -10,
                  child: StickerIconButton(
                    icon: Icons.close,
                    assetName: 'assets/images/close.png',
                    size: 48,
                    backgroundColor: Colors.white,
                    iconColor: Colors.red,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UndoDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const UndoDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 300,
                  height: 220,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xff6EC6D0),
                    borderRadius: BorderRadius.circular(36.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1E4CE),
                      borderRadius: BorderRadius.circular(26.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DialogHeaderBanner(text: "UNDO ?".toUpperCase()),

                        SizedBox(height: 10),
                        const Text(
                          "Do you really want to Undo?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Regular",
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),

                        // const Text(
                        //   "UNDO?", // Yahan Undo likha hai
                        //   style: TextStyle(
                        //     fontSize: 24,
                        //     fontWeight: FontWeight.bold,
                        //     color: Color(0xFF7B3FE4),
                        //   ),
                        // ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("NO"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff3b9499),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                onConfirm(); // Yahan Undo ka logic chalega
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: const Text("YES"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Close button yahan pehle ki tarah...
                Positioned(
                  top: -10,
                  right: -10,
                  child: StickerIconButton(
                    icon: Icons.close,
                    assetName: 'assets/images/close.png',
                    size: 48,
                    backgroundColor: Colors.white,
                    iconColor: Colors.red,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BackNavigationDialog extends StatelessWidget {
  final BuildContext screenContext;

  const BackNavigationDialog({super.key, required this.screenContext});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context), // Bahar click karne par band
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Dialog ke andar click karne par band na ho
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 300,
                  height: 220,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xff6EC6D0),
                    borderRadius: BorderRadius.circular(36.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1E4CE),
                      borderRadius: BorderRadius.circular(26.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DialogHeaderBanner(text: "GO BACK?".toUpperCase()),
                        SizedBox(height: 10),
                        const Text(
                          "Do you really want to go back?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Regular",
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),

                        // const Text(
                        //   "GO BACK?",
                        //   style: TextStyle(
                        //     fontSize: 24,
                        //     fontFamily: "Regular",
                        //     fontWeight: FontWeight.bold,
                        //     color: Color(0xFF7B3FE4),
                        //   ),
                        // ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // NO Button
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("NO"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff3b9499),
                              ),
                            ),
                            // YES Button
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Dialog band
                                Navigator.pop(screenContext); // Screen back
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: const Text("YES"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Close button (UndoDialog jaisa)
                Positioned(
                  top: -10,
                  right: -10,
                  child: StickerIconButton(
                    icon: Icons.close,
                    assetName: 'assets/images/close.png',
                    size: 48,
                    backgroundColor: Colors.white,
                    iconColor: Colors.red,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DeleteAccountDialog extends StatelessWidget {
  final BuildContext screenContext;
  final Future<void> Function() onDelete;

  const DeleteAccountDialog({
    super.key,
    required this.screenContext,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 300,
                  height: 240,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xff6EC6D0),
                    borderRadius: BorderRadius.circular(36.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1E4CE),
                      borderRadius: BorderRadius.circular(26.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DialogHeaderBanner(text: "DELETE ?".toUpperCase()),

                        SizedBox(height: 10),
                        const Text(
                          "Do you really want to Delete Account?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Regular",
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),

                        // const Text(
                        //   "DELETE ACCOUNT?",
                        //   textAlign: TextAlign.center,
                        //   style: TextStyle(
                        //     fontSize: 22,
                        //     fontFamily: "Regular",
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.red,
                        //   ),
                        // ),
                        // const SizedBox(height: 10),
                        // const Text(
                        //   "This action cannot be undone. Are you sure to Delete Account ?",
                        //   textAlign: TextAlign.center,
                        //   style: TextStyle(
                        //     fontSize: 12,
                        //     fontFamily: "Regular",
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.black,
                        //   ),
                        // ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // CANCEL
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff3b9499),
                              ),
                            ),

                            // DELETE
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context); // close dialog
                                await onDelete(); // delete account
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Close button
                Positioned(
                  top: -10,
                  right: -10,
                  child: StickerIconButton(
                    icon: Icons.close,
                    assetName: 'assets/images/close.png',
                    size: 48,
                    backgroundColor: Colors.white,
                    iconColor: Colors.red,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LogoutDialog extends StatelessWidget {
  final BuildContext screenContext;
  final Future<void> Function() onLogout;

  const LogoutDialog({
    super.key,
    required this.screenContext,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 300,
                  height: 300,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xff6EC6D0),
                    borderRadius: BorderRadius.circular(36.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1E4CE),
                      borderRadius: BorderRadius.circular(26.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DialogHeaderBanner(text: "LOG OUT?".toUpperCase()),
                        // const Text(
                        //   "LOGOUT?",
                        //   textAlign: TextAlign.center,
                        //   style: TextStyle(
                        //     fontSize: 22,
                        //     fontFamily: "Regular",
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.red,
                        //   ),
                        // ),
                        SizedBox(height: 10),
                        const Text(
                          "Do you really want to log out?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Regular",
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // CANCEL
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff3b9499),
                              ),
                            ),

                            // LOGOUT
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context); // close dialog
                                await onLogout(); // perform logout
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text("Log out"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Close button
                Positioned(
                  top: -10,
                  right: -10,
                  child: StickerIconButton(
                    icon: Icons.close,
                    assetName: 'assets/images/close.png',
                    size: 48,
                    backgroundColor: Colors.white,
                    iconColor: Colors.red,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
