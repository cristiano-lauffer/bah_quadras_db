-- GERADO por gerar_completo.sh: não edite à mão, edite os scripts e gere de novo.
-- ATENÇÃO: APAGA e recria o banco bah_quadras e o usuário usr_app_bah_quadras.
-- Uso: mysql -u root -p < bah_quadras_reset_completo.sql
SET NAMES utf8mb4;
DROP DATABASE IF EXISTS bah_quadras;
DROP USER IF EXISTS usr_app_bah_quadras;

-- >>> 01_db/database.sql
-- drop DATABASE bah_quadras;

CREATE DATABASE bah_quadras CHARACTER SET utf8 COLLATE utf8_general_ci;

-- >>> 02_users/usr_app_bah_quadras.sql
-- drop user usr_app_bah_quadras;
CREATE USER usr_app_bah_quadras IDENTIFIED BY '123456';
USE bah_quadras;

-- >>> 03_grants/usr_app_bah_quadras.sql
use bah_quadras;

GRANT SELECT, INSERT, UPDATE, DELETE ON bah_quadras.* TO usr_app_bah_quadras;

SHOW GRANTS FOR usr_app_bah_quadras;

-- >>> 04_tables/01_usuarios.sql
-- CREATE TABLE usuarios (
--         id BIGINT AUTO_INCREMENT PRIMARY KEY,
--         nome VARCHAR(150) NOT NULL,
--         email VARCHAR(255) NOT NULL UNIQUE,
--         telefone VARCHAR(20),
--         senha_hash VARCHAR(255) NOT NULL,
--         tipo VARCHAR(20) NOT NULL DEFAULT 'CLIENTE',
--         ativo BOOLEAN NOT NULL DEFAULT TRUE,
--         created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
--         updated_at DATETIME NULL,
--         CONSTRAINT chk_usuario_tipo CHECK (tipo IN ('ADMIN', 'CLIENTE'))
--     );

-- Tabela de usuários (clientes, empresas e admins)
CREATE TABLE IF NOT EXISTS usuarios (
  id         BIGINT NOT NULL AUTO_INCREMENT,
  nome       VARCHAR(100) NOT NULL,
  email      VARCHAR(150) NOT NULL,
  telefone   VARCHAR(20) NULL,       -- só dígitos (DDD + número), a API remove a máscara
  senha      VARCHAR(255) NOT NULL,  -- hash bcrypt, nunca senha pura
  papel      ENUM('cliente', 'empresa', 'admin') NOT NULL DEFAULT 'cliente',
  empresa_id BIGINT NULL,            -- só para papel 'empresa'; a FK é criada em 02_empresas.sql
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,

  PRIMARY KEY (id),
  UNIQUE KEY uq_email (email)
);

-- >>> 04_tables/02_empresas.sql
CREATE TABLE empresas (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        nome VARCHAR(200) NOT NULL,
        cnpj VARCHAR(20) UNIQUE,       -- só dígitos; a API devolve 409 se repetir
        telefone VARCHAR(20),
        endereco VARCHAR(500),
        ativo BOOLEAN NOT NULL DEFAULT TRUE,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME NULL
    );

-- Usuário responsável pela empresa (papel 'empresa').
-- Fica aqui porque 01_usuarios.sql roda antes de existir a tabela empresas.
ALTER TABLE usuarios
    ADD CONSTRAINT fk_usuarios_empresa FOREIGN KEY (empresa_id) REFERENCES empresas (id);


-- >>> 04_tables/03_tipos_quadra.sql
CREATE TABLE tipos_quadra (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        descricao VARCHAR(100) NOT NULL UNIQUE,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    );

-- >>> 04_tables/04_quadras.sql
CREATE TABLE quadras (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        empresa_id BIGINT NOT NULL,
        tipo_quadra_id BIGINT NOT NULL,
        nome VARCHAR(100) NOT NULL,
        descricao VARCHAR(500),
        valor_hora DECIMAL(10, 2) NOT NULL,
        status ENUM('ativa', 'manutencao', 'inativa') NOT NULL DEFAULT 'ativa',
        piso VARCHAR(50),
        cobertura ENUM('coberta', 'descoberta'),
        capacidade TINYINT UNSIGNED,
        comodidades JSON,              -- lista de textos, ex.: ["Vestiário", "Iluminação"]
        imagem_url VARCHAR(500),
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME NULL,
        FOREIGN KEY (empresa_id) REFERENCES empresas (id),
        FOREIGN KEY (tipo_quadra_id) REFERENCES tipos_quadra (id)
    );

