-- Criação do banco
CREATE DATABASE IF NOT EXISTS bah_quadras
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE bah_quadras;

-- Tabela de usuários (clientes, empresas e admins)
CREATE TABLE IF NOT EXISTS usuarios (
  id         INT          NOT NULL AUTO_INCREMENT,
  nome       VARCHAR(100) NOT NULL,
  email      VARCHAR(150) NOT NULL,
  senha      VARCHAR(255) NOT NULL,  -- hash bcrypt, nunca senha pura
  papel      ENUM('cliente', 'empresa', 'admin') NOT NULL DEFAULT 'cliente',
  created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  UNIQUE KEY uq_email (email)
);

-- Seed: usuário admin inicial
-- Senha: admin123 (hash gerado com bcrypt, salt 10)
INSERT INTO usuarios (nome, email, senha, papel) VALUES (
  'Admin',
  'admin@bahquadras.com',
  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHHG',
  'admin'
);
