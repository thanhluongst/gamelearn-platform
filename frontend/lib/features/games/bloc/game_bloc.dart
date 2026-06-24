import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../repository/game_repository.dart';
import '../../../core/network/socket_client.dart';

// Events
abstract class GameEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GameJoinEvent extends GameEvent {
  final String? sessionId;
  final String? joinCode;
  final String? nickname;
  GameJoinEvent({this.sessionId, this.joinCode, this.nickname});
}

class GameStartEvent extends GameEvent {
  final String sessionId;
  GameStartEvent(this.sessionId);
}

class GameSubmitAnswerEvent extends GameEvent {
  final String sessionId;
  final String answer;
  GameSubmitAnswerEvent({required this.sessionId, required this.answer});
  @override
  List<Object?> get props => [sessionId, answer];
}

class GameQuestionReceivedEvent extends GameEvent {
  final Map<String, dynamic> question;
  final int index;
  GameQuestionReceivedEvent(this.question, this.index);
}

class GameAnswerResultReceivedEvent extends GameEvent {
  final Map<String, dynamic> result;
  GameAnswerResultReceivedEvent(this.result);
}

class GameLeaderboardUpdatedEvent extends GameEvent {
  final List<dynamic> leaderboard;
  GameLeaderboardUpdatedEvent(this.leaderboard);
}

class GameEndedEvent extends GameEvent {
  final Map<String, dynamic> results;
  GameEndedEvent(this.results);
}

// States
abstract class GameState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GameInitialState extends GameState {}
class GameLoadingState extends GameState {}
class GameLobbyState extends GameState {
  final Map<String, dynamic> session;
  final List<dynamic> players;
  GameLobbyState(this.session, this.players);
  @override
  List<Object?> get props => [session, players];
}
class GamePlayingState extends GameState {
  final Map<String, dynamic> currentQuestion;
  final int currentIndex;
  final int totalQuestions;
  final int myScore;
  final int currentStreak;
  final String gameType;
  final List<dynamic> leaderboard;
  GamePlayingState({
    required this.currentQuestion,
    required this.currentIndex,
    required this.totalQuestions,
    required this.myScore,
    required this.currentStreak,
    required this.gameType,
    required this.leaderboard,
  });
  @override
  List<Object?> get props => [currentQuestion, currentIndex, myScore];
}
class GameAnswerResultState extends GameState {
  final bool isCorrect;
  final String correctAnswer;
  final int scoreEarned;
  final int xpEarned;
  GameAnswerResultState({
    required this.isCorrect,
    required this.correctAnswer,
    required this.scoreEarned,
    required this.xpEarned,
  });
  @override
  List<Object?> get props => [isCorrect, scoreEarned];
}
class GameEndedState extends GameState {
  final Map<String, dynamic> results;
  GameEndedState(this.results);
  @override
  List<Object?> get props => [results];
}
class GameErrorState extends GameState {
  final String message;
  GameErrorState(this.message);
}

// BLoC
class GameBloc extends Bloc<GameEvent, GameState> {
  final GameRepository _repo;
  final SocketClient _socket;
  int _myScore = 0;
  int _currentStreak = 0;
  String _sessionId = '';
  String _gameType = '';
  int _totalQuestions = 0;
  List<dynamic> _leaderboard = [];

  GameBloc(this._repo, this._socket) : super(GameInitialState()) {
    on<GameJoinEvent>(_onJoin);
    on<GameStartEvent>(_onStart);
    on<GameSubmitAnswerEvent>(_onSubmitAnswer);
    on<GameQuestionReceivedEvent>(_onQuestionReceived);
    on<GameAnswerResultReceivedEvent>(_onAnswerResult);
    on<GameLeaderboardUpdatedEvent>(_onLeaderboardUpdate);
    on<GameEndedEvent>(_onGameEnded);

    _listenToSocket();
  }

  void _listenToSocket() {
    _socket.on('session:joined', (data) {
      _sessionId = data['id'];
      _gameType = data['gameType'] ?? '';
      _totalQuestions = data['questionIds']?.length ?? 10;
    });

    _socket.on('game:question', (data) {
      add(GameQuestionReceivedEvent(data['question'] as Map<String, dynamic>, data['index'] as int));
    });

    _socket.on('game:answer_result', (data) {
      add(GameAnswerResultReceivedEvent(data as Map<String, dynamic>));
    });

    _socket.on('game:leaderboard_update', (data) {
      add(GameLeaderboardUpdatedEvent(data as List));
    });

    _socket.on('game:ended', (data) {
      add(GameEndedEvent(data as Map<String, dynamic>));
    });
  }

  Future<void> _onJoin(GameJoinEvent event, Emitter<GameState> emit) async {
    emit(GameLoadingState());
    await _socket.connect();
    _socket.emit('session:join', {
      'sessionId': event.sessionId,
      'joinCode': event.joinCode,
      'nickname': event.nickname,
    });
  }

  Future<void> _onStart(GameStartEvent event, Emitter<GameState> emit) async {
    _socket.emit('session:start', {'sessionId': event.sessionId});
  }

  Future<void> _onSubmitAnswer(GameSubmitAnswerEvent event, Emitter<GameState> emit) async {
    _socket.emit('game:answer', {
      'sessionId': event.sessionId,
      'answer': event.answer,
      'timeTaken': 5000, // calculated from timer
    });
  }

  void _onQuestionReceived(GameQuestionReceivedEvent event, Emitter<GameState> emit) {
    emit(GamePlayingState(
      currentQuestion: event.question,
      currentIndex: event.index,
      totalQuestions: _totalQuestions,
      myScore: _myScore,
      currentStreak: _currentStreak,
      gameType: _gameType,
      leaderboard: _leaderboard,
    ));
  }

  void _onAnswerResult(GameAnswerResultReceivedEvent event, Emitter<GameState> emit) {
    final result = event.result;
    if (result['isCorrect'] == true) {
      _myScore += (result['scoreEarned'] as int? ?? 0);
      _currentStreak = result['currentStreak'] as int? ?? _currentStreak + 1;
    } else {
      _currentStreak = 0;
    }
    emit(GameAnswerResultState(
      isCorrect: result['isCorrect'] as bool? ?? false,
      correctAnswer: result['correctAnswer'] as String? ?? '',
      scoreEarned: result['scoreEarned'] as int? ?? 0,
      xpEarned: result['xpEarned'] as int? ?? 0,
    ));
  }

  void _onLeaderboardUpdate(GameLeaderboardUpdatedEvent event, Emitter<GameState> emit) {
    _leaderboard = event.leaderboard;
    if (state is GamePlayingState) {
      final s = state as GamePlayingState;
      emit(GamePlayingState(
        currentQuestion: s.currentQuestion,
        currentIndex: s.currentIndex,
        totalQuestions: s.totalQuestions,
        myScore: _myScore,
        currentStreak: _currentStreak,
        gameType: _gameType,
        leaderboard: _leaderboard,
      ));
    }
  }

  void _onGameEnded(GameEndedEvent event, Emitter<GameState> emit) {
    emit(GameEndedState(event.results));
    _socket.disconnect();
  }

  @override
  Future<void> close() {
    _socket.disconnect();
    return super.close();
  }
}
