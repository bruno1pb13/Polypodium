import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

/// One-time introduction shown on the first launch of the app.
///
/// Presents a short swipeable tour of the main features; once dismissed
/// (skipped or completed) it is never shown again.
class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  /// Whether the user tapped "turn on reminders" on the reminders page.
  /// Kept here (not in the page) so it survives swiping away and back.
  bool _remindersOptedIn = false;

  static const _pageCount = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(settingsRepositoryProvider).setIntroSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
  }

  void _next() {
    if (_currentPage == _pageCount - 1) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  /// Explicit opt-in: only here (and via the settings toggle) does the app
  /// ask the OS for notification permissions — never at startup.
  Future<void> _enableReminders() async {
    final granted = await NotificationService.requestPermissions();
    await ref.read(settingsRepositoryProvider).setNotificationsEnabled(true);
    if (!mounted) return;
    setState(() => _remindersOptedIn = granted);
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: ref.read(notificationTimeNotifierProvider),
    );
    if (picked != null) {
      await ref.read(notificationTimeNotifierProvider.notifier).setTime(picked);
    }
  }

  List<_IntroPageData> _pages(BuildContext context) => [
    _IntroPageData(
      icon: null, // welcome page shows the logo instead
      title: context.l10n.introWelcomeTitle,
      body: context.l10n.introWelcomeBody,
    ),
    _IntroPageData(
      icon: Icons.eco,
      title: context.l10n.introPlantsTitle,
      body: context.l10n.introPlantsBody,
    ),
    _IntroPageData(
      icon: Icons.water_drop,
      title: context.l10n.introRemindersTitle,
      body: context.l10n.introRemindersBody,
      child: _ReminderSetup(
        optedIn: _remindersOptedIn,
        onEnable: _enableReminders,
        onPickTime: _pickReminderTime,
      ),
    ),
    _IntroPageData(
      icon: Icons.cloud_sync,
      title: context.l10n.introSyncTitle,
      body: context.l10n.introSyncBody,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = _pages(context);
    final isLastPage = _currentPage == _pageCount - 1;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Gradient overlay for better readability - darkened at top
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: TextButton(
                      onPressed: _finish,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                      ),
                      child: Text(context.l10n.introSkip),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (_, index) => _IntroPage(data: pages[index]),
                  ),
                ),
                _PageDots(count: _pageCount, current: _currentPage),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: FilledButton(
                        onPressed: _next,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          isLastPage
                              ? context.l10n.introGetStarted
                              : context.l10n.next,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroPageData {
  const _IntroPageData({
    required this.icon,
    required this.title,
    required this.body,
    this.child,
  });

  final IconData? icon;
  final String title;
  final String body;

  /// Optional interactive content shown below the body inside the card.
  final Widget? child;
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.data});

  final _IntroPageData data;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 36,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (data.icon == null)
                      Image.asset(
                        'assets/images/logo.png',
                        width: 96,
                        height: 96,
                      )
                    else
                      Icon(data.icon, size: 72, color: Colors.white),
                    const SizedBox(height: 28),
                    Text(
                      data.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'CormorantGaramond',
                        fontWeight: FontWeight.w600,
                        fontSize: 30,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      data.body,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.white70,
                      ),
                    ),
                    if (data.child != null) ...[
                      const SizedBox(height: 24),
                      data.child!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Opt-in block on the reminders page: pick the reminder time and, if the
/// user wants reminders, request the OS notification permission — the app
/// never asks for it unprompted.
class _ReminderSetup extends ConsumerWidget {
  const _ReminderSetup({
    required this.optedIn,
    required this.onEnable,
    required this.onPickTime,
  });

  final bool optedIn;
  final Future<void> Function() onEnable;
  final Future<void> Function() onPickTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = ref.watch(notificationTimeNotifierProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.introRemindersTimeLabel,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: onPickTime,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
              ),
              icon: const Icon(Icons.schedule, size: 18),
              label: Text(
                time.format(context),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: optedIn
              ? FilledButton.tonalIcon(
                  onPressed: null,
                  icon: const Icon(Icons.check),
                  label: Text(context.l10n.introRemindersEnabled),
                )
              : FilledButton.icon(
                  onPressed: onEnable,
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: Text(context.l10n.introRemindersEnable),
                ),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.introRemindersLaterNote,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == current ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == current ? Colors.white : Colors.white38,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
