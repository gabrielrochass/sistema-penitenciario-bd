-- Renomeia a tabela Detento para Presidiario
ALTER TABLE Detento
rename to Presidiario;

-- Renomeia a tabela Presidiario de volta para Detento
ALTER TABLE Presidiario
rename to Detento;

-- Cria um índice na coluna nome da tabela Visitante
CREATE INDEX idx_nome_visitante ON Visitante(nome);

-- Atualiza o comportamento para 'Excelente' do detento com CPF específico
UPDATE Detento
SET comportamento = 'Excelente'
WHERE cpf = '92210987654';

-- Deleta o funcionário com o nome específico
DELETE FROM Funcionario
WHERE nome = '01234567890';

-- Seleciona todas as colunas da tabela Ala onde o nível de segurança é 'PADRAO'
SELECT * FROM Ala
WHERE nivel_seg = 'PADRAO';

-- Seleciona id_crime, crime e duração da tabela Crime onde a duração está entre 5 e 10
SELECT id_crime, crime, duracao
FROM Crime
WHERE duracao BETWEEN 5 AND 10;

-- Seleciona nome e cpf dos detentos com CPF específico
SELECT nome, cpf
FROM Detento
WHERE cpf IN ('12345678901', '80098765432', '92210987654');

-- Seleciona nome e cpf dos detentos cujo nome começa com 'Jo'
SELECT nome, cpf
FROM Detento
WHERE nome LIKE 'Jo%';

-- Seleciona cpf e nome dos funcionários cujo CEP não é nulo
SELECT cpf, nome
FROM Funcionario
WHERE cep IS NOT NULL;

-- Seleciona nome dos detentos e crime da tabela Sentenca onde há correspondência de CPF
SELECT D.nome, S.crime
FROM Detento D
INNER JOIN Sentenca S ON D.cpf = S.cpf_detento;

-- Seleciona a duração máxima dos crimes
SELECT MAX(duracao) AS duracao_maxima
FROM Crime;

-- Seleciona o salário mínimo dos funcionários
SELECT MIN(salario) AS salario_minimo
FROM Funcionario;

-- Seleciona o salário médio dos funcionários
SELECT AVG(salario) AS salario_medio
FROM Funcionario;

-- Seleciona bonificação e cpf_f da tabela Diretor e Superintendente com junção externa completa
SELECT S.bonificacao, D.cpf_f 
FROM DIRETOR D
FULL OUTER JOIN Superintendente S ON S.cpf_f = D.cpf_f;

-- Seleciona nome e cpf dos detentos que estão na cela com menor id
SELECT nome, cpf
FROM Detento
WHERE cpf IN (
    SELECT malfeitor
    FROM Possui
    WHERE cela = (
        SELECT MIN(id_cela)
        FROM Cela
    )
);

-- Seleciona nome e cpf dos detentos que são visitantes
SELECT nome, cpf
FROM Detento
WHERE cpf IN (
    SELECT malfeitor
    FROM Visitante
);

-- Seleciona nome e cpf dos detentos cujo crime tem duração maior que a média
SELECT nome, cpf
FROM Detento
WHERE cpf IN (
    SELECT cpf_detento
    FROM Crime
    WHERE duracao > ANY (
        SELECT AVG(duracao)
        FROM Crime
    )
);

-- Seleciona nome e cpf dos detentos cujo crime tem duração maior que todos os outros crimes
SELECT nome, cpf
FROM Detento
WHERE cpf IN (
    SELECT cpf_detento
    FROM Crime
    WHERE duracao > ALL (
        SELECT duracao
        FROM Crime
        WHERE cpf_detento <> Crime.cpf_detento)
);

-- Seleciona cpf e soma do salário dobrado dos funcionários com soma menor que 10000
SELECT cpf, SUM(salario * 2) AS total_salario_dobrado 
FROM Funcionario 
GROUP BY cpf 
HAVING SUM(salario * 2) < 10000;

