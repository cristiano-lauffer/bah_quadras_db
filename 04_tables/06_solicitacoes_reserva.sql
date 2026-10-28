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