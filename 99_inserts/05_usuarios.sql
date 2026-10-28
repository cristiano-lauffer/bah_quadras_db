-- INSERT INTO
--     usuarios (id, nome, email, senha_hash, tipo)
-- VALUES
--     (
--         1,
--         'Administrador',
--         'admin@arena.local',
--         'hash',
--         'ADMIN'
--     ),
--     (
--         2,
--         'Joao Silva',
--         'joao@arena.local',
--         'hash',
--         'CLIENTE'
--     ),
--     (
--         3,
--         'Maria Souza',
--         'maria@arena.local',
--         'hash',
--         'CLIENTE'
--     );

INSERT INTO usuarios (nome, email, senha, papel) VALUES (
  'Admin',
  'admin@bahquadras.com',
  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHHG',
  'admin'
);