-- >>> 04_tables/05_status_solicitacao_reserva.sql
CREATE TABLE status_solicitacao_reserva (
        id TINYINT PRIMARY KEY,
        nome VARCHAR(50) NOT NULL UNIQUE,
        descricao VARCHAR(255),
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    );

-- >>> 04_tables/06_solicitacoes_reserva.sql
CREATE TABLE solicitacoes_reserva (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        usuario_id BIGINT NOT NULL,
        quadra_id BIGINT NOT NULL,
        status_id TINYINT NOT NULL,
        data_reserva DATE NOT NULL,
        hora_inicio TIME NOT NULL,
        hora_fim TIME NOT NULL,
        observacao TEXT,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME NULL,
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id),
        FOREIGN KEY (quadra_id) REFERENCES quadras (id),
        FOREIGN KEY (status_id) REFERENCES status_solicitacao_reserva (id),
        CHECK (hora_fim > hora_inicio)
    );

-- >>> 04_tables/07_reservas.sql
CREATE TABLE reservas (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        solicitacao_id BIGINT NOT NULL UNIQUE,
        status VARCHAR(20) NOT NULL DEFAULT 'ATIVA',
        preco_snapshot DECIMAL(10, 2) NULL,  -- valor_hora da quadra no momento da reserva (US6)

        -- alterar para data_cancelamento
        data_confirmacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (solicitacao_id) REFERENCES solicitacoes_reserva (id),
        CHECK (status IN ('ATIVA', 'CANCELADA'))
    );

-- >>> 04_tables/08_bloqueios_quadra.sql
CREATE TABLE bloqueios_quadra (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        quadra_id BIGINT NOT NULL,
        data_inicio DATETIME NOT NULL,
        data_fim DATETIME NOT NULL,
        motivo VARCHAR(255) NOT NULL,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (quadra_id) REFERENCES quadras (id),
        CHECK (data_fim > data_inicio)
    );

CREATE INDEX idx_bloqueios_quadra_periodo ON bloqueios_quadra (quadra_id, data_inicio, data_fim);

-- >>> 04_tables/09_horarios.sql
-- Grade semanal de horários da quadra (US5).
-- Cada linha vale para TODA semana naquele dia: dia_semana 0 = domingo ... 6 = sábado.
--   * datas específicas indisponíveis (manutenção, evento) -> bloqueios_quadra
--   * conflito entre reservas                             -> trigger trg_reserva_sem_conflito
CREATE TABLE horarios (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        quadra_id BIGINT NOT NULL,
        dia_semana TINYINT NOT NULL,
        hora_inicio TIME NOT NULL,
        hora_fim TIME NOT NULL,
        ativo BOOLEAN NOT NULL DEFAULT TRUE,  -- FALSE = slot bloqueado pela empresa
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME NULL,
        CONSTRAINT uq_horarios_slot UNIQUE (quadra_id, dia_semana, hora_inicio),
        FOREIGN KEY (quadra_id) REFERENCES quadras (id),
        CHECK (dia_semana BETWEEN 0 AND 6),
        CHECK (hora_fim > hora_inicio)
    );


-- >>> 05_triggers/01_trg_reserva_sem_conflito.sql
DELIMITER $$
CREATE TRIGGER trg_reserva_sem_conflito
BEFORE INSERT ON reservas
FOR EACH ROW
BEGIN
    DECLARE v_quadra_id BIGINT;
    DECLARE v_data DATE;
    DECLARE v_inicio TIME;
    DECLARE v_fim TIME;
    DECLARE v_conflitos INT DEFAULT 0;

    SELECT sr.quadra_id, sr.data_reserva, sr.hora_inicio, sr.hora_fim
      INTO v_quadra_id, v_data, v_inicio, v_fim
    FROM solicitacoes_reserva sr
    WHERE sr.id = NEW.solicitacao_id;

    SELECT COUNT(*) INTO v_conflitos
    FROM reservas r
    INNER JOIN solicitacoes_reserva sr ON sr.id = r.solicitacao_id
    WHERE r.status='ATIVA'
      AND sr.quadra_id=v_quadra_id
      AND sr.data_reserva=v_data
      AND (v_inicio < sr.hora_fim AND v_fim > sr.hora_inicio);

    IF v_conflitos > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Conflito de horario: quadra ja reservada.';
    END IF;
