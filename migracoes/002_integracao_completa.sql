-- =====================================================================
-- migracoes/002_integracao_completa.sql
-- Para quem JÁ TEM o banco no formato da 001_integracao_api.sql:
-- acrescenta o que a integração completa do front usa (reservas pela API,
-- avaliações, favoritas, perfil da empresa, dados do jogador e recuperação de senha).
-- Não apaga dados e NÃO insere os dados de demonstração (para eles, use o reset completo).
-- Rodar como root (o usr_app_bah_quadras não tem permissão de DDL).
-- =====================================================================
SET NAMES utf8mb4;
USE bah_quadras;

-- 1) usuarios: dados do jogador e avisos lidos -------------------------
ALTER TABLE usuarios
  ADD COLUMN cidade VARCHAR(100) NULL AFTER empresa_id,
  ADD COLUMN esportes JSON NULL AFTER cidade,
  ADD COLUMN preferencias JSON NULL AFTER esportes,
  ADD COLUMN notificacoes_lidas JSON NULL AFTER preferencias,
  ADD COLUMN foto_url VARCHAR(500) NULL AFTER notificacoes_lidas;

-- 2) empresas: perfil da vitrine ----------------------------------------
ALTER TABLE empresas
  ADD COLUMN perfil JSON NULL AFTER endereco;

-- 3) quadras: galeria, destaque e cobrança por bateria (kart) -----------
ALTER TABLE quadras
  ADD COLUMN imagens JSON NULL AFTER imagem_url,
  ADD COLUMN destaque BOOLEAN NOT NULL DEFAULT FALSE AFTER imagens,
  ADD COLUMN cobranca ENUM('hora', 'bateria') NOT NULL DEFAULT 'hora' AFTER destaque,
  ADD COLUMN minutos_bateria TINYINT UNSIGNED NULL AFTER cobranca,
  ADD COLUMN mapa VARCHAR(255) NULL AFTER minutos_bateria;

-- 4) solicitacoes_reserva: reservas de balcão (sem conta) ---------------
ALTER TABLE solicitacoes_reserva
  MODIFY COLUMN usuario_id BIGINT NULL,
  ADD COLUMN cliente_nome VARCHAR(100) NULL AFTER usuario_id;

-- 5) reservas: valor, pagamento, origem, cancelamento e remarcação ------
ALTER TABLE reservas
  ADD COLUMN valor_total DECIMAL(10, 2) NULL AFTER preco_snapshot,
  ADD COLUMN forma_pagamento VARCHAR(20) NULL AFTER valor_total,
  ADD COLUMN pago BOOLEAN NOT NULL DEFAULT FALSE AFTER forma_pagamento,
  ADD COLUMN origem ENUM('app', 'balcao') NOT NULL DEFAULT 'app' AFTER pago,
  ADD COLUMN baterias TINYINT UNSIGNED NULL AFTER origem,
  ADD COLUMN minutos_bateria TINYINT UNSIGNED NULL AFTER baterias,
  ADD COLUMN cancelada_em DATETIME NULL AFTER minutos_bateria,
  ADD COLUMN remarcada_em DATETIME NULL AFTER cancelada_em,
  ADD COLUMN data_anterior DATE NULL AFTER remarcada_em,
  ADD COLUMN hora_anterior TIME NULL AFTER data_anterior;

-- Reservas antigas: valor = preço da época x horas
UPDATE reservas r
  JOIN solicitacoes_reserva s ON s.id = r.solicitacao_id
  SET r.valor_total = r.preco_snapshot * TIME_TO_SEC(TIMEDIFF(s.hora_fim, s.hora_inicio)) / 3600
  WHERE r.valor_total IS NULL AND r.preco_snapshot IS NOT NULL;

-- 6) novas tabelas ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS avaliacoes (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  quadra_id BIGINT NOT NULL,
  usuario_id BIGINT NULL,
  autor_nome VARCHAR(100) NOT NULL,
  nota TINYINT NOT NULL,
  aspectos JSON,
  texto VARCHAR(1000) NOT NULL,
  util INT NOT NULL DEFAULT 0,
  resposta VARCHAR(1000) NULL,
  resposta_em DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_avaliacoes_jogador UNIQUE (quadra_id, usuario_id),
  FOREIGN KEY (quadra_id) REFERENCES quadras (id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE,
  CHECK (nota BETWEEN 1 AND 5)
);

CREATE TABLE IF NOT EXISTS favoritos (
  usuario_id BIGINT NOT NULL,
  quadra_id BIGINT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (usuario_id, quadra_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE,
  FOREIGN KEY (quadra_id) REFERENCES quadras (id)
);

CREATE TABLE IF NOT EXISTS tokens_senha (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  usuario_id BIGINT NOT NULL,
  token_hash CHAR(64) NOT NULL UNIQUE,
  expira_em DATETIME NOT NULL,
  usado_em DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS avaliacoes_uteis (
  usuario_id BIGINT NOT NULL,
  avaliacao_id BIGINT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (usuario_id, avaliacao_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE,
  FOREIGN KEY (avaliacao_id) REFERENCES avaliacoes (id) ON DELETE CASCADE
);

-- 7) modalidades novas ------------------------------------------------------
INSERT IGNORE INTO tipos_quadra (descricao) VALUES
  ('Badminton'), ('Esportes de Areia'), ('Futebol 7'), ('Futebol 11'), ('Kart');
