-- 开启外键约束（IM表关联必须开启，否则外键不生效）
PRAGMA foreign_keys = ON;
-- 开启WAL模式，提升并发读写，IM多线程推荐
PRAGMA journal_mode = WAL;

-- 5.2.1 用户信息表 t_user
CREATE TABLE IF NOT EXISTS t_user (
    user_id INTEGER PRIMARY KEY NOT NULL,
    username VARCHAR(32) NOT NULL UNIQUE,
    nickname VARCHAR(32) NOT NULL,
    user_role INTEGER NOT NULL DEFAULT 0,
    login_status INTEGER NOT NULL DEFAULT 0,
    is_banned INTEGER NOT NULL DEFAULT 0,
    create_time TEXT NOT NULL DEFAULT (datetime('now','localtime')),
    update_time TEXT NOT NULL DEFAULT (datetime('now','localtime'))
);
CREATE INDEX IF NOT EXISTS idx_is_banned ON t_user(is_banned);

-- 5.2.2 群组信息表 t_group
CREATE TABLE IF NOT EXISTS t_group (
    group_id INTEGER PRIMARY KEY AUTOINCREMENT,
    group_name VARCHAR(64) NOT NULL,
    owner_id INTEGER NOT NULL,
    group_status INTEGER NOT NULL DEFAULT 0,
    create_time TEXT NOT NULL DEFAULT (datetime('now','localtime')),
    update_time TEXT NOT NULL DEFAULT (datetime('now','localtime')),
    FOREIGN KEY (owner_id) REFERENCES t_user(user_id)
);
CREATE INDEX IF NOT EXISTS idx_owner ON t_group(owner_id);
CREATE INDEX IF NOT EXISTS idx_status ON t_group(group_status);

-- 5.2.3 群成员表 t_group_member
CREATE TABLE IF NOT EXISTS t_group_member (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    group_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    join_time TEXT NOT NULL DEFAULT (datetime('now','localtime')),
    FOREIGN KEY (group_id) REFERENCES t_group(group_id),
    FOREIGN KEY (user_id) REFERENCES t_user(user_id)
);
CREATE UNIQUE INDEX IF NOT EXISTS uk_group_user ON t_group_member(group_id, user_id);
CREATE INDEX IF NOT EXISTS idx_group_id ON t_group_member(group_id);
CREATE INDEX IF NOT EXISTS idx_user_id ON t_group_member(user_id);

-- 5.2.4 消息记录表 t_message
CREATE TABLE IF NOT EXISTS t_message (
    msg_id INTEGER PRIMARY KEY NOT NULL,
    sender_id INTEGER NOT NULL,
    target_id INTEGER NOT NULL,
    msg_type INTEGER NOT NULL,
    content TEXT NOT NULL,
    send_time TEXT NOT NULL DEFAULT (datetime('now','localtime')),
    msg_status INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (sender_id) REFERENCES t_user(user_id)
);
CREATE INDEX IF NOT EXISTS idx_target_time ON t_message(target_id, send_time DESC);
CREATE INDEX IF NOT EXISTS idx_sender ON t_message(sender_id);

-- 5.2.5 会话信息表 t_session
CREATE TABLE IF NOT EXISTS t_session (
    session_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    session_type INTEGER NOT NULL,
    target_id INTEGER NOT NULL,
    last_msg_time TEXT NULL,
    create_time TEXT NOT NULL DEFAULT (datetime('now','localtime')),
    FOREIGN KEY (user_id) REFERENCES t_user(user_id)
);
CREATE UNIQUE INDEX IF NOT EXISTS uk_user_target ON t_session(user_id, session_type, target_id);
CREATE INDEX IF NOT EXISTS idx_user_time ON t_session(user_id, last_msg_time DESC);

-- 5.2.6 离线消息表 t_offline_message
CREATE TABLE IF NOT EXISTS t_offline_message (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    msg_id INTEGER NOT NULL,
    create_time TEXT NOT NULL DEFAULT (datetime('now','localtime')),
    FOREIGN KEY (user_id) REFERENCES t_user(user_id),
    FOREIGN KEY (msg_id) REFERENCES t_message(msg_id)
);
CREATE INDEX IF NOT EXISTS idx_user_id ON t_offline_message(user_id);
CREATE INDEX IF NOT EXISTS idx_msg_id ON t_offline_message(msg_id);