-- Seleciona cpf, nome e valores nulos para data_ent e comportamento de detentos e funcionários
SELECT cpf, nome, NULL AS data_ent, NULL AS comportamento
FROM Detento
UNION
SELECT cpf, nome, NULL AS data_ent, NULL AS comportamento
FROM Funcionario;

-- Cria uma view para visualizar detentos com data de entrada entre 01/01/2024 e 31/01/2024
CREATE VIEW visualizar_detentos AS 
SELECT NOME, CPF  
FROM DETENTO 
WHERE DATA_ENT BETWEEN TO_DATE('2024-01-01', 'YYYY-MM-DD') AND TO_DATE('2024-01-31', 'YYYY-MM-DD');

-- Declara um record para armazenar nome e cpf de um detento específico e exibe esses valores
DECLARE
    TYPE r_detento_type 
    IS 
    RECORD (
        nome Detento.nome%TYPE,
        cpf Detento.cpf%TYPE
    );
    r_detento_info r_detento_type;
BEGIN
    SELECT nome, cpf INTO r_detento_info
    FROM Detento
    WHERE cpf = '95543210987';
    
    DBMS_OUTPUT.PUT_LINE('Nome: ' || r_detento_info.nome || ' CPF: ' || r_detento_info.cpf);
END;

-- Declara uma tabela associativa para armazenar nomes de detentos e exibe esses nomes
DECLARE
    TYPE tabela_nome IS TABLE OF Detento.nome%TYPE INDEX BY PLS_INTEGER;
    nomes tabela_nome;
    i PLS_INTEGER := 1;
BEGIN
    FOR pessoa IN (SELECT nome FROM Detento) LOOP
        nomes(i) := pessoa.nome;
        i := i + 1;
    END LOOP;
    
    FOR presidiario IN 1..nomes.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Nome: ' || nomes(presidiario));
    END LOOP;
END;

-- Exibe uma mensagem indicando que um bloco anônimo foi criado
BEGIN
    DBMS_OUTPUT.PUT_LINE('Bloco anônimo criado.');
END;

-- Cria uma procedure que imprime os dados de uma sala de visita específica
CREATE OR REPLACE PROCEDURE imprimir_salas (
    id_Sala_visita NUMBER
)     
IS
    r_salas Sala_visita%ROWTYPE;
BEGIN
  -- Buscando os dados da sala especificada
  SELECT *
  INTO r_salas
  FROM Sala_visita
  WHERE id = id_Sala_visita;

  -- Exibindo os valores dos campos
  dbms_output.put_line('ID da Sala: ' || r_salas.id);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Nenhuma sala encontrada com esse ID. Lembre que só existem salas de 101 - 110');
   WHEN OTHERS THEN
      dbms_output.put_line('Erro: ' || SQLERRM);
END;

-- Cria uma função que calcula o salário anual com base no salário mensal
CREATE OR REPLACE FUNCTION calcular_salario_anual(salario_mensal IN NUMBER) 
RETURN NUMBER 
IS
    salario_anual NUMBER;
BEGIN
    salario_anual := salario_mensal * 13;
    RETURN salario_anual;
END;

-- Declara variáveis para calcular e exibir o salário anual usando a função calcular_salario_anual
DECLARE
    salario NUMBER := 3000;
    salario_total NUMBER;
BEGIN
    salario_total := calcular_salario_anual(salario);
    DBMS_OUTPUT.PUT_LINE('Salário anual: ' || salario_total);
END;

-- Declara variáveis para armazenar nome e salário de um funcionário específico e exibe esses valores
DECLARE
    v_nome       Funcionario.nome%TYPE;
    v_salario    Funcionario.salario%TYPE;
BEGIN
    SELECT nome, salario 
    INTO v_nome, v_salario 
    FROM Funcionario 
    WHERE cpf = '23456789012';
    
    DBMS_OUTPUT.PUT_LINE('Nome: ' || v_nome);
    DBMS_OUTPUT.PUT_LINE('Salário: ' || v_salario);
END;

