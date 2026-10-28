CREATE TABLE reservas (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        solicitacao_id BIGINT NOT NULL UNIQUE,
        status VARCHAR(20) NOT NULL DEFAULT 'ATIVA',

        -- alterar para data_cancelamento
        data_confirmacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (solicitacao_id) REFERENCES solicitacoes_reserva (id),
        CHECK (status IN ('ATIVA', 'CANCELADA'))
    );