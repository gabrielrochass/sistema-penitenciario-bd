CREATE TABLE TB_DETENTO OF TP_DETENTO (
    CPF PRIMARY KEY,
    CONSTRAINT CHECK_SEXO CHECK (SEXO IN ('F', 'M'))
);
/