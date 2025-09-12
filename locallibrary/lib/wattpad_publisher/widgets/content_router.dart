import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/navigation_cubit.dart';

class ContentRouter extends StatelessWidget {
  const ContentRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationScreenCubit>(
      builder: (_, screen) => screen.get(),
    );
  }
}
