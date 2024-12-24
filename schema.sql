CREATE TABLE IF NOT EXISTS comment (
  _id TEXT NOT NULL,
  uid TEXT NOT NULL,
  nick TEXT NOT NULL,
  mail TEXT NOT NULL,
  mailMd5 TEXT NOT NULL,
  link TEXT NOT NULL,
  ua TEXT NOT NULL,
  ip TEXT NOT NULL,
  master INTEGER NOT NULL,
  url TEXT NOT NULL,
  href TEXT NOT NULL,
  comment TEXT NOT NULL,
  pid TEXT NOT NULL,
  rid TEXT NOT NULL,
  isSpam INTEGER NOT NULL,
  created INTEGER NOT NULL,
  updated INTEGER NOT NULL,
  like TEXT NOT NULL,
  top INTEGER NOT NULL,
  avatar TEXT NOT NULL,
  PRIMARY KEY (url, created DESC)
);

CREATE INDEX IF NOT EXISTS idx_comment_created ON comment (created DESC);
CREATE INDEX IF NOT EXISTS idx_comment_ip_created ON comment (ip, created DESC);

CREATE TABLE IF NOT EXISTS config (
  value TEXT NOT NULL
);

INSERT INTO config (value) SELECT '' WHERE NOT EXISTS (SELECT 1 FROM config);

CREATE TABLE IF NOT EXISTS counter (
  url TEXT NOT NULL PRIMARY KEY,
  title TEXT NOT NULL,
  time INTEGER NOT NULL,
  created INTEGER NOT NULL,
  updated INTEGER NOT NULL
);
