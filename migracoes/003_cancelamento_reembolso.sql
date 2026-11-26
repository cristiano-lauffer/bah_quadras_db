-- =====================================================================
-- migracoes/003_cancelamento_reembolso.sql
-- Para quem já aplicou a 002: registra quem cancelou a reserva e o reembolso
-- de reservas pagas que foram canceladas (a devolução é feita pela empresa, por fora).
-- Rodar como root.
-- =====================================================================
SET NAMES utf8mb4;
USE bah_quadras;

ALTER TABLE reservas
  ADD COLUMN cancelada_por ENUM('jogador', 'empresa') NULL AFTER cancelada_em,
  ADD COLUMN reembolso ENUM('pendente', 'feito') NULL AFTER cancelada_por,
  ADD COLUMN reembolsado_em DATETIME NULL AFTER reembolso,
  ADD COLUMN valor_reembolsado DECIMAL(10, 2) NULL AFTER reembolsado_em;