END$$
DELIMITER ;

-- >>> 99_inserts/01_status.sql
INSERT INTO
    status_solicitacao_reserva (id, nome, descricao)
VALUES
    (1, 'AGUARDANDO_APROVACAO', 'Aguardando aprovação'),
    (2, 'APROVADA', 'Solicitação aprovada'),
    (3, 'CANCELADA', 'Cancelada');

-- >>> 99_inserts/02_empresas.sql
SET NAMES utf8mb4;

-- Endereço no formato "Rua, número - Bairro, Cidade/UF": o front separa bairro e cidade a partir dele.
INSERT INTO
    empresas (id, nome, cnpj, telefone, endereco)
VALUES
    (1, 'Arena Central', '12345678000195', '51999990000', 'Av. Ipiranga, 6681 - Partenon, Porto Alegre/RS');


-- >>> 99_inserts/03_tipos_quadra.sql
SET NAMES utf8mb4;

-- Mesmas modalidades do formulário de quadra do front (a comparação ignora maiúsculas).
INSERT INTO
    tipos_quadra (id, descricao)
VALUES
    (1, 'Futebol Society'),
    (2, 'Beach Tennis'),
    (3, 'Futsal'),
    (4, 'Vôlei'),
    (5, 'Vôlei de Areia'),
    (6, 'Basquete'),
    (7, 'Tênis'),
    (8, 'Padel');


-- >>> 99_inserts/04_quadras.sql
SET NAMES utf8mb4;

INSERT INTO
    quadras (id, empresa_id, tipo_quadra_id, nome, descricao, valor_hora, status, piso, cobertura, capacidade, comodidades, imagem_url)
VALUES
    (1, 1, 1, 'Society 1', 'Campo de grama sintética com iluminação para jogos à noite.', 120, 'ativa',
        'Grama sintética', 'descoberta', 14, '["Vestiário", "Chuveiro", "Iluminação", "Estacionamento"]',
        'https://images.unsplash.com/photo-1522778119026-d647f0596c20?auto=format&fit=crop&w=1000&q=80'),
    (2, 1, 2, 'Beach 1', 'Quadra de areia para beach tennis.', 80, 'ativa',
        'Areia', 'descoberta', 4, '["Iluminação", "Aluguel de materiais"]',
        'https://images.unsplash.com/photo-1592656094267-764a45160876?auto=format&fit=crop&w=1000&q=80');


-- >>> 99_inserts/05_usuarios.sql
-- SOMENTE DESENVOLVIMENTO: senhas conhecidas para testar cada papel.
--   admin@bahquadras.com    admin123    (admin)
--   joao@arena.local        cliente123  (cliente)
--   maria@arena.local       cliente123  (cliente)
--   contato@arenacentral.com empresa123 (empresa, responsável pela Arena Central)
-- Os ids 2 e 3 são usados pelo seed 06_solicitacoes_reserva.sql.
INSERT INTO
    usuarios (id, nome, email, telefone, senha, papel, empresa_id)
VALUES
    (1, 'Admin', 'admin@bahquadras.com', NULL, '$2a$10$APN7QMwJOiM.XmlAJEs5/e.BHaOTj4fDhSR9txi82QtkZ3xYllcMO', 'admin', NULL),
    (2, 'Joao Silva', 'joao@arena.local', '51999998888', '$2a$10$NEQ.CMuMMJMRTwJEeceOP.bi0hT4lbpDSXAtxIUprZtIJCmKhYIwW', 'cliente', NULL),
    (3, 'Maria Souza', 'maria@arena.local', '51999997777', '$2a$10$NEQ.CMuMMJMRTwJEeceOP.bi0hT4lbpDSXAtxIUprZtIJCmKhYIwW', 'cliente', NULL),
    (4, 'Carlos Mendes', 'contato@arenacentral.com', '51999990000', '$2a$10$.PdgKDbD5DKHB5Dq7oJY5OLZnqa1dtn6QDbXR47I3j6.4/WCmwfQa', 'empresa', 1);


