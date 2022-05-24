part of 'send_name_cubit.dart';

@immutable
abstract class SendNameState extends Equatable {
  const SendNameState();

  @override
  List<Object> get props => [];
}

class SendNameInitial extends SendNameState {}

class SendNameLoading extends SendNameState {}

class SendNameSuccess extends SendNameState {
  final SuccessResponse? successResponse;

  const SendNameSuccess(this.successResponse);
}

class SendNameFailed extends SendNameState {
  final String errorMessage;

  const SendNameFailed(this.errorMessage);
}
