// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class ProfileGetEvent extends ProfileEvent {}

class ProfileDeletAccountEvent extends ProfileEvent {}

class ProfileSendFotoAccountEvent extends ProfileEvent {}

class ProfileEditingEvent extends ProfileEvent {
  final ProfileEditingModel profile;
  ProfileEditingEvent({
    required this.profile,
  });
}

class ProfileChangePasswordEvent extends ProfileEvent {
  final ChangePasswordmodel password;
  ProfileChangePasswordEvent({
    required this.password,
  });
}
