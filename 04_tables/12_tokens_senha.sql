-- Links de "Esqueci minha senha". Guarda só o hash SHA-256 do token (o token puro vai no link).
CREATE TABLE tokens_senha (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        usuario_id BIGINT NOT NULL,
        token_hash CHAR(64) NOT NULL UNIQUE,
        expira_em DATETIME NOT NULL,
        usado_em DATETIME NULL,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
    );
