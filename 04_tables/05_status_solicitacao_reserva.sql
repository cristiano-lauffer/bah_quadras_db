CREATE TABLE status_solicitacao_reserva (
        id TINYINT PRIMARY KEY,
        nome VARCHAR(50) NOT NULL UNIQUE,
        descricao VARCHAR(255),
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    );