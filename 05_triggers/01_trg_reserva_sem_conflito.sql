DELIMITER $$;
CREATE TRIGGER trg_reserva_sem_conflito
BEFORE INSERT ON reservas
FOR EACH ROW
BEGIN
    DECLARE v_quadra_id BIGINT;
    DECLARE v_data DATE;
    DECLARE v_inicio TIME;
    DECLARE v_fim TIME;
    DECLARE v_conflitos INT DEFAULT 0;

    SELECT sr.quadra_id, sr.data_reserva, sr.hora_inicio, sr.hora_fim
      INTO v_quadra_id, v_data, v_inicio, v_fim
    FROM solicitacoes_reserva sr
    WHERE sr.id = NEW.solicitacao_id;

    SELECT COUNT(*) INTO v_conflitos
    FROM reservas r
    INNER JOIN solicitacoes_reserva sr ON sr.id = r.solicitacao_id
    WHERE r.status='ATIVA'
      AND sr.quadra_id=v_quadra_id
      AND sr.data_reserva=v_data
      AND (v_inicio < sr.hora_fim AND v_fim > sr.hora_inicio);

    IF v_conflitos > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Conflito de horario: quadra ja reservada.';
    END IF;
END$$
DELIMITER ;