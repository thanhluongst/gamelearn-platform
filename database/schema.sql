-- ============================================================
-- GAME-BASED LEARNING PLATFORM - DATABASE SCHEMA
-- PostgreSQL 16
-- ============================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE user_role AS ENUM ('admin', 'teacher', 'student');
CREATE TYPE user_status AS ENUM ('active', 'inactive', 'suspended');
CREATE TYPE question_type AS ENUM ('multiple_choice', 'true_false', 'numeric');
CREATE TYPE difficulty_level AS ENUM ('easy', 'medium', 'hard');
CREATE TYPE game_type AS ENUM ('fishing', 'gold_mining', 'car_race', 'treasure_hunt', 'puzzle', 'arena');
CREATE TYPE game_status AS ENUM ('waiting', 'playing', 'finished', 'cancelled');
CREATE TYPE badge_tier AS ENUM ('bronze', 'silver', 'gold', 'diamond', 'master', 'legend');
CREATE TYPE mission_type AS ENUM ('daily', 'weekly', 'special');
CREATE TYPE mission_status AS ENUM ('active', 'completed', 'expired');

-- ============================================================
-- SCHOOLS
-- ============================================================

CREATE TABLE schools (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    address TEXT,
    province VARCHAR(100),
    district VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(255),
    logo_url TEXT,
    settings JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_schools_code ON schools(code);

-- ============================================================
-- USERS (Admin, Teacher, Student)
-- ============================================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID REFERENCES schools(id) ON DELETE SET NULL,
    role user_role NOT NULL,
    status user_status DEFAULT 'active',
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    date_of_birth DATE,
    gender VARCHAR(10),
    -- Gamification
    xp_total INTEGER DEFAULT 0,
    level INTEGER DEFAULT 1,
    coins INTEGER DEFAULT 0,
    -- Student specific
    student_code VARCHAR(50),
    grade INTEGER, -- Khối lớp (1-9)
    -- Refresh token
    refresh_token_hash VARCHAR(255),
    last_login_at TIMESTAMP,
    -- Settings
    settings JSONB DEFAULT '{"notifications": true, "sound": true, "language": "vi"}',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_school ON users(school_id);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_xp ON users(xp_total DESC);

-- ============================================================
-- CLASSES
-- ============================================================

CREATE TABLE classes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL, -- Join code
    grade INTEGER NOT NULL,
    academic_year VARCHAR(20),
    subject VARCHAR(100),
    description TEXT,
    cover_url TEXT,
    is_active BOOLEAN DEFAULT true,
    max_students INTEGER DEFAULT 50,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_classes_school ON classes(school_id);
CREATE INDEX idx_classes_teacher ON classes(teacher_id);
CREATE INDEX idx_classes_code ON classes(code);

-- ============================================================
-- CLASS MEMBERSHIPS
-- ============================================================

CREATE TABLE class_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMP DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true,
    UNIQUE(class_id, student_id)
);

CREATE INDEX idx_class_members_class ON class_members(class_id);
CREATE INDEX idx_class_members_student ON class_members(student_id);

-- ============================================================
-- QUESTION BANKS
-- ============================================================

CREATE TABLE question_banks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    school_id UUID REFERENCES schools(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    subject VARCHAR(100),
    grade INTEGER,
    total_questions INTEGER DEFAULT 0,
    is_public BOOLEAN DEFAULT false,
    tags TEXT[],
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_qbanks_owner ON question_banks(owner_id);
CREATE INDEX idx_qbanks_school ON question_banks(school_id);

-- ============================================================
-- QUESTIONS
-- ============================================================

CREATE TABLE questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bank_id UUID NOT NULL REFERENCES question_banks(id) ON DELETE CASCADE,
    type question_type NOT NULL,
    difficulty difficulty_level DEFAULT 'medium',
    content TEXT NOT NULL,
    explanation TEXT, -- Giải thích đáp án
    image_url TEXT,
    audio_url TEXT,
    -- AI metadata
    subject VARCHAR(100),
    topic VARCHAR(255),
    subtopic VARCHAR(255),
    ai_confidence DECIMAL(3,2), -- 0.00-1.00
    -- Timing
    time_limit INTEGER DEFAULT 30, -- seconds
    -- XP reward
    xp_reward INTEGER DEFAULT 10,
    -- Stats
    total_attempts INTEGER DEFAULT 0,
    correct_attempts INTEGER DEFAULT 0,
    -- Import tracking
    import_row INTEGER,
    import_batch_id UUID,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_questions_bank ON questions(bank_id);
CREATE INDEX idx_questions_type ON questions(type);
CREATE INDEX idx_questions_difficulty ON questions(difficulty);
CREATE INDEX idx_questions_subject ON questions(subject);
CREATE INDEX idx_questions_topic ON questions(topic);
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_questions_content_trgm ON questions USING GIN (content gin_trgm_ops);

-- ============================================================
-- ANSWERS (for Multiple Choice)
-- ============================================================

CREATE TABLE answers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    label CHAR(1) NOT NULL, -- A, B, C, D
    content TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT false,
    display_order INTEGER DEFAULT 0
);

