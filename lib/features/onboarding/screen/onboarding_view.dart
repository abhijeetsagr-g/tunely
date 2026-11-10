import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_const.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/onboarding/model/onboarding_page_data.dart';
import 'package:tunely/features/onboarding/repository/onboarding_repository.dart';
import 'package:tunely/features/onboarding/widgets/onboarding_page_content.dart';
import 'package:tunely/features/onboarding/widgets/page_indicator.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _pages = [
    OnboardingPageData(
      imageAsset: AppConst.primaryIcon,
      title: 'Welcome to Tunely',
      subtitle: 'Your music. Offline. Always.',
      body: '',
    ),
    OnboardingPageData(
      icon: Icons.folder_open_rounded,
      title: 'Your Library',
      subtitle: 'Your Decision',
      body: 'Tunely reads the music stored on this device',
      isPermission: true,
    ),
    OnboardingPageData(
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

  int get _permissionIndex => _pages.indexWhere((p) => p.isPermission);
  void _onPrimaryPressed() {
    if (!_isLast) {
      _goTo(_currentPage + 1);
    } else if (!_permissionGranted) {
      _goTo(_permissionIndex); // send them back instead of a dead button
    } else {
      _finish();
    }
  }

  // Replace build()
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final page = _controller.hasClients
                        ? (_controller.page ?? _currentPage.toDouble())
                        : _currentPage.toDouble();
                    final delta = (page - index).clamp(-1.0, 1.0);
                    return Opacity(
                      opacity: 1 - delta.abs() * 0.6,
                      child: Transform.translate(
                        offset: Offset(delta * -48, 0), // parallax
                        child: child,
                      ),
                    );
                  },
                  child: OnboardingPageContent(
                    page: _pages[index],
                    requestingPermission: _requestingPermission,
                    permissionGranted: _permissionGranted,
                    onGrantPermission: _grantPermission,
                  ),
                ),
              ),
            ),
            OnboardingPageIndicator(
              pageCount: _pages.length,
              currentPage: _currentPage,
              onDotTap: _goTo,
            ),
            _BottomBar(
              label: !_isLast
                  ? 'Next'
                  : (_permissionGranted ? 'Get Started' : 'Allow music access'),
              onBack: _currentPage > 0 ? () => _goTo(_currentPage - 1) : null,
              onPrimary: _onPrimaryPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.label,
    required this.onBack,
    required this.onPrimary,
  });

  final String label;
  final VoidCallback? onBack;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Row(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: onBack == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IconButton.filledTonal(
                      onPressed: onBack,
                      iconSize: 24,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(56, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
          ),
          Expanded(
            child: FilledButton(
              onPressed: onPrimary,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: scheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(label, key: ValueKey(label)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
