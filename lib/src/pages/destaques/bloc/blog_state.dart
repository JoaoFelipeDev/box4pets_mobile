// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'blog_bloc.dart';

@immutable
sealed class BlogState {}

final class BlogInitial extends BlogState {}

final class BlogLoading extends BlogState {}

class BlogLoaded extends BlogState {
  final List<BlogModel> listBlog;
  BlogLoaded({
    required this.listBlog,
  });
}