CREATE INDEX idx_answers_question ON answers(question_id);

-- ============================================================
-- TRUE/FALSE & NUMERIC ANSWERS (stored in questions table as JSONB)
-- For TRUE_FALSE: correct_answer = 'true' or 'false'
-- For NUMERIC: correct_answer = numeric value, accepted_range JSONB
-- ============================================================

ALTER TABLE questions ADD COLUMN correct_answer TEXT; -- true/false or numeric value
ALTER TABLE questions ADD COLUMN accepted_answers JSONB DEFAULT '[]'; -- Alternative accepted answers
ALTER TABLE questions ADD COLUMN numeric_tolerance DECIMAL(10,4) DEFAULT 0.001;

-- ============================================================
-- IMPORT BATCHES
-- ============================================================

CREATE TABLE import_batches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bank_id UUID NOT NULL REFERENCES question_banks(id) ON DELETE CASCADE,
    uploaded_by UUID NOT NULL REFERENCES users(id),
    file_name VARCHAR(255) NOT NULL,
    file_url TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'processing', -- processing, completed, failed
    total_rows INTEGER DEFAULT 0,
    processed_rows INTEGER DEFAULT 0,
    success_rows INTEGER DEFAULT 0,
    error_rows INTEGER DEFAULT 0,
    errors JSONB DEFAULT '[]',
    ai_processing_status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);

-- ============================================================
-- GAME SESSIONS
-- ============================================================

CREATE TABLE game_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_id UUID REFERENCES classes(id) ON DELETE SET NULL,
    teacher_id UUID REFERENCES users(id) ON DELETE SET NULL,
    bank_id UUID REFERENCES question_banks(id) ON DELETE SET NULL,
    game_type game_type NOT NULL,
    status game_status DEFAULT 'waiting',
    title VARCHAR(255),
    join_code VARCHAR(10) UNIQUE,
    -- Config
    max_players INTEGER DEFAULT 50,
    question_count INTEGER DEFAULT 10,
    time_per_question INTEGER DEFAULT 30,
    allow_late_join BOOLEAN DEFAULT true,
    show_leaderboard BOOLEAN DEFAULT true,
    randomize_questions BOOLEAN DEFAULT true,
    randomize_answers BOOLEAN DEFAULT true,
    -- Selected questions
    question_ids UUID[],
    current_question_index INTEGER DEFAULT 0,
    -- Timing
    started_at TIMESTAMP,
    ended_at TIMESTAMP,
    -- Results summary
    total_players INTEGER DEFAULT 0,
    avg_score DECIMAL(5,2),
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_sessions_class ON game_sessions(class_id);
CREATE INDEX idx_sessions_teacher ON game_sessions(teacher_id);
CREATE INDEX idx_sessions_status ON game_sessions(status);
CREATE INDEX idx_sessions_code ON game_sessions(join_code);
CREATE INDEX idx_sessions_type ON game_sessions(game_type);

-- ============================================================
-- GAME PLAYERS (Session participants)
-- ============================================================

