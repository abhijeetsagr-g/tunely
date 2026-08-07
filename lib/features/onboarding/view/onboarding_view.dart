import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_const.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/onboarding/repository/onboarding_repository.dart';
import 'package:tunely/shared/widget/theme_picker.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.body,
    this.isPermission = false,
    this.isTheme = false,
    this.imageAsset,
    this.icon,
  });

  final IconData? icon;
  final String? imageAsset;
  final String title;
  final String subtitle;
  final String body;
  final bool isPermission;
  final bool isTheme;
}

class _OnboardingViewState extends State<OnboardingView> {
  static const _pages = [
    _OnboardingPageData(
      imageAsset: AppConst.primaryIcon,
      title: 'Welcome to Tunely',
      subtitle: 'Your music. Offline. Always.',
      body: '',
    ),
    _OnboardingPageData(
      icon: Icons.folder_open_rounded,
      title: "Your Library",
      subtitle: 'Your Decision',
      body: 'Tunely reads the music stored on this device',
      isPermission: true,
    ),
    _OnboardingPageData(
      icon: Icons.contrast_rounded,
      title: 'Your look',
      subtitle: 'Light, dark, or system',
      body: '',
      isTheme: true,
    ),
  ];

  final PageController _controller = PageController();
  int _currentPage = 0;
  bool _requestingPermission = false;
  bool _permissionGranted = false;

  bool get _isLast => _currentPage == _pages.length - 1;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final granted = await context.read<LibraryCubit>().hasPermission();
    if (!mounted) return;
    setState(() => _permissionGranted = granted);
  }

  Future<void> _grantPermission() async {
    setState(() => _requestingPermission = true);
    final granted = await context.read<LibraryCubit>().requestPermission();
    if (!mounted) return;
    setState(() {
      _requestingPermission = false;
      _permissionGranted = granted;
    });
  }

  Future<void> _finish() async {
    if (!_permissionGranted) return;
    await context.read<OnboardingRepository>().setCompleted();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoute.splash);
  }

  void _goTo(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return _PageContent(
                    page: _pages[index],
                    requestingPermission: _requestingPermission,
                    permissionGranted: _permissionGranted,
                    onGrantPermission: _grantPermission,
                  );
                },
              ),
            ),
            _buildIndicator(scheme),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_pages.length, (index) {
          final selected = index == _currentPage;
          return GestureDetector(
            onTap: () => _goTo(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: selected ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: selected
                    ? scheme.primary
                    : scheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        children: [
          if (_currentPage > 0)
            IconButton(
              onPressed: () => _goTo(_currentPage - 1),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          Expanded(
            child: FilledButton(
              onPressed: _isLast
                  ? (_permissionGranted ? _finish : null)
                  : () => _goTo(_currentPage + 1),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(_isLast ? 'Get Started' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({
    required this.page,
    required this.requestingPermission,
    required this.permissionGranted,
    required this.onGrantPermission,
  });

  final _OnboardingPageData page;
  final bool requestingPermission;
  final bool permissionGranted;
  final VoidCallback onGrantPermission;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scheme.primary.withValues(alpha: 0.35),
                          scheme.primary.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(
                        color: scheme.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: page.imageAsset != null
                        ? Padding(
                            padding: const EdgeInsets.all(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                page.imageAsset!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Icon(page.icon, size: 56, color: scheme.primary),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    page.title,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    page.subtitle,
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    page.body,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  if (page.isPermission) ...[
                    const SizedBox(height: 40),
                    _PermissionCard(
                      requesting: requestingPermission,
                      granted: permissionGranted,
                      onGrant: onGrantPermission,
                    ),
                  ],
                  if (page.isTheme) ...[
                    const SizedBox(height: 40),
                    const ThemePicker(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.requesting,
    required this.granted,
    required this.onGrant,
  });

  final bool requesting;
  final bool granted;
  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (granted) ...[
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF4CAF50),
                size: 44,
              ),
              const SizedBox(height: 12),
              Text(
                'Access granted',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              FilledButton.tonalIcon(
                onPressed: requesting ? null : onGrant,
                icon: requesting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.folder_open_rounded),
                label: Text(
                  requesting ? 'Requesting…' : 'Grant access to music',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Required to see your library',
                style: textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
