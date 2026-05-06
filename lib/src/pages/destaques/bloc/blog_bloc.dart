import 'package:bloc/bloc.dart';
import 'package:Box4Pets/src/pages/destaques/repositories/blog_repository.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import '../models/blog_model.dart';

part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final blogRespository = BlogRepository();
  BlogBloc() : super(BlogInitial()) {
    on<BlogEvent>((event, emit) async {
      emit(BlogLoading());
      if (event is BlogGetEvent) {
        final Response<dynamic> response = await blogRespository.getBlog();
        if (response.statusCode != 200) {
        } else {
          List<dynamic> responseMap = response.data['records'];
          List<BlogModel> listBlog =
              responseMap.map<BlogModel>((e) => BlogModel.fromMap(e)).toList();
          emit(BlogLoaded(listBlog: listBlog));
        }
      }
    });
  }
}
