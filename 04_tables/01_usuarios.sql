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
  cidade     VARCHAR(100) NULL,      -- "Porto Alegre/RS" (Meus dados do jogador)
  esportes   JSON NULL,              -- modalidades favoritas do jogador, ex.: ["Futsal"]
  preferencias JSON NULL,            -- avisos por e-mail: { lembrete, confirmacao, novidades }
  notificacoes_lidas JSON NULL,      -- ids dos avisos já lidos no site
  foto_url   VARCHAR(500) NULL,      -- foto de perfil (enviada pelo POST /uploads da API)
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,

  PRIMARY KEY (id),
  UNIQUE KEY uq_email (email)
);