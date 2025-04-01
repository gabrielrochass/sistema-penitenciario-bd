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


-- trigger para atualizar a data de saída: não dá erro da tabela mutante pq usa cursor para percorrer os detentos e não FOR EACH ROW
DROP TRIGGER atualizar_data_saida;

CREATE OR REPLACE TRIGGER atualizar_data_saida
AFTER INSERT OR UPDATE OR DELETE ON Sentenca
DECLARE
    -- cursor para obter todos os detentos com sentenças
    CURSOR c_detentos IS 
        SELECT DISTINCT cpf_detento FROM Sentenca; 
    v_duracao_total NUMBER; -- armazena duração total da sentença
BEGIN
    -- para cada detento com sentença retornado pelo cursor
    FOR detento IN c_detentos LOOP
        -- soma todas as sentenças do detento
        SELECT NVL(SUM(duracao), 0) INTO v_duracao_total
        FROM Sentenca
        WHERE cpf_detento = detento.cpf_detento;

        -- atualiza a data de saída no Detento
        UPDATE Detento
        SET data_saida = LEAST(ADD_MONTHS(data_ent, v_duracao_total * 12), ADD_MONTHS(data_ent, 30 * 12)) -- min entre 30 anos e data_ent + duracao_total
        WHERE cpf = detento.cpf_detento;
    END LOOP;
END;
/


-- teste: outro detento com sentenças diferentes
select * from Detento;

INSERT INTO Detento (cpf, comportamento, data_ent, data_saida, sexo, data_nasc, nome)
VALUES ('98765432100', 'Excelente', TO_DATE('15-03-2021', 'DD-MM-YYYY'), NULL, 'M', TO_DATE('10-10-1990', 'DD-MM-YYYY'), 'Chicó');

select * from Detento;

INSERT INTO Sentenca (crime, cpf_detento, duracao)
VALUES ('Homicídio', '98765432100', 10); -- 10 anos de sentença

select * from Detento;

INSERT INTO Sentenca (crime, cpf_detento, duracao)
VALUES ('Tráfico', '98765432100', 4); -- +4 anos = total de 14 anos de sentença

select * from Detento;

-- delete para testar trigger
DELETE FROM Detento
WHERE nome = 'Chicó';

SELECT * FROM Detento;