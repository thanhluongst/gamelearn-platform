import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../repository/student_repository.dart';

// Events
abstract class StudentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StudentLoadStatsEvent extends StudentEvent {}
class StudentLoadMissionsEvent extends StudentEvent {}
class StudentClaimMissionEvent extends StudentEvent {
  final String missionId;
  StudentClaimMissionEvent(this.missionId);
  @override
  List<Object?> get props => [missionId];
}

// States
abstract class StudentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StudentInitialState extends StudentState {}
class StudentLoadingState extends StudentState {}
class StudentLoadedState extends StudentState {
  final Map<String, dynamic> stats;
  final List<dynamic> missions;
  StudentLoadedState({required this.stats, required this.missions});
  @override
  List<Object?> get props => [stats, missions];
}
class StudentErrorState extends StudentState {
  final String message;
  StudentErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentRepository _repository;

  StudentBloc(this._repository) : super(StudentInitialState()) {
    on<StudentLoadStatsEvent>(_onLoadStats);
    on<StudentLoadMissionsEvent>(_onLoadMissions);
    on<StudentClaimMissionEvent>(_onClaimMission);
  }

  Future<void> _onLoadStats(StudentLoadStatsEvent event, Emitter<StudentState> emit) async {
    emit(StudentLoadingState());
    try {
      final stats = await _repository.getMyStats();
      final missions = await _repository.getMyMissions();
      emit(StudentLoadedState(stats: stats, missions: missions));
    } catch (e) {
      emit(StudentErrorState(e.toString()));
    }
  }

  Future<void> _onLoadMissions(StudentLoadMissionsEvent event, Emitter<StudentState> emit) async {
    try {
      final missions = await _repository.getMyMissions();
      final current = state;
      if (current is StudentLoadedState) {
        emit(StudentLoadedState(stats: current.stats, missions: missions));
      }
    } catch (_) {}
  }

  Future<void> _onClaimMission(StudentClaimMissionEvent event, Emitter<StudentState> emit) async {
    try {
      await _repository.claimMission(event.missionId);
      add(StudentLoadMissionsEvent());
    } catch (_) {}
  }
}
