import 'package:bloc/bloc.dart';
import 'package:dbsync_app_new/services/services.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../main.dart';
import '../model/models.dart';

part 'send_name_state.dart';

class SendNameCubit extends Cubit<SendNameState> {
  SendNameCubit() : super(SendNameInitial());

  Future addName(text, _connectionStatus) async {
    try {
      emit(SendNameLoading());
      final addNameResponse =
          await SendNameService().addName(text, _connectionStatus);
      emit(SendNameSuccess(addNameResponse));
    } catch (e) {
      emit(SendNameFailed((e as ErrorResponse).statusMessage));
    }
  }

  Future<void> sync(text, _connectionStatus) async {
    try {
      emit(SendNameLoading());
      final addNameResponse =
          await SendNameService().sync(text, _connectionStatus);
      emit(SendNameSuccess(addNameResponse));
    } catch (e) {
      emit(SendNameFailed((e as ErrorResponse).statusMessage));
    }
  }
}
