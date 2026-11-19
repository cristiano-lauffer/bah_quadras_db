-- =====================================================================
-- migracoes/001_integracao_api.sql
-- Para quem JÁ TEM o banco criado com os scripts antigos (antes desta branch):
-- leva o schema ao formato que a bah_quadras_api usa, sem apagar dados.
-- Banco novo? Não precisa disto: use bah_quadras_reset_completo.sql.
-- Rodar como root (o usr_app_bah_quadras não tem permissão de DDL).
--
-- ATENÇÃO: se você já aplicou a branch fix_integracao_api do db, a coluna
-- usuarios.telefone já existe: apague o bloco "1) usuarios.telefone" abaixo.
-- =====================================================================
SET NAMES utf8mb4;   -- garante acentos corretos nos tipos de quadra, qualquer que seja o cliente
USE bah_quadras;

-- 1) usuarios.telefone ------------------------------------------------
-- O cadastro de cliente do front envia celular; a API grava só os dígitos (10 ou 11).
ALTER TABLE usuarios
  ADD COLUMN telefone VARCHAR(20) NULL AFTER email;

-- 2) usuarios.empresa_id ----------------------------------------------
-- Liga o login do responsável à empresa dele. Sem isso o login da empresa
-- (US2) não sabe de quem são as quadras, e o POST /admin/empresas falha.
ALTER TABLE usuarios
  ADD COLUMN empresa_id BIGINT NULL AFTER papel,
  ADD CONSTRAINT fk_usuarios_empresa FOREIGN KEY (empresa_id) REFERENCES empresas (id);

-- 3) empresas.cnpj único ----------------------------------------------
-- A API devolve 409 "Este CNPJ já está cadastrado" a partir deste índice.
ALTER TABLE empresas
  ADD CONSTRAINT uq_empresas_cnpj UNIQUE (cnpj);

-- 4) quadras: status e os campos que a tela de quadra já tem ----------
-- "ativa BOOLEAN" vira "status" (ativa | manutencao | inativa), como no front.
ALTER TABLE quadras
  ADD COLUMN status     ENUM('ativa', 'manutencao', 'inativa') NOT NULL DEFAULT 'ativa' AFTER valor_hora,
  ADD COLUMN piso       VARCHAR(50)  NULL,
  ADD COLUMN cobertura  ENUM('coberta', 'descoberta') NULL,
  ADD COLUMN capacidade TINYINT UNSIGNED NULL,
  ADD COLUMN comodidades JSON NULL,
  ADD COLUMN imagem_url VARCHAR(500) NULL;

UPDATE quadras SET status = IF(ativa, 'ativa', 'inativa');
ALTER TABLE quadras DROP COLUMN ativa;

-- 5) horarios: grade semanal (US5) ------------------------------------
-- Cada linha vale para toda semana naquele dia. dia_semana: 0 = domingo ... 6 = sábado.
CREATE TABLE IF NOT EXISTS horarios (
  id          BIGINT NOT NULL AUTO_INCREMENT,
  quadra_id   BIGINT NOT NULL,
  dia_semana  TINYINT NOT NULL,
  hora_inicio TIME NOT NULL,
  hora_fim    TIME NOT NULL,
  ativo       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME NULL,
  PRIMARY KEY (id),
  CONSTRAINT uq_horarios_slot UNIQUE (quadra_id, dia_semana, hora_inicio),
  CONSTRAINT fk_horarios_quadra FOREIGN KEY (quadra_id) REFERENCES quadras (id),
  CONSTRAINT chk_horarios_dia CHECK (dia_semana BETWEEN 0 AND 6),
  CONSTRAINT chk_horarios_periodo CHECK (hora_fim > hora_inicio)
);

-- 6) reservas.preco_snapshot (US6) -------------------------------------
-- Preço da época: o endpoint de criar reserva (ainda não existe) deve gravar aqui o valor_hora.
ALTER TABLE reservas
  ADD COLUMN preco_snapshot DECIMAL(10, 2) NULL AFTER status;

-- 7) tipos de quadra do front -------------------------------------------
-- O select de modalidade do front tem 8 opções; o banco só tinha 2.
INSERT IGNORE INTO tipos_quadra (descricao) VALUES
  ('Futsal'), ('Vôlei'), ('Vôlei de Areia'), ('Basquete'), ('Tênis'), ('Padel');

-- 8) trigger --------------------------------------------------------------
-- O script antigo (DELIMITER $$;) falhava e o trigger não era criado.
-- Depois desta migração, rode também:  mysql -u root -p bah_quadras < 05_triggers/01_trg_reserva_sem_conflito.sql
