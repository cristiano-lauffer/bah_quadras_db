SET NAMES utf8mb4;

INSERT INTO
    quadras (id, empresa_id, tipo_quadra_id, nome, descricao, valor_hora, status, piso, cobertura, capacidade, comodidades, imagem_url)
VALUES
    (1, 1, 1, 'Society 1', 'Campo de grama sintética com iluminação para jogos à noite.', 120, 'ativa',
        'Grama sintética', 'descoberta', 14, '["Vestiário", "Chuveiro", "Iluminação", "Estacionamento"]',
        'https://images.unsplash.com/photo-1522778119026-d647f0596c20?auto=format&fit=crop&w=1000&q=80'),
    (2, 1, 2, 'Beach 1', 'Quadra de areia para beach tennis.', 80, 'ativa',
        'Areia', 'descoberta', 4, '["Iluminação", "Aluguel de materiais"]',
        'https://images.unsplash.com/photo-1592656094267-764a45160876?auto=format&fit=crop&w=1000&q=80');
