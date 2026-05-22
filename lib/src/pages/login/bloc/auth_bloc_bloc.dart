import 'package:Box4Pets/debug_agent_log.dart';
import 'package:bloc/bloc.dart';
import 'package:Box4Pets/src/pages/login/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';
import '../models/auth_model.dart';

part 'auth_bloc_event.dart';
part 'auth_bloc_state.dart';

class AuthBlocBloc extends Bloc<AuthBlocEvent, AuthBlocState> {
  final _authRepository = AuthRepository();
  AuthBlocBloc() : super(AuthBlocInitial()) {
     String generateUniqueCode() {
  var uuid = Uuid();
  return uuid.v4();
}
    on<AuthBlocEvent>((event, emit) async {
      String userId = '';
      emit(AuthBlocLoading());

      if (event is AuthEvent) {
        try {
          final result = await _authRepository.auth(auth: event.auth);
          agentDebugLog(
            location: 'auth_bloc_bloc.dart:AuthEvent',
            message: 'auth bloc result',
            hypothesisId: 'H-D',
            data: {'success': result.success},
          );
          if (result.success) {
            emit(AuthBlocLoaded(isAuthenticated: true));
          } else {
            emit(AuthBlocError(
              messageError:
                  result.errorMessage ?? 'Email ou senha incorretos!',
            ));
          }
        } catch (e) {
          agentDebugLog(
            location: 'auth_bloc_bloc.dart:AuthEvent:error',
            message: 'auth bloc uncaught error',
            hypothesisId: 'H-B',
            data: {'error': e.toString()},
          );
          emit(AuthBlocError(messageError: 'Erro ao autenticar. Tente novamente.'));
        }
      }else if(event is AuthForgotPasswordEvent){
       final Response(:data) = await _authRepository.getUser(event.email);
        final users = data['records'];
        if(users.isEmpty){
          String messageError = 'Email não encontrado!';
          emit(AuthBlocError(messageError: messageError));
      }else{   
        print(users[0]['id']);
        final id = users[0]['id'];
        userId = users[0]['id'];
        print('setando id: $userId');
        final code = generateUniqueCode();
        await _authRepository.setCode(id,code);

        emit(AuthBlocForgotPassword(email: event.email, code: code));
      }
      } else if(event is AuthCheckCodeEvent){
      final Response(:data) = await _authRepository.checkCode(event.code);
        final users = data['records'];
        if(users.isEmpty){
          emit(AuthBlocCheckCode(isValid: false));
        }else{
          emit(AuthBlocCheckCode(isValid: true));
        }

    }else if(event is AuthChangePasswordEvent){
      final Response<dynamic> response = await _authRepository.checkCode(event.code);
      
        final id = response.data['records'][0]['id'];
      final Response(:data) = await _authRepository.changePassword( id, event.password);
       
      print(data);
        final users = data['records'];
        if(users.isEmpty){
          emit(AuthBlocChangePassword(isChanged: false));
        }else{
          emit(AuthBlocChangePassword(isChanged: true));
        }
    }});
  }
  
}

