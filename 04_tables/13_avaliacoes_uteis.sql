-- Quem marcou cada avaliação como útil (um voto por jogador).
-- O total mostrado é avaliacoes.util (votos de exemplo) + as linhas daqui.
CREATE TABLE avaliacoes_uteis (
        usuario_id BIGINT NOT NULL,
        avaliacao_id BIGINT NOT NULL,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (usuario_id, avaliacao_id),
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE,
        FOREIGN KEY (avaliacao_id) REFERENCES avaliacoes (id) ON DELETE CASCADE
    );
