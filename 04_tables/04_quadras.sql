CREATE TABLE quadras (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        empresa_id BIGINT NOT NULL,
        tipo_quadra_id BIGINT NOT NULL,
        nome VARCHAR(100) NOT NULL,
        descricao VARCHAR(500),
        valor_hora DECIMAL(10, 2) NOT NULL,
        ativa BOOLEAN NOT NULL DEFAULT TRUE,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME NULL,
        FOREIGN KEY (empresa_id) REFERENCES empresas (id),
        FOREIGN KEY (tipo_quadra_id) REFERENCES tipos_quadra (id)
    );