CREATE TABLE game_players (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES game_sessions(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    nickname VARCHAR(100),
    avatar_url TEXT,
    score INTEGER DEFAULT 0,
    correct_count INTEGER DEFAULT 0,
    wrong_count INTEGER DEFAULT 0,
    streak INTEGER DEFAULT 0,
    max_streak INTEGER DEFAULT 0,
    rank INTEGER,
    xp_earned INTEGER DEFAULT 0,
    coins_earned INTEGER DEFAULT 0,
    joined_at TIMESTAMP DEFAULT NOW(),
    finished_at TIMESTAMP,
    UNIQUE(session_id, player_id)
);

CREATE INDEX idx_players_session ON game_players(session_id);
CREATE INDEX idx_players_player ON game_players(player_id);
CREATE INDEX idx_players_score ON game_players(session_id, score DESC);

-- ============================================================
-- GAME ANSWERS (Individual question answers)
-- ============================================================

CREATE TABLE game_answers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES game_sessions(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    answer_given TEXT,
    is_correct BOOLEAN DEFAULT false,
    time_taken INTEGER, -- milliseconds
    score_earned INTEGER DEFAULT 0,
    answered_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_ganswers_session ON game_answers(session_id);
CREATE INDEX idx_ganswers_player ON game_answers(player_id);
CREATE INDEX idx_ganswers_question ON game_answers(question_id);

-- ============================================================
-- LEVELS
-- ============================================================

CREATE TABLE levels (
    id SERIAL PRIMARY KEY,
    level_number INTEGER UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    xp_required INTEGER NOT NULL,
    xp_to_next INTEGER,
    -- Unlocks
    avatar_frame_url TEXT,
    badge_url TEXT,
    perks JSONB DEFAULT '{}',
    color_hex VARCHAR(7)
);

-- Seed levels 1-100
INSERT INTO levels (level_number, name, xp_required, xp_to_next, color_hex)
SELECT
    n,
    CASE
        WHEN n <= 10 THEN 'Tân Binh'
        WHEN n <= 20 THEN 'Học Trò'
        WHEN n <= 30 THEN 'Đệ Tử'
        WHEN n <= 40 THEN 'Học Sĩ'
        WHEN n <= 50 THEN 'Trí Tuệ'
        WHEN n <= 60 THEN 'Hiền Tài'
        WHEN n <= 70 THEN 'Thạc Sĩ'
        WHEN n <= 80 THEN 'Tiến Sĩ'
        WHEN n <= 90 THEN 'Huyền Thoại'
        ELSE 'Đại Sư'
    END,
    CASE
        WHEN n = 1 THEN 0
        ELSE (n-1) * (n-1) * 50 + (n-1) * 100
    END,
    n * n * 50 + n * 100,
    CASE
        WHEN n <= 10 THEN '#9E9E9E'
        WHEN n <= 20 THEN '#4CAF50'
        WHEN n <= 30 THEN '#2196F3'
        WHEN n <= 40 THEN '#9C27B0'
        WHEN n <= 50 THEN '#FF9800'
        WHEN n <= 60 THEN '#F44336'
        WHEN n <= 70 THEN '#E91E63'
        WHEN n <= 80 THEN '#00BCD4'
        WHEN n <= 90 THEN '#FFD700'
        ELSE '#FF4500'
    END
FROM generate_series(1, 100) n;

-- ============================================================
-- XP LOGS
-- ============================================================

CREATE TABLE xp_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    xp_amount INTEGER NOT NULL,
    source VARCHAR(100) NOT NULL, -- game_answer, daily_mission, achievement, bonus
    source_id UUID,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_xp_logs_user ON xp_logs(user_id);
CREATE INDEX idx_xp_logs_created ON xp_logs(created_at DESC);

-- ============================================================
-- ACHIEVEMENTS / BADGES
-- ============================================================

CREATE TABLE achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    tier badge_tier DEFAULT 'bronze',
    icon_url TEXT,
    -- Conditions (JSON)
    conditions JSONB NOT NULL,
    -- Rewards
    xp_reward INTEGER DEFAULT 0,
    coin_reward INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE user_achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id UUID NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
    earned_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

CREATE INDEX idx_user_achievements_user ON user_achievements(user_id);

-- ============================================================
-- MISSIONS
-- ============================================================

CREATE TABLE missions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type mission_type NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    icon_url TEXT,
    -- Target
    target_type VARCHAR(100) NOT NULL, -- correct_answers, games_played, xp_earned
    target_value INTEGER NOT NULL,
    -- Rewards
    xp_reward INTEGER DEFAULT 0,
    coin_reward INTEGER DEFAULT 0,
    item_rewards JSONB DEFAULT '[]',
    -- Schedule
    is_active BOOLEAN DEFAULT true,
    valid_from TIMESTAMP,
    valid_to TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE user_missions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    mission_id UUID NOT NULL REFERENCES missions(id) ON DELETE CASCADE,
    status mission_status DEFAULT 'active',
    progress INTEGER DEFAULT 0,
    started_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP,
    expires_at TIMESTAMP,
    UNIQUE(user_id, mission_id, started_at::DATE)
);

CREATE INDEX idx_user_missions_user ON user_missions(user_id);
CREATE INDEX idx_user_missions_status ON user_missions(status);

-- ============================================================
-- LEADERBOARDS (Materialized Views updated periodically)
-- ============================================================

CREATE TABLE leaderboard_snapshots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    scope VARCHAR(50) NOT NULL, -- class, grade, school, global
    scope_id UUID, -- class_id / school_id / null for global
    period VARCHAR(20) NOT NULL, -- daily, weekly, monthly, yearly, all_time
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    rankings JSONB NOT NULL, -- [{rank, user_id, score, xp, games_played}]
    generated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(scope, scope_id, period, period_start)
);