-- Declara uma variável para armazenar uma linha da tabela Funcionario e exibe os valores dos campos
DECLARE
    v_fun Funcionario%ROWTYPE;
BEGIN
    SELECT * INTO v_fun 
    FROM Funcionario 
    WHERE cpf = '23456789012';
    
    DBMS_OUTPUT.PUT_LINE('Nome: ' || v_fun.nome);
    DBMS_OUTPUT.PUT_LINE('Salário: ' || v_fun.salario);
    DBMS_OUTPUT.PUT_LINE('Data de Nascimento: ' || TO_CHAR(v_fun.data_nasc, 'DD/MM/YYYY'));
    DBMS_OUTPUT.PUT_LINE('Sexo: ' || v_fun.sexo);
    DBMS_OUTPUT.PUT_LINE('Data de Admissão: ' || TO_CHAR(v_fun.data_admi, 'DD/MM/YYYY'));
    DBMS_OUTPUT.PUT_LINE('CEP: ' || v_fun.cep);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nenhum funcionário encontrado com o CPF informado.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
END;

-- Cria uma função que determina a categoria salarial com base no salário e exibe a categoria
CREATE OR REPLACE FUNCTION categoria_salarial(salario IN NUMBER)
RETURN VARCHAR2
IS
    categoria VARCHAR2(20);
BEGIN
    IF salario < 2000 THEN
        categoria := 'Abaixo da média';
    ELSIF salario BETWEEN 2000 AND 4000 THEN
        categoria := 'Na média';
    ELSE
        categoria := 'Acima da média';
    END IF;
    RETURN categoria;
END;

-- Declara variáveis para calcular a categoria salarial e exibe o resultado
DECLARE
    salario NUMBER := 2500;
    resultado VARCHAR2(20);
BEGIN
    resultado := categoria_salarial(salario);
    DBMS_OUTPUT.PUT_LINE('Categoria salarial: ' || resultado);
END;

-- Declara um cursor para selecionar cpf, nome e salário dos funcionários e exibe essas informações
DECLARE
    CURSOR funcionario_cursor IS
        SELECT cpf, nome, salario
        FROM Funcionario;
    
    v_funcionario funcionario_cursor%ROWTYPE;
    v_categoria VARCHAR2(20);
BEGIN
    OPEN funcionario_cursor;
    
    LOOP
        FETCH funcionario_cursor INTO v_funcionario;
        EXIT WHEN funcionario_cursor%NOTFOUND;
        v_categoria := categoria_salarial(v_funcionario.salario);
        DBMS_OUTPUT.PUT_LINE('CPF: ' || v_funcionario.cpf);
        DBMS_OUTPUT.PUT_LINE('Nome: ' || v_funcionario.nome);
        DBMS_OUTPUT.PUT_LINE('Salário: ' || v_funcionario.salario);
        DBMS_OUTPUT.PUT_LINE('Categoria salarial: ' || v_categoria);
        DBMS_OUTPUT.PUT_LINE('---------------------------------------');
    END LOOP;   
    -- Fecha o cursor após o processamento
    CLOSE funcionario_cursor;
END;

-- Declara variáveis para armazenar o tipo de cela e exibe uma mensagem baseada no tipo
DECLARE
    v_tipo VARCHAR2(15);
    v_mensagem VARCHAR2(100);
BEGIN
    SELECT tipo INTO v_tipo FROM Cela WHERE id_cela = 49; -- Exemplo com cela de ID 49

    v_mensagem := CASE 
                    WHEN v_tipo = 'SOLITARIA' THEN 'Cela de isolamento para criminosos que apresentaram comportamento violento, Protocolo X401087@.'
                    WHEN v_tipo = 'REGULAR' THEN 'Cela regular, Protocolo 99#.'
                    ELSE 'Tipo de cela desconhecido.'
                  END;

    DBMS_OUTPUT.PUT_LINE(v_mensagem);
END;

-- Declara variáveis para armazenar o nome de um detento com bom comportamento e exibe o nome
DECLARE
    v_comportamento VARCHAR2(35);
    v_nome Detento.nome%TYPE;
