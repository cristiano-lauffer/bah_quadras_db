-- SOMENTE DESENVOLVIMENTO: senhas conhecidas para testar cada papel.
--   admin@bahquadras.com    admin123    (admin)
--   joao@arena.local        cliente123  (cliente)
--   maria@arena.local       cliente123  (cliente)
--   contato@arenacentral.com empresa123 (empresa, responsável pela Arena Central)
-- Os ids 2 e 3 são usados pelo seed 06_solicitacoes_reserva.sql.
INSERT INTO
    usuarios (id, nome, email, telefone, senha, papel, empresa_id)
VALUES
    (1, 'Admin', 'admin@bahquadras.com', NULL, '$2a$10$APN7QMwJOiM.XmlAJEs5/e.BHaOTj4fDhSR9txi82QtkZ3xYllcMO', 'admin', NULL),
    (2, 'Joao Silva', 'joao@arena.local', '51999998888', '$2a$10$NEQ.CMuMMJMRTwJEeceOP.bi0hT4lbpDSXAtxIUprZtIJCmKhYIwW', 'cliente', NULL),
    (3, 'Maria Souza', 'maria@arena.local', '51999997777', '$2a$10$NEQ.CMuMMJMRTwJEeceOP.bi0hT4lbpDSXAtxIUprZtIJCmKhYIwW', 'cliente', NULL),
    (4, 'Carlos Mendes', 'contato@arenacentral.com', '51999990000', '$2a$10$.PdgKDbD5DKHB5Dq7oJY5OLZnqa1dtn6QDbXR47I3j6.4/WCmwfQa', 'empresa', 1);
