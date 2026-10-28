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
  id         INT          NOT NULL AUTO_INCREMENT,
  nome       VARCHAR(100) NOT NULL,
  email      VARCHAR(150) NOT NULL,
  senha      VARCHAR(255) NOT NULL,  -- hash bcrypt, nunca senha pura
  papel      ENUM('cliente', 'empresa', 'admin') NOT NULL DEFAULT 'cliente',
  created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL,

  PRIMARY KEY (id),
  UNIQUE KEY uq_email (email)
);