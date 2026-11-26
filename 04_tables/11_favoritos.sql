-- Quadras favoritas do jogador.
CREATE TABLE favoritos (
        usuario_id BIGINT NOT NULL,
        quadra_id BIGINT NOT NULL,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (usuario_id, quadra_id),
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE,
        FOREIGN KEY (quadra_id) REFERENCES quadras (id)
    );
