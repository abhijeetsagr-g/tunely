import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/logic/provider/history/history_cubit.dart';
import 'package:tunely/logic/provider/library/library_cubit.dart';
import 'package:tunely/logic/provider/library/library_state.dart';
import 'package:tunely/ui/home/home_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    context.read<LibraryCubit>().initialLoad().then((_) {
      if (!mounted) return;
      context.read<HistoryCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LibraryCubit, LibraryState>(
        listenWhen: (prev, curr) => prev.isLoading && !curr.isLoading,
        listener: (context, state) {
          if (state.errorMessage.isNotEmpty) {
            // TODO: SHOW SNACKBAR
            return;
          }
          // TODO: PUSH IN SPLASH SCREEN
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeView()),
          );
        },
        child: const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
