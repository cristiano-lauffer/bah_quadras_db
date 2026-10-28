CREATE TABLE bloqueios_quadra (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        quadra_id BIGINT NOT NULL,
        data_inicio DATETIME NOT NULL,
        data_fim DATETIME NOT NULL,
        motivo VARCHAR(255) NOT NULL,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (quadra_id) REFERENCES quadras (id),
        CHECK (data_fim > data_inicio)
    );

CREATE INDEX idx_bloqueios_quadra_periodo ON bloqueios_quadra (quadra_id, data_inicio, data_fim);