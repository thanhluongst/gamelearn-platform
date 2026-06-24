import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger, UseGuards } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { GamesService } from './games.service';
import { ConfigService } from '@nestjs/config';

interface AuthSocket extends Socket {
  userId: string;
  username: string;
  role: string;
}

@WebSocketGateway({
  cors: { origin: '*', credentials: true },
  namespace: '/game',
})
export class GameGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(GameGateway.name);
  private readonly playerSessions = new Map<string, string>(); // userId -> sessionId

  constructor(
    private readonly gamesService: GamesService,
    private readonly jwtService: JwtService,
    private readonly config: ConfigService,
  ) {}

  async handleConnection(client: AuthSocket) {
    try {
      const token = client.handshake.auth?.token
        || client.handshake.headers?.authorization?.replace('Bearer ', '');
      if (!token) { client.disconnect(); return; }

      const payload = this.jwtService.verify(token, {
        secret: this.config.get('app.jwtSecret'),
      });
      client.userId = payload.sub;
      client.username = payload.username;
      client.role = payload.role;

      this.logger.log(`Client connected: ${client.userId} (${client.username})`);
    } catch {
      client.disconnect();
    }
  }

  handleDisconnect(client: AuthSocket) {
    const sessionId = this.playerSessions.get(client.userId);
    if (sessionId) {
      client.to(`session:${sessionId}`).emit('player:disconnected', {
        userId: client.userId,
        username: client.username,
      });
      this.playerSessions.delete(client.userId);
    }
    this.logger.log(`Client disconnected: ${client.userId}`);
  }

  @SubscribeMessage('session:join')
  async handleJoinSession(
    @ConnectedSocket() client: AuthSocket,
    @MessageBody() data: { sessionId?: string; joinCode?: string; nickname?: string },
  ) {
    try {
      const session = await this.gamesService.joinSession(
        client.userId,
        data.sessionId,
        data.joinCode,
        data.nickname,
      );

      client.join(`session:${session.id}`);
      this.playerSessions.set(client.userId, session.id);

      // Notify all players
      const players = await this.gamesService.getSessionPlayers(session.id);
      this.server.to(`session:${session.id}`).emit('session:players_update', players);

      client.emit('session:joined', session);
    } catch (e) {
      client.emit('error', { message: e.message });
    }
  }

  @SubscribeMessage('session:start')
  async handleStartSession(
    @ConnectedSocket() client: AuthSocket,
    @MessageBody() data: { sessionId: string },
  ) {
    try {
      const session = await this.gamesService.startSession(data.sessionId, client.userId);
      const firstQuestion = await this.gamesService.getSessionQuestion(session.id, 0);

      this.server.to(`session:${session.id}`).emit('game:started', {
        sessionId: session.id,
        gameType: session.gameType,
        totalQuestions: session.questionIds.length,
      });

      // Send first question after 3 seconds
      setTimeout(() => {
        this.sendQuestion(session.id, 0, firstQuestion);
      }, 3000);
    } catch (e) {
      client.emit('error', { message: e.message });
    }
  }

  @SubscribeMessage('game:answer')
  async handleAnswer(
    @ConnectedSocket() client: AuthSocket,
    @MessageBody() data: {
      sessionId: string;
      questionId: string;
      answer: string;
      timeTaken: number;
    },
  ) {
    try {
      const result = await this.gamesService.submitAnswer(
        data.sessionId,
        client.userId,
        data.questionId,
        data.answer,
        data.timeTaken,
      );

      // Send result to the answering player
      client.emit('game:answer_result', result);

      // Update leaderboard for all players
      const leaderboard = await this.gamesService.getSessionLeaderboard(data.sessionId);
      this.server.to(`session:${data.sessionId}`).emit('game:leaderboard_update', leaderboard);
    } catch (e) {
      client.emit('error', { message: e.message });
    }
  }

  @SubscribeMessage('session:next_question')
  async handleNextQuestion(
    @ConnectedSocket() client: AuthSocket,
    @MessageBody() data: { sessionId: string },
  ) {
    try {
      const session = await this.gamesService.advanceQuestion(data.sessionId, client.userId);
      if (!session) {
        // Game over
        const results = await this.gamesService.endSession(data.sessionId, client.userId);
        this.server.to(`session:${data.sessionId}`).emit('game:ended', results);
        return;
      }

      const question = await this.gamesService.getSessionQuestion(
        session.id,
        session.currentQuestionIndex,
      );
      this.sendQuestion(session.id, session.currentQuestionIndex, question);
    } catch (e) {
      client.emit('error', { message: e.message });
    }
  }

  @SubscribeMessage('game:reaction')
  async handleReaction(
    @ConnectedSocket() client: AuthSocket,
    @MessageBody() data: { sessionId: string; emoji: string },
  ) {
    client.to(`session:${data.sessionId}`).emit('game:reaction', {
      userId: client.userId,
      username: client.username,
      emoji: data.emoji,
    });
  }

  private sendQuestion(sessionId: string, index: number, question: any) {
    // Strip correct answer before sending to clients
    const { correctAnswer, answers, explanation, ...safeQuestion } = question;
    const safeAnswers = answers?.map(({ isCorrect, ...ans }) => ans);

    this.server.to(`session:${sessionId}`).emit('game:question', {
      index,
      question: { ...safeQuestion, answers: safeAnswers },
    });
  }

  // Called by GamesService to push events
  emitToSession(sessionId: string, event: string, data: any) {
    this.server.to(`session:${sessionId}`).emit(event, data);
  }
}
