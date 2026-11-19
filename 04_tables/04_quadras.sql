CREATE TABLE quadras (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        empresa_id BIGINT NOT NULL,
        tipo_quadra_id BIGINT NOT NULL,
        nome VARCHAR(100) NOT NULL,
        descricao VARCHAR(500),
        valor_hora DECIMAL(10, 2) NOT NULL,
        status ENUM('ativa', 'manutencao', 'inativa') NOT NULL DEFAULT 'ativa',
        piso VARCHAR(50),
        cobertura ENUM('coberta', 'descoberta'),
        capacidade TINYINT UNSIGNED,
        comodidades JSON,              -- lista de textos, ex.: ["Vestiário", "Iluminação"]
        imagem_url VARCHAR(500),
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME NULL,
        FOREIGN KEY (empresa_id) REFERENCES empresas (id),
        FOREIGN KEY (tipo_quadra_id) REFERENCES tipos_quadra (id)
    );