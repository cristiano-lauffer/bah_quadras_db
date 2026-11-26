-- Grade semanal de horários da quadra (US5).
-- Cada linha vale para TODA semana naquele dia: dia_semana 0 = domingo ... 6 = sábado.
--   * datas específicas indisponíveis (manutenção, evento) -> bloqueios_quadra
--   * conflito entre reservas                             -> trigger trg_reserva_sem_conflito
CREATE TABLE horarios (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        quadra_id BIGINT NOT NULL,
        dia_semana TINYINT NOT NULL,
        hora_inicio TIME NOT NULL,
        hora_fim TIME NOT NULL,
        ativo BOOLEAN NOT NULL DEFAULT TRUE,  -- FALSE = slot bloqueado pela empresa
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME NULL,
        CONSTRAINT uq_horarios_slot UNIQUE (quadra_id, dia_semana, hora_inicio),
        FOREIGN KEY (quadra_id) REFERENCES quadras (id),
        CHECK (dia_semana BETWEEN 0 AND 6),
        CHECK (hora_fim > hora_inicio)
    );
