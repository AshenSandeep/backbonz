import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../components/timer_display.dart';
import '../../components/session_card.dart';
import '../../components/primary_button.dart';
import '../../viewModels/auth_viewmodel.dart';
import '../../viewModels/timer_viewmodel.dart';
import '../../services/session_service.dart';
import '../../models/session_model.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final sessionService = SessionService();
    final AuthViewModel authViewModel = Get.find<AuthViewModel>();
    final TimerViewModel timerViewModel = Get.find<TimerViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BackBonz',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () async {
                      timerViewModel.reset();
                      await authViewModel.signOut();
                      Get.offAll(() => const LoginScreen());
                    },
                    icon: const Icon(
                      Icons.logout,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // Timer Display
                    Obx(() => TimerDisplay(
                      elapsed: timerViewModel.elapsed,
                      status: timerViewModel.status,
                    )),

                    const SizedBox(height: 40),

                    // Timer Controls
                    _TimerControls(timer: timerViewModel),

                    const SizedBox(height: 40),

                    // Today's Sessions
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Today's Sessions",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (user != null)
                      StreamBuilder<List<SessionModel>>(
                        stream: sessionService.getTodaysSessions(user.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            );
                          }

                          final sessions = snapshot.data ?? [];

                          if (sessions.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      color: AppColors.textSecondary,
                                      size: 40,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'No sessions yet today',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Start the timer to begin tracking',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sessions.length,
                            itemBuilder: (context, index) {
                              return SessionCard(
                                session: sessions[index],
                                index: sessions.length - index,
                              );
                            },
                          );
                        },
                      ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerControls extends StatelessWidget {
  final TimerViewModel timer;

  const _TimerControls({required this.timer});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      print("Start Session is pressed");
      if (timer.isIdle) {
        return PrimaryButton(
          label: '▶  Start Session',
          onPressed: timer.start,
          color: AppColors.accent,
        );
      }

      if (timer.isRunning) {
        return Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: '⏸  Pause',
                onPressed: timer.pause,
                color: AppColors.timerPaused,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                label: '⏹  Stop',
                onPressed: () async => await timer.stop(),
                color: AppColors.error,
              ),
            ),
          ],
        );
      }

      // Paused state
      return Row(
        children: [
          Expanded(
            child: PrimaryButton(
              label: '▶  Resume',
              onPressed: timer.start,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              label: '⏹  Stop',
              onPressed: () async => await timer.stop(),
              color: AppColors.error,
            ),
          ),
        ],
      );
    });
  }
}