-- >>> 99_inserts/06_solicitacoes_reserva.sql
INSERT INTO solicitacoes_reserva (
    id,
    usuario_id,
    quadra_id,
    status_id,
    data_reserva,
    hora_inicio,
    hora_fim,
    observacao
) VALUES
(1,  2, 1, 2, '2026-10-01', '14:00:00', '15:00:00', 'Reserva 1'),
(2,  3, 1, 2, '2026-10-02', '15:00:00', '16:00:00', 'Reserva 2'),
(3,  2, 1, 2, '2026-10-03', '16:00:00', '17:00:00', 'Reserva 3'),
(23,  1, 1, 3, '2026-10-03', '16:00:00', '17:00:00', 'Reserva 23'),
(4,  3, 1, 3, '2026-10-04', '18:00:00', '19:00:00', 'Reserva 4'),
(5,  2, 1, 1, '2026-10-05', '19:00:00', '20:00:00', 'Reserva 5'),
(21,  1, 1, 1, '2026-10-05', '19:00:00', '20:00:00', 'Reserva 21'),
(22,  3, 1, 3, '2026-10-05', '19:00:00', '20:00:00', 'Reserva 22'),

(6,  3, 1, 1, '2026-10-06', '14:00:00', '15:00:00', 'Reserva 6'),
(7,  2, 1, 1, '2026-10-07', '15:00:00', '16:00:00', 'Reserva 7'),
(8,  3, 1, 3, '2026-10-08', '16:00:00', '17:00:00', 'Reserva 8'),
(9,  2, 1, 1, '2026-10-09', '18:00:00', '19:00:00', 'Reserva 9'),
(10, 3, 1, 1, '2026-10-10', '19:00:00', '20:00:00', 'Reserva 10'),

(11, 2, 2, 3, '2026-10-11', '14:00:00', '15:00:00', 'Reserva 11'),
(12, 3, 2, 1, '2026-10-12', '15:00:00', '16:00:00', 'Reserva 12'),
(13, 2, 2, 3, '2026-10-13', '16:00:00', '17:00:00', 'Reserva 13'),
(14, 3, 2, 1, '2026-10-14', '18:00:00', '19:00:00', 'Reserva 14'),
(15, 2, 2, 1, '2026-10-15', '19:00:00', '20:00:00', 'Reserva 15'),

(16, 3, 2, 3, '2026-10-16', '14:00:00', '15:00:00', 'Reserva 16'),
(17, 2, 2, 1, '2026-10-17', '15:00:00', '16:00:00', 'Reserva 17'),
(18, 3, 2, 3, '2026-10-18', '16:00:00', '17:00:00', 'Reserva 18'),
(19, 2, 2, 1, '2026-10-19', '18:00:00', '19:00:00', 'Reserva 19'),
(20, 3, 2, 1, '2026-10-20', '19:00:00', '20:00:00', 'Reserva 20');

-- >>> 99_inserts/07_reservas.sql
INSERT INTO
    reservas (id, solicitacao_id, status, preco_snapshot)
VALUES
    (1, 1, 'ATIVA', 120),
    (2, 2, 'ATIVA', 120),
    (3, 3, 'ATIVA', 120);


-- >>> 99_inserts/08_bloqueios_quadra.sql
INSERT INTO
    bloqueios_quadra (id, quadra_id, data_inicio, data_fim, motivo)
VALUES
    (
        1,
        1,
        '2026-10-26 08:00:00',
        '2026-10-26 12:00:00',
        'Manutencao preventiva'
    ),
    (
        2,
        2,
        '2026-10-26 08:00:00',
        '2026-10-26 12:00:00',
        'Evento interno'
    );

-- >>> 99_inserts/09_horarios.sql
-- Grade de exemplo (slots de 1 hora) para as quadras 1 e 2:
--   segunda a sexta (1-5): 17h às 22h
--   sábado e domingo (6, 0): 9h às 21h
INSERT INTO horarios (quadra_id, dia_semana, hora_inicio, hora_fim)
SELECT q.id, d.dia, SEC_TO_TIME(h.hora * 3600), SEC_TO_TIME((h.hora + 1) * 3600)
FROM (SELECT 1 AS id UNION ALL SELECT 2) q
CROSS JOIN (SELECT 0 AS dia UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
            UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6) d
CROSS JOIN (SELECT 9 AS hora UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
            UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16
            UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20
            UNION ALL SELECT 21) h
WHERE (d.dia BETWEEN 1 AND 5 AND h.hora BETWEEN 17 AND 21)
   OR (d.dia IN (0, 6) AND h.hora BETWEEN 9 AND 20);

