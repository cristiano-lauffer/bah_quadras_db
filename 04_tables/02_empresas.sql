CREATE TABLE empresas (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        nome VARCHAR(200) NOT NULL,
        cnpj VARCHAR(20),
        telefone VARCHAR(20),
        endereco VARCHAR(500),
        ativo BOOLEAN NOT NULL DEFAULT TRUE,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME NULL
    );