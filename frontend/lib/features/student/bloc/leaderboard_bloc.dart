import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/api_client.dart';

// Events
abstract class LeaderboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LeaderboardLoadEvent extends LeaderboardEvent {
  final String scope;
  final String period;
  final String? scopeId;
  LeaderboardLoadEvent({this.scope = 'global', this.period = 'all_time', this.scopeId});
  @override
  List<Object?> get props => [scope, period, scopeId];
}

// States
abstract class LeaderboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LeaderboardInitialState extends LeaderboardState {}
class LeaderboardLoadingState extends LeaderboardState {}
class LeaderboardLoadedState extends LeaderboardState {
  final List<dynamic> entries;
  final Map<String, dynamic>? myRank;
  final String scope;
  final String period;
  LeaderboardLoadedState({required this.entries, this.myRank, required this.scope, required this.period});
  @override
  List<Object?> get props => [entries, myRank, scope, period];
}
class LeaderboardErrorState extends LeaderboardState {
  final String message;
  LeaderboardErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final ApiClient _client;

  LeaderboardBloc(this._client) : super(LeaderboardInitialState()) {
    on<LeaderboardLoadEvent>(_onLoad);
  }

  Future<void> _onLoad(LeaderboardLoadEvent event, Emitter<LeaderboardState> emit) async {
    emit(LeaderboardLoadingState());
    try {
      final params = 'scope=${event.scope}&period=${event.period}'
          '${event.scopeId != null ? '&scopeId=${event.scopeId}' : ''}';

      final results = await Future.wait([
        _client.get('/leaderboard?$params'),
        _client.get('/leaderboard/me?$params'),
      ]);

      final leaderboard = results[0].data['data'] as List<dynamic>? ?? [];
      final myRank = results[1].data as Map<String, dynamic>?;

      emit(LeaderboardLoadedState(
        entries: leaderboard,
        myRank: myRank,
        scope: event.scope,
        period: event.period,
      ));
    } catch (e) {
      emit(LeaderboardErrorState(e.toString()));
    }
  }
}
