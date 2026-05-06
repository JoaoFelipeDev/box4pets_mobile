import 'package:Box4Pets/src/pages/parentesco/models/ativacao_parentesco_model.dart';
import 'package:Box4Pets/src/pages/parentesco/models/parentesco_model.dart';
import 'package:Box4Pets/src/pages/parentesco/repositories/parentesco_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'parentesco_event.dart';
part 'parentesco_state.dart';

class ParentescoBloc extends Bloc<ParentescoEvent, ParentescoState> {
  final parentescoRepository = ParentescoRepository();
  ParentescoBloc() : super(ParentescoInitial()) {
    on<ParentescoEvent>((event, emit) async {
      emit(ParentescoLoading());

      if(event is CreateParentesco){
       await parentescoRepository.createParentesco(parentesco: event.parentesco).then((response) {
          if(response.statusCode == 200){
            emit(ParentescoSuccess('Parentesco criado com sucesso'));
          }else{
            emit(ParentescoSuccess('Erro ao criar parentesco'));
          }
        });

      }else if(event is GetAtivacoes){
       await parentescoRepository.getAppAtivacao().then((response) {
          if(response.statusCode == 200){
            List<AtivacaoParentescoModel> ativacoes = [];
            response.data['records'].forEach((ativacao) {
              ativacoes.add(AtivacaoParentescoModel.fromMap(ativacao));
            });
            emit(ParentescoGetAtivacoesLoaded(ativacoes));
          }else{
            emit(ParentescoSuccess('Erro ao buscar parentescos'));
          }
        });
      }
    });
  }
}