CREATE INDEX idx_leaderboard_scope ON leaderboard_snapshots(scope, scope_id, period);

-- ============================================================
-- STATISTICS (Aggregated)
-- ============================================================

CREATE TABLE user_statistics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    -- Overall
    total_questions INTEGER DEFAULT 0,
    correct_questions INTEGER DEFAULT 0,
    total_games INTEGER DEFAULT 0,
    total_play_time INTEGER DEFAULT 0, -- seconds
    -- By type
    stats_by_type JSONB DEFAULT '{}',
    -- By subject
    stats_by_subject JSONB DEFAULT '{}',
    -- By topic
    stats_by_topic JSONB DEFAULT '{}',
    -- Streaks
    current_daily_streak INTEGER DEFAULT 0,
    max_daily_streak INTEGER DEFAULT 0,
    last_played_date DATE,
    -- Computed
    accuracy_rate DECIMAL(5,2) DEFAULT 0,
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE daily_statistics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    questions_answered INTEGER DEFAULT 0,
    correct_answers INTEGER DEFAULT 0,
    games_played INTEGER DEFAULT 0,
    xp_earned INTEGER DEFAULT 0,
    time_spent INTEGER DEFAULT 0, -- seconds
    UNIQUE(user_id, date)
);

CREATE INDEX idx_daily_stats_user ON daily_statistics(user_id);
CREATE INDEX idx_daily_stats_date ON daily_statistics(date DESC);

-- ============================================================
-- AI REPORTS
-- ============================================================

CREATE TABLE ai_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    session_id UUID REFERENCES game_sessions(id) ON DELETE CASCADE,
    report_type VARCHAR(100) NOT NULL, -- weakness_analysis, recommendation, progress_summary
    content JSONB NOT NULL,
    -- Strengths and weaknesses
    strengths JSONB DEFAULT '[]',
    weaknesses JSONB DEFAULT '[]',
    recommendations JSONB DEFAULT '[]',
    generated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_ai_reports_user ON ai_reports(user_id);

-- ============================================================
-- NOTIFICATIONS
-- ============================================================

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(100) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT,
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = false;

-- ============================================================
-- REWARDS / ITEMS
-- ============================================================

CREATE TABLE reward_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(100) NOT NULL, -- avatar_frame, theme, character, power_up
    rarity VARCHAR(50) DEFAULT 'common', -- common, rare, epic, legendary
    image_url TEXT,
    coin_price INTEGER,
    level_required INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE user_inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    item_id UUID NOT NULL REFERENCES reward_items(id) ON DELETE CASCADE,
    quantity INTEGER DEFAULT 1,
    is_equipped BOOLEAN DEFAULT false,
    acquired_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, item_id)
);

CREATE INDEX idx_inventory_user ON user_inventory(user_id);

-- ============================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================

