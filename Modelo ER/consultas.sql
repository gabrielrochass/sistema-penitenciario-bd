-- 1. Listar todos os detentos com suas respectivas datas de entrada e saída
SELECT nome, cpf, data_ent, data_saida
FROM Detento;

-- 2. Listar os detentos que possuem comportamento "Bom"
SELECT nome, cpf, comportamento
FROM Detento
WHERE comportamento = 'Bom';

-- 3. Listar os funcionários que possuem salário acima de 2000
SELECT nome, cpf, salario
FROM Funcionario
WHERE salario > 2000;

-- 4. Listar os guardas que trabalham no turno noturno
SELECT cpf_f, turno
FROM Guarda
WHERE turno = 'NOTURNO';

-- 5. Listar as celas do tipo "REGULAR" com suas capacidades
SELECT c.id_cela, c.tipo, t.capacidade
FROM Cela c
JOIN Tipo_Cela t ON c.tipo = t.tipo_cela
WHERE c.tipo = 'REGULAR';

-- 6. Listar os visitantes que visitaram detentos por motivo de "Parente"
SELECT v.visitante, v.malfeitor, v.motivo
FROM Visita v
WHERE v.motivo = 'Parente';

-- 7. Listar os superintendentes e os diretores que os coordenam
SELECT 
    f1.nome AS superintendente_nome, 
    f2.nome AS diretor_nome
FROM Superintendente s
JOIN Diretor d ON s.diretor = d.codigo
JOIN Funcionario f1 ON s.cpf_f = f1.cpf
JOIN Funcionario f2 ON d.cpf_f = f2.cpf
WHERE f1.nome != f2.nome;

-- 8. Listar as alas de segurança máxima e seus respectivos superintendentes
SELECT a.id, a.nivel_seg, a.autoridade, f.nome AS superintendente
FROM Ala a
JOIN Superintendente s ON a.autoridade = s.cpf_f
JOIN Funcionario f ON s.cpf_f = f.cpf
WHERE a.nivel_seg = 'MAXIMA';

-- 9. Listar os detentos e as celas em que estão alocados
SELECT p.malfeitor AS cpf_detento, d.nome, p.cela
FROM Possui p
JOIN Detento d ON p.malfeitor = d.cpf;

-- 10. Listar os funcionários que possuem telefone cadastrado
SELECT f.nome, f.cpf, t.telefone
FROM Funcionario f
JOIN Telefone t ON f.cpf = t.funcionario;

-- 11. Contar o número de detentos por sexo
SELECT sexo, COUNT(*) AS total
FROM Detento
GROUP BY sexo;

-- 12. Listar os detentos com mais de uma sentença registrada (top)
SELECT s.cpf_detento, d.nome , COUNT(*) AS total_sentencas
FROM Sentenca s
JOIN Detento d ON s.cpf_detento = d.cpf
GROUP BY s.cpf_detento, d.nome
HAVING COUNT(*) > 1;

-- 13. Listar os visitantes que visitaram detentos em uma sala específica
SELECT v.visitante, v.malfeitor, v.sala_visita
FROM Visita v
WHERE v.sala_visita = 101;

-- 14. Listar os diretores e suas datas de início de mandato
SELECT d.cpf_f, f.nome, d.data_inicio
FROM Diretor d
JOIN Funcionario f ON d.cpf_f = f.cpf;
