import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/question_card.dart';
import '../widgets/answer_option.dart';
import '../widgets/timer_widget.dart';
import '../widgets/leaderboard_overlay.dart';
import '../widgets/score_popup.dart';
import '../bloc/game_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GamePlayScreen extends StatefulWidget {
  final String sessionId;
  const GamePlayScreen({super.key, required this.sessionId});

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AudioPlayer _audioPlayer;
  late AnimationController _backgroundController;
  late Animation<Color?> _backgroundAnimation;
  String? _selectedAnswer;
  bool _hasAnswered = false;
  bool _showLeaderboard = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _audioPlayer = AudioPlayer();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _backgroundAnimation = ColorTween(
      begin: const Color(0xFF6C63FF),
      end: const Color(0xFF43E97B),
    ).animate(_backgroundController);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) {
        if (state is GameAnswerResultState) {
          _handleAnswerResult(state);
        } else if (state is GameEndedState) {
          _navigateToResults();
        }
      },
      builder: (context, state) {
        if (state is GamePlayingState) {
          return _buildGameUI(state);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildGameUI(GamePlayingState state) {
    final question = state.currentQuestion;
    final gameType = state.gameType;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            gradient: _buildGameGradient(gameType),
          ),
          child: child,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Game background illustration
              _buildGameBackground(gameType),

              Column(
                children: [
                  // Header: Progress + Timer + Score
                  _buildHeader(state),

                  // Question card
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Question
                          QuestionCard(
                            question: question,
                            questionNumber: state.currentIndex + 1,
                            totalQuestions: state.totalQuestions,
                          ).animate().slideY(begin: 0.3, duration: 400.ms).fadeIn(),

                          const SizedBox(height: 20),

                          // Answers
                          _buildAnswers(question, state.gameType),
                        ],
                      ),
                    ),
                  ),

                  // Bottom streak indicator
                  _buildStreakBar(state.currentStreak),
                ],
              ),

              // Timer overlay
              Positioned(
                top: 60,
                right: 16,
                child: TimerWidget(
                  duration: question['timeLimit'] ?? 30,
                  onTimeUp: _onTimeUp,
                  isActive: !_hasAnswered,
                ),
              ),

              // Leaderboard overlay
              if (_showLeaderboard)
                LeaderboardOverlay(
                  players: state.leaderboard,
                  onClose: () => setState(() => _showLeaderboard = false),
                ),

              // Confetti
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Color(0xFF6C63FF),
                  Color(0xFFFF6584),
                  Color(0xFF43E97B),
                  Color(0xFFFFBE0B),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(GamePlayingState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Câu ${state.currentIndex + 1}/${state.totalQuestions}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (state.currentIndex + 1) / state.totalQuestions,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${state.myScore}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Leaderboard button
          IconButton(
            onPressed: () => setState(() => _showLeaderboard = !_showLeaderboard),
            icon: const Icon(Icons.leaderboard, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswers(Map<String, dynamic> question, String gameType) {
    final type = question['type'] as String;

    if (type == 'multiple_choice') {
      final answers = question['answers'] as List;
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
        children: List.generate(answers.length, (i) {
          final answer = answers[i];
          final label = answer['label'] as String;
          final isSelected = _selectedAnswer == label;
          final isCorrect = _hasAnswered && (answer['isCorrect'] as bool? ?? false);
          final isWrong = _hasAnswered && isSelected && !(answer['isCorrect'] as bool? ?? false);

          return AnswerOption(
            label: label,
            content: answer['content'] as String,
            isSelected: isSelected,
            isCorrect: isCorrect,
            isWrong: isWrong,
            isEnabled: !_hasAnswered,
            onTap: () => _submitAnswer(label),
            color: _answerColor(i),
          ).animate(delay: (i * 100).ms).slideX(begin: i.isEven ? -0.3 : 0.3).fadeIn();
        }),
      );
    } else if (type == 'true_false') {
      return Row(
        children: [
          Expanded(
            child: AnswerOption(
              label: 'A',
              content: 'ĐÚNG',
              isSelected: _selectedAnswer == 'true',
              isCorrect: _hasAnswered && question['correctAnswer'] == 'true',
              isWrong: _hasAnswered && _selectedAnswer == 'true' && question['correctAnswer'] != 'true',
              isEnabled: !_hasAnswered,
              onTap: () => _submitAnswer('true'),
              color: const Color(0xFF43E97B),
              icon: Icons.check_circle,
            ).animate(delay: 100.ms).slideX(begin: -0.3).fadeIn(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnswerOption(
              label: 'B',
              content: 'SAI',
              isSelected: _selectedAnswer == 'false',
              isCorrect: _hasAnswered && question['correctAnswer'] == 'false',
              isWrong: _hasAnswered && _selectedAnswer == 'false' && question['correctAnswer'] != 'false',
              isEnabled: !_hasAnswered,
              onTap: () => _submitAnswer('false'),
              color: const Color(0xFFFF4D6D),
              icon: Icons.cancel,
            ).animate(delay: 200.ms).slideX(begin: 0.3).fadeIn(),
          ),
        ],
      );
    } else {
      // Numeric input
      return _NumericInput(
        enabled: !_hasAnswered,
        onSubmit: _submitAnswer,
      );
    }
  }

  Widget _buildStreakBar(int streak) {
    if (streak < 2) return const SizedBox(height: 16);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
          const SizedBox(width: 4),
          Text(
            'Combo x$streak!',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ).animate().shake();
  }

  Widget _buildGameBackground(String gameType) {
    // Different decorative backgrounds per game type
    return Positioned.fill(
      child: Opacity(
        opacity: 0.1,
        child: Image.asset(
          'assets/images/bg_$gameType.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  LinearGradient _buildGameGradient(String gameType) {
    return AppTheme.gameGradients[gameType] ??
        AppTheme.primaryGradient;
  }

  Color _answerColor(int index) {
    const colors = [
      Color(0xFFFF6B6B),
      Color(0xFF4ECDC4),
      Color(0xFF45B7D1),
      Color(0xFFFFA07A),
    ];
    return colors[index % colors.length];
  }

  void _submitAnswer(String answer) {
    if (_hasAnswered) return;
    setState(() {
      _selectedAnswer = answer;
      _hasAnswered = true;
    });

    context.read<GameBloc>().add(GameSubmitAnswerEvent(
      sessionId: widget.sessionId,
      answer: answer,
    ));
  }

  void _onTimeUp() {
    if (!_hasAnswered) {
      _submitAnswer('');
    }
  }

  void _handleAnswerResult(GameAnswerResultState state) {
    if (state.isCorrect) {
      _confettiController.play();
      _audioPlayer.play(AssetSource('sounds/correct.mp3'));
      _backgroundController.forward();
    } else {
      _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
    }
  }

  void _navigateToResults() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/game/result/${widget.sessionId}');
  }
}

class _NumericInput extends StatefulWidget {
  final bool enabled;
  final void Function(String) onSubmit;

  const _NumericInput({required this.enabled, required this.onSubmit});

  @override
  State<_NumericInput> createState() => _NumericInputState();
}

class _NumericInputState extends State<_NumericInput> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
          ),
          child: TextField(
            controller: _controller,
            enabled: widget.enabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(
              hintText: 'Nhập đáp án...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.enabled
                ? () => widget.onSubmit(_controller.text.trim())
                : null,
            icon: const Icon(Icons.send),
            label: const Text('Xác nhận'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    ).animate().slideY(begin: 0.3).fadeIn();
  }
}
