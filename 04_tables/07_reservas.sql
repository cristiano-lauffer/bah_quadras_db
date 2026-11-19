CREATE TABLE reservas (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        solicitacao_id BIGINT NOT NULL UNIQUE,
        status VARCHAR(20) NOT NULL DEFAULT 'ATIVA',
        preco_snapshot DECIMAL(10, 2) NULL,  -- valor_hora da quadra no momento da reserva (US6)
        valor_total DECIMAL(10, 2) NULL,     -- preço x horas (ou x baterias no kart)
        forma_pagamento VARCHAR(20) NULL,    -- Pix, Cartão ou Dinheiro (pago no local)
        pago BOOLEAN NOT NULL DEFAULT FALSE,
        origem ENUM('app', 'balcao') NOT NULL DEFAULT 'app',
        baterias TINYINT UNSIGNED NULL,      -- kart: baterias dentro do horário reservado
        minutos_bateria TINYINT UNSIGNED NULL,
        cancelada_em DATETIME NULL,
        remarcada_em DATETIME NULL,
        data_anterior DATE NULL,             -- dia e hora antes da última remarcação
        hora_anterior TIME NULL,

        -- alterar para data_cancelamento
        data_confirmacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (solicitacao_id) REFERENCES solicitacoes_reserva (id),
        CHECK (status IN ('ATIVA', 'CANCELADA'))
    );