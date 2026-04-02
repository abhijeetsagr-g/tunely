import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/features/onboarding/widget/get_started.dart';
import 'package:tunely/features/onboarding/widget/permission_view.dart';
import 'package:tunely/features/onboarding/widget/theme_view.dart';
import 'package:tunely/features/theme/theme_cubit.dart';

enum OnboardingStep { start, permissions, theme }

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  OnboardingStep step = OnboardingStep.start;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildStep(),
      ),
    );
  }

  Widget _buildStep() {
    switch (step) {
      case OnboardingStep.start:
        return GetStarted(
          key: const ValueKey('start'),
          onTap: () {
            setState(() => step = OnboardingStep.permissions);
          },
        );

      case OnboardingStep.permissions:
        return PermissionView(
          key: const ValueKey('permissions'),
          onAllGranted: () {
            setState(() => step = OnboardingStep.theme);
          },
        );

      case OnboardingStep.theme:
        return ThemeBoardingView(
          key: const ValueKey('theme'),
          onDone: () {
            context.read<ThemeCubit>().completeOnboarding();
            Navigator.pushReplacementNamed(context, AppRoute.splash);
          },
        );
    }
  }
}