-- Update updated_at automatically
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_classes_updated_at BEFORE UPDATE ON classes FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_questions_updated_at BEFORE UPDATE ON questions FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_sessions_updated_at BEFORE UPDATE ON game_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Update question bank total count
CREATE OR REPLACE FUNCTION update_bank_question_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE question_banks SET total_questions = total_questions + 1 WHERE id = NEW.bank_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE question_banks SET total_questions = total_questions - 1 WHERE id = OLD.bank_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_question_count
AFTER INSERT OR DELETE ON questions
FOR EACH ROW EXECUTE FUNCTION update_bank_question_count();

-- Auto level up function
CREATE OR REPLACE FUNCTION check_level_up(p_user_id UUID)
RETURNS VOID AS $$
DECLARE
    v_user RECORD;
    v_next_level RECORD;
BEGIN
    SELECT xp_total, level INTO v_user FROM users WHERE id = p_user_id;
    SELECT level_number, xp_required INTO v_next_level
    FROM levels
    WHERE level_number = v_user.level + 1;

    IF v_next_level IS NOT NULL AND v_user.xp_total >= v_next_level.xp_required THEN
        UPDATE users SET level = v_next_level.level_number WHERE id = p_user_id;
        PERFORM check_level_up(p_user_id); -- Recursive for multiple level ups
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- SEED DATA - Default Achievements
-- ============================================================

INSERT INTO achievements (name, description, tier, conditions, xp_reward, coin_reward) VALUES
('Khởi Đầu Tốt', 'Trả lời đúng câu hỏi đầu tiên', 'bronze', '{"type": "correct_answers", "value": 1}', 10, 5),
('Combo 5', 'Trả lời đúng 5 câu liên tiếp', 'bronze', '{"type": "streak", "value": 5}', 25, 10),
('Combo 10', 'Trả lời đúng 10 câu liên tiếp', 'silver', '{"type": "streak", "value": 10}', 50, 25),
('100 Câu Đúng', 'Trả lời đúng tổng 100 câu', 'silver', '{"type": "total_correct", "value": 100}', 100, 50),
('1000 Câu Đúng', 'Trả lời đúng tổng 1000 câu', 'gold', '{"type": "total_correct", "value": 1000}', 500, 200),
('Siêu Tốc', 'Trả lời đúng trong 3 giây', 'gold', '{"type": "speed", "value": 3000}', 50, 20),
('Học Sinh Chuyên Cần', 'Học liên tục 7 ngày', 'silver', '{"type": "daily_streak", "value": 7}', 200, 100),
('Chiến Binh 30 Ngày', 'Học liên tục 30 ngày', 'gold', '{"type": "daily_streak", "value": 30}', 1000, 500),
('Vô Địch Lớp', 'Đứng đầu bảng xếp hạng lớp', 'gold', '{"type": "class_rank", "value": 1}', 200, 100),
('Thiên Tài', 'Đạt Level 50', 'diamond', '{"type": "level", "value": 50}', 2000, 1000),
('Huyền Thoại', 'Đạt Level 100', 'legend', '{"type": "level", "value": 100}', 10000, 5000);

-- Default daily missions
INSERT INTO missions (type, name, description, target_type, target_value, xp_reward, coin_reward, is_active) VALUES
('daily', 'Khởi Động Buổi Sáng', 'Trả lời đúng 10 câu hỏi', 'correct_answers', 10, 30, 15, true),
('daily', 'Chiến Binh Hôm Nay', 'Tham gia 2 trận đấu', 'games_played', 2, 50, 25, true),
('daily', 'Thu Thập Kinh Nghiệm', 'Kiếm 50 XP', 'xp_earned', 50, 20, 10, true),
('daily', 'Thử Thách Khó', 'Trả lời đúng 5 câu khó', 'hard_correct_answers', 5, 60, 30, true),
('weekly', 'Học Sinh Chăm Chỉ', 'Học 5 ngày trong tuần', 'active_days', 5, 200, 100, true),
('weekly', 'Chinh Phục Tuần', 'Trả lời đúng 100 câu', 'correct_answers', 100, 300, 150, true),
('weekly', 'Đấu Sĩ Xuất Sắc', 'Tham gia 10 trận đấu', 'games_played', 10, 250, 125, true);
