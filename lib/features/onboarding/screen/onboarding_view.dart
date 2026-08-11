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
                itemBuilder: (context, index) => OnboardingPageContent(
                  page: _pages[index],
                  requestingPermission: _requestingPermission,
                  permissionGranted: _permissionGranted,
                  onGrantPermission: _grantPermission,
                ),
              ),
            ),
            OnboardingPageIndicator(
              pageCount: _pages.length,
              currentPage: _currentPage,
              onDotTap: _goTo,
            ),
            _BottomBar(
              isLast: _isLast,
              canFinish: _permissionGranted,
              onBack: _currentPage > 0 ? () => _goTo(_currentPage - 1) : null,
              onNext: () => _goTo(_currentPage + 1),
              onFinish: _finish,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isLast,
    required this.canFinish,
    required this.onBack,
    required this.onNext,
    required this.onFinish,
  });

  final bool isLast;
  final bool canFinish;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          Expanded(
            child: FilledButton(
              onPressed: isLast ? (canFinish ? onFinish : null) : onNext,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(isLast ? 'Get Started' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}
