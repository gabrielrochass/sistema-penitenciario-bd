-- trigger para definir o valor padrão de data_saida como data_ent -> por causa do oracle
DROP TRIGGER trg_set_data_saida;

CREATE OR REPLACE TRIGGER trg_set_data_saida
BEFORE INSERT ON Detento
FOR EACH ROW
BEGIN
    IF :NEW.data_saida IS NULL THEN
        :NEW.data_saida := :NEW.data_ent;
    END IF;
END;
/


-- trigger para atualizar a data de saída
DROP TRIGGER atualizar_data_saida;

CREATE OR REPLACE TRIGGER atualizar_data_saida
AFTER INSERT OR UPDATE OR DELETE ON Sentenca
FOR EACH ROW
DECLARE
    duracao_total NUMBER := 0;
BEGIN
    -- soma todas as durações das sentenças do detento
    SELECT NVL(SUM(duracao), 0) INTO duracao_total
    FROM Sentenca
    WHERE cpf_detento = :NEW.cpf_detento; -- new guarda o valor inserido na coluna cpf_detento no novo registro

    -- atualiza a data de saída somando todos os anos de sentença à data de entrada
    UPDATE Detento
    SET data_saida = ADD_MONTHS(data_ent, duracao_total * 12) -- converte a duracao_total de anos pra meses e adiciona à data de entrada
    WHERE cpf = :NEW.cpf_detento;
END;
/

-- teste: mesmo detento com duas sentenças
select * from Detento;

INSERT INTO Detento (cpf, comportamento, data_ent, data_saida, sexo, data_nasc, nome)
VALUES ('12345678901', 'Bom', TO_DATE('01-01-2020', 'DD-MM-YYYY'), NULL, 'M', TO_DATE('01-01-1985', 'DD-MM-YYYY'), 'João Grilo');

INSERT INTO Sentenca (crime, cpf_detento, duracao)
VALUES ('Roubo', '12345678901', 5); -- 5 anos de sentença

INSERT INTO Sentenca (crime, cpf_detento, duracao)
VALUES ('Fraude', '12345678901', 3); -- +3 anos = total de 8 anos de sentença
