import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/links/external_links.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../weather/presentation/providers/weather_providers.dart';
import '../../../../core/theme/glass_colors.dart';

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

  /// Same for "turn on the weather analysis" on the weather page.
  bool _weatherOptedIn = false;

  static const _pageCount = 6;

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

  void _back() => _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );

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

  /// The weather page itself says what is sent and to whom, so tapping
  /// the button is the informed opt-in (the settings switch asks first).
  Future<void> _enableWeather() async {
    await ref.read(settingsRepositoryProvider).setLocalWeatherEnabled(true);
    ref.invalidate(localWeatherEnabledNotifierProvider);
    if (!mounted) return;
    setState(() => _weatherOptedIn = true);
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
      icon: Icons.auto_stories,
      title: context.l10n.introDiaryTitle,
      body: context.l10n.introDiaryBody,
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
      icon: Icons.wb_cloudy,
      title: context.l10n.introWeatherTitle,
      body: context.l10n.introWeatherBody,
      child: _WeatherSetup(
        optedIn: _weatherOptedIn,
        onEnable: _enableWeather,
      ),
    ),
    _IntroPageData(
      icon: Icons.cloud_sync,
      title: context.l10n.introSyncTitle,
      body: context.l10n.introSyncBody,
      child: const _SyncOptions(),
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
              excludeFromSemantics: true,
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
                    context.glass.scrim(0.5),
                    Colors.transparent,
                    context.glass.scrim(0.4),
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
                        foregroundColor: context.glass.fgMuted,
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
                      child: Row(
                        children: [
                          if (_currentPage > 0) ...[
                            TextButton(
                              onPressed: _back,
                              style: TextButton.styleFrom(
                                foregroundColor: context.glass.fg,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 20),
                              ),
                              child: Text(context.l10n.back),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: FilledButton(
                              onPressed: _next,
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                isLastPage
                                    ? context.l10n.introGetStarted
                                    : context.l10n.next,
                              ),
                            ),
                          ),
                        ],
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
                  color: context.glass.glassFill,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: context.glass.tint(0.1),
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
                        excludeFromSemantics: true,
                      )
                    else
                      Icon(data.icon, size: 72, color: context.glass.fg),
                    const SizedBox(height: 28),
                    Text(
                      data.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'CormorantGaramond',
                        fontWeight: FontWeight.w600,
                        fontSize: 30,
                        letterSpacing: 0.5,
                        color: context.glass.fg,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      data.body,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: context.glass.fgMuted,
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
              style: TextStyle(color: context.glass.fgMuted, fontSize: 15),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: onPickTime,
              style: OutlinedButton.styleFrom(
                foregroundColor: context.glass.fg,
                side: BorderSide(color: context.glass.tint(0.38)),
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
          style: TextStyle(color: context.glass.fgFaint, fontSize: 12),
        ),
      ],
    );
  }
}

/// Opt-in block on the weather page: what turning it on sends to the
/// third-party service, and the button. Off unless the user taps it.
class _WeatherSetup extends StatelessWidget {
  const _WeatherSetup({required this.optedIn, required this.onEnable});

  final bool optedIn;
  final Future<void> Function() onEnable;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.glass.tint(0.24)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.privacy_tip_outlined,
                  size: 20, color: context.glass.fg),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.weatherThirdPartyTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.glass.fg,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.weatherThirdPartyBody,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: context.glass.fgMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: optedIn
              ? FilledButton.tonalIcon(
                  onPressed: null,
                  icon: const Icon(Icons.check),
                  label: Text(context.l10n.introWeatherEnabled),
                )
              : FilledButton.icon(
                  onPressed: onEnable,
                  icon: const Icon(Icons.wb_cloudy_outlined),
                  label: Text(context.l10n.introWeatherEnable),
                ),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.introWeatherLaterNote,
          textAlign: TextAlign.center,
          style: TextStyle(color: context.glass.fgFaint, fontSize: 12),
        ),
      ],
    );
  }
}

/// The two ways to keep the data on the sync page, the documentation for
/// the server one, and where the app runs.
class _SyncOptions extends StatelessWidget {
  const _SyncOptions();

  @override
  Widget build(BuildContext context) {
    Widget option(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: context.glass.fg),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: context.glass.fgMuted,
                  ),
                ),
              ),
            ],
          ),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        option(Icons.smartphone_outlined, context.l10n.introSyncOffline),
        option(Icons.cloud_sync_outlined, context.l10n.introSyncServer),
        OutlinedButton.icon(
          onPressed: () => openExternalLink(
              context, ExternalLinks.serverDocs(context.l10n.localeName)),
          style: OutlinedButton.styleFrom(
            foregroundColor: context.glass.fg,
            side: BorderSide(color: context.glass.tint(0.38)),
          ),
          icon: const Icon(Icons.menu_book_outlined, size: 18),
          label: Text(context.l10n.viewDocumentation),
        ),
        const SizedBox(height: 12),
        Text(
          '${context.l10n.introSyncLaterNote} ${context.l10n.introPlatforms}',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.glass.fgFaint, fontSize: 12),
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
              color: i == current ? context.glass.fg : context.glass.tint(0.38),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
