import 'package:bloc/bloc.dart';
import 'package:Box4Pets/src/pages/register/repositories/register_repository.dart';
import 'package:meta/meta.dart';
import '../models/register_model.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final _registerRepository = RegisterRepository();
  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterEvent>((event, emit) async {
      emit(RegisterLoading());
      if (event is RegisterEventRegister) {
        bool unicEmail =
            await _registerRepository.findEmail(register: event.register);
        if (unicEmail) {
          bool isAuth =
              await _registerRepository.register(register: event.register);

          if (isAuth) {
            emit(RegisterLoaded(isRegister: isAuth));
          }
        } else {
          emit(RegisterError(
              messageError: 'Este e-mail já está cadastrado no sistema!'));
        }
      }
    });
  }
}
