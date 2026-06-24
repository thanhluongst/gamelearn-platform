import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../repository/teacher_repository.dart';

// Events
abstract class TeacherEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class TeacherLoadClassesEvent extends TeacherEvent {}
class TeacherLoadAnalyticsEvent extends TeacherEvent {
  final String classId;
  TeacherLoadAnalyticsEvent(this.classId);
  @override
  List<Object?> get props => [classId];
}
class TeacherCreateClassEvent extends TeacherEvent {
  final Map<String, dynamic> data;
  TeacherCreateClassEvent(this.data);
  @override
  List<Object?> get props => [data];
}
class TeacherCreateGameEvent extends TeacherEvent {
  final Map<String, dynamic> data;
  TeacherCreateGameEvent(this.data);
  @override
  List<Object?> get props => [data];
}

// States
abstract class TeacherState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TeacherInitialState extends TeacherState {}
class TeacherLoadingState extends TeacherState {}
class TeacherClassesLoadedState extends TeacherState {
  final List<dynamic> classes;
  TeacherClassesLoadedState(this.classes);
  @override
  List<Object?> get props => [classes];
}
class TeacherAnalyticsLoadedState extends TeacherState {
  final Map<String, dynamic> analytics;
  TeacherAnalyticsLoadedState(this.analytics);
  @override
  List<Object?> get props => [analytics];
}
class TeacherGameCreatedState extends TeacherState {
  final Map<String, dynamic> session;
  TeacherGameCreatedState(this.session);
  @override
  List<Object?> get props => [session];
}
class TeacherErrorState extends TeacherState {
  final String message;
  TeacherErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final TeacherRepository _repository;

  TeacherBloc(this._repository) : super(TeacherInitialState()) {
    on<TeacherLoadClassesEvent>(_onLoadClasses);
    on<TeacherLoadAnalyticsEvent>(_onLoadAnalytics);
    on<TeacherCreateClassEvent>(_onCreateClass);
    on<TeacherCreateGameEvent>(_onCreateGame);
  }

  Future<void> _onLoadClasses(TeacherLoadClassesEvent event, Emitter<TeacherState> emit) async {
    emit(TeacherLoadingState());
    try {
      final classes = await _repository.getMyClasses();
      emit(TeacherClassesLoadedState(classes));
    } catch (e) {
      emit(TeacherErrorState(e.toString()));
    }
  }

  Future<void> _onLoadAnalytics(TeacherLoadAnalyticsEvent event, Emitter<TeacherState> emit) async {
    emit(TeacherLoadingState());
    try {
      final analytics = await _repository.getClassAnalytics(event.classId);
      emit(TeacherAnalyticsLoadedState(analytics));
    } catch (e) {
      emit(TeacherErrorState(e.toString()));
    }
  }

  Future<void> _onCreateClass(TeacherCreateClassEvent event, Emitter<TeacherState> emit) async {
    try {
      await _repository.createClass(event.data);
      add(TeacherLoadClassesEvent());
    } catch (e) {
      emit(TeacherErrorState(e.toString()));
    }
  }

  Future<void> _onCreateGame(TeacherCreateGameEvent event, Emitter<TeacherState> emit) async {
    emit(TeacherLoadingState());
    try {
      final session = await _repository.createGameSession(event.data);
      emit(TeacherGameCreatedState(session));
    } catch (e) {
      emit(TeacherErrorState(e.toString()));
    }
  }
}
