-- Avaliações das quadras pelos jogadores (uma por jogador e quadra).
-- usuario_id NULL = avaliação de exemplo (seed), sem conta ligada; o nome mostrado fica em autor_nome.
CREATE TABLE avaliacoes (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        quadra_id BIGINT NOT NULL,
        usuario_id BIGINT NULL,
        autor_nome VARCHAR(100) NOT NULL,
        nota TINYINT NOT NULL,
        aspectos JSON,                 -- ex.: ["Iluminação", "Atendimento"]
        texto VARCHAR(1000) NOT NULL,
        util INT NOT NULL DEFAULT 0,   -- quantas pessoas acharam útil
        resposta VARCHAR(1000) NULL,   -- resposta da empresa
        resposta_em DATETIME NULL,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT uq_avaliacoes_jogador UNIQUE (quadra_id, usuario_id),
        FOREIGN KEY (quadra_id) REFERENCES quadras (id),
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE,
        CHECK (nota BETWEEN 1 AND 5)
    );