BEGIN
    FOR r IN (SELECT nome, comportamento FROM Detento) LOOP
        IF r.comportamento = 'Bom' THEN
            v_nome := r.nome;
            EXIT; -- Sai do loop ao encontrar o primeiro detento com comportamento 'Bom'
        END IF;
    END LOOP;

    IF v_nome IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Presidiário com bom comportamento: ' || v_nome);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nenhum detento com comportamento Bom encontrado.');
    END IF;
END;

-- Declara variáveis para calcular o salário médio e incrementa os salários enquanto o salário médio for menor que 3000
DECLARE
    v_avg_salary NUMBER;
    v_increment NUMBER := 100; -- Valor do incremento do salário
BEGIN
    -- Calcula o salário médio inicial
    SELECT AVG(salario) INTO v_avg_salary FROM Funcionario;

    -- Enquanto o salário médio for menor que 3000, continue incrementando
    WHILE v_avg_salary < 3000 LOOP
        -- Incrementa os salários
        IF (v_avg_salary < 1800) THEN
            UPDATE Funcionario
            SET salario = salario + v_increment;
            
            -- Recalcula o salário médio
            SELECT AVG(salario) INTO v_avg_salary FROM Funcionario;
            DBMS_OUTPUT.PUT_LINE('Novo salário médio: ' || v_avg_salary);
        ELSE 
            v_avg_salary := 3000;
        END IF;
    END LOOP;
END;

-- Declara um loop para exibir os crimes e CPFs dos detentos
DECLARE 
BEGIN
    FOR r IN (SELECT crime, cpf_detento FROM Sentenca) LOOP
        DBMS_OUTPUT.PUT_LINE('Crime: ' || r.crime || ' | CPF Detento: ' || r.cpf_detento);
    END LOOP;
END;

-- Declara variáveis para armazenar nome, CPF e comportamento de um detento e exibe esses valores
DECLARE
    v_nome Detento.nome%TYPE;
    v_cpf Detento.cpf%TYPE;
    v_comportamento Detento.comportamento%TYPE;
BEGIN
    SELECT nome, cpf, comportamento 
    INTO v_nome, v_cpf, v_comportamento
    FROM Detento
    WHERE ROWNUM = 1;

    DBMS_OUTPUT.PUT_LINE('Nome: ' || v_nome);
    DBMS_OUTPUT.PUT_LINE('CPF: ' || v_cpf);
    DBMS_OUTPUT.PUT_LINE('Comportamento: ' || v_comportamento);
END;

-- Declara variáveis para inserir um novo detento e trata exceções
DECLARE
    v_cpf Detento.cpf%TYPE := '12345678901';
    v_nome Detento.nome%TYPE := 'João Silva';
BEGIN
    -- Tentativa de inserção de um detento
    INSERT INTO Detento (cpf, nome, sexo, data_nasc, data_ent)
    VALUES (v_cpf, v_nome, 'M', TO_DATE('1990-01-01', 'YYYY-MM-DD'), SYSDATE);

    DBMS_OUTPUT.PUT_LINE('Detento inserido com sucesso!');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Erro: CPF já cadastrado.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro inesperado: ' || SQLERRM);
END;

-- Cria uma procedure que obtém dados de um detento com base no CPF e exibe esses dados
CREATE OR REPLACE PROCEDURE obter_dados_detento (
    p_cpf IN Detento.cpf%TYPE,
    p_nome OUT Detento.nome%TYPE,
    p_comportamento OUT Detento.comportamento%TYPE
)
IS
BEGIN
    SELECT nome, comportamento
    INTO p_nome, p_comportamento
    FROM Detento
    WHERE cpf = p_cpf;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Nenhum detento encontrado com o CPF: ' || p_cpf);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro inesperado: ' || SQLERRM);
END;

