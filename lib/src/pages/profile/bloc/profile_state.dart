// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileDelet extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileModel proile;
  ProfileLoaded({
    required this.proile,
  });
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError({
    required this.message,
  });
}

class ProfileChangePasswordSuccess extends ProfileState {
  final String message;
  ProfileChangePasswordSuccess({
    required this.message,
  });
}

