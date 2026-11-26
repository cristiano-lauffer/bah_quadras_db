CREATE TABLE empresas (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        nome VARCHAR(200) NOT NULL,
        cnpj VARCHAR(20) UNIQUE,       -- só dígitos; a API devolve 409 se repetir
        telefone VARCHAR(20),
        endereco VARCHAR(500),
        perfil JSON,                   -- vitrine da empresa: descrição, contatos, endereço detalhado, horário de funcionamento,
                                       -- formas de pagamento, política de cancelamento, logo, capa e fotos
        ativo BOOLEAN NOT NULL DEFAULT TRUE,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME NULL
    );

-- Usuário responsável pela empresa (papel 'empresa').
-- Fica aqui porque 01_usuarios.sql roda antes de existir a tabela empresas.
ALTER TABLE usuarios
    ADD CONSTRAINT fk_usuarios_empresa FOREIGN KEY (empresa_id) REFERENCES empresas (id);