-- Cria um pacote para inserir e obter dados de detentos
CREATE OR REPLACE PACKAGE detento_pkg AS
    PROCEDURE inserir_detento(
        p_cpf IN Detento.cpf%TYPE,
        p_nome IN Detento.nome%TYPE,
        p_sexo IN Detento.sexo%TYPE,
        p_data_nasc IN Detento.data_nasc%TYPE,
        p_data_ent IN Detento.data_ent%TYPE
    );

    FUNCTION obter_nome_detento(p_cpf IN Detento.cpf%TYPE) RETURN Detento.nome%TYPE;
END detento_pkg;

-- Implementa o corpo do pacote detento_pkg
CREATE OR REPLACE PACKAGE BODY detento_pkg AS
    PROCEDURE inserir_detento(
        p_cpf IN Detento.cpf%TYPE,
        p_nome IN Detento.nome%TYPE,
        p_sexo IN Detento.sexo%TYPE,
        p_data_nasc IN Detento.data_nasc%TYPE,
        p_data_ent IN Detento.data_ent%TYPE
    ) IS
    BEGIN
        INSERT INTO Detento (cpf, nome, sexo, data_nasc, data_ent)
        VALUES (p_cpf, p_nome, p_sexo, p_data_nasc, p_data_ent);

        DBMS_OUTPUT.PUT_LINE('Detento inserido com sucesso!');
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Erro: CPF já cadastrado.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro inesperado: ' || SQLERRM);
    END inserir_detento;

    FUNCTION obter_nome_detento(p_cpf IN Detento.cpf%TYPE) RETURN Detento.nome%TYPE IS
        v_nome Detento.nome%TYPE;
    BEGIN
        SELECT nome INTO v_nome FROM Detento WHERE cpf = p_cpf;
        RETURN v_nome;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Nenhum detento encontrado com o CPF: ' || p_cpf);
            RETURN NULL;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro inesperado: ' || SQLERRM);
            RETURN NULL;
    END obter_nome_detento;
END detento_pkg;

-- Cria um trigger para verificar a capacidade da cela antes de inserir um novo detento
CREATE OR REPLACE TRIGGER trg_limite_cela
BEFORE INSERT ON Possui
DECLARE
    v_capacidade NUMBER;
    v_ocupantes NUMBER;
    v_cela Possui.cela%TYPE;
BEGIN
    -- Cursor para iterar sobre as novas inserções
    FOR r IN (SELECT cela FROM Possui WHERE ROWID IN (SELECT ROWID FROM Possui WHERE ROWNUM = 1)) LOOP
        v_cela := r.cela;

        SELECT capacidade INTO v_capacidade 
        FROM Tipo_Cela 
        WHERE tipo_cela = (SELECT tipo FROM Cela WHERE id_cela = v_cela);

        SELECT COUNT(*) INTO v_ocupantes 
        FROM Possui 
        WHERE cela = v_cela;

        -- Verificar se a capacidade será excedida
        IF v_ocupantes >= v_capacidade THEN
            RAISE_APPLICATION_ERROR(-20001, 'A cela ' || v_cela || ' já atingiu sua capacidade máxima.');
        END IF;
    END LOOP;
END trg_limite_cela;

-- Cria um trigger para verificar a capacidade da cela antes de inserir um novo detento (linha por linha)
CREATE OR REPLACE TRIGGER trg_limite_cela_linha
BEFORE INSERT ON Possui
FOR EACH ROW
DECLARE
    v_capacidade NUMBER;
    v_ocupantes NUMBER;
BEGIN
    -- Obter a capacidade da cela
    SELECT capacidade INTO v_capacidade 
    FROM Tipo_Cela 
    WHERE tipo_cela = (SELECT tipo FROM Cela WHERE id_cela = :NEW.cela);

    -- Contar o número de detentos na cela
    SELECT COUNT(*) INTO v_ocupantes 
    FROM Possui 
    WHERE cela = :NEW.cela;

    -- Verificar se a capacidade foi excedida
    IF v_ocupantes >= v_capacidade THEN
        RAISE_APPLICATION_ERROR(-20001, 'A cela já atingiu sua capacidade máxima.');
    END IF;
END trg_limite_cela_linha;
