import 'package:flutter_bloc/flutter_bloc.dart';

import '../main.dart';

class MyAppObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (bloc is Cubit) logger.d(change);
  }

  // @override
  // void onTransition(Bloc bloc, Transition transition) {
  //   super.onTransition(bloc, transition);
  //   logger.d(change);
  // }
}
