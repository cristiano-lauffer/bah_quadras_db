SET NAMES utf8mb4;

-- Endereço no formato "Rua, número - Bairro, Cidade/UF": o front separa bairro e cidade a partir dele.
INSERT INTO
    empresas (id, nome, cnpj, telefone, endereco)
VALUES
    (1, 'Arena Central', '12345678000195', '51999990000', 'Av. Ipiranga, 6681 - Partenon, Porto Alegre/RS');
