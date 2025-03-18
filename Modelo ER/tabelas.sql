-- Criação da tabela Detento
CREATE TABLE Detento (
    cpf VARCHAR2(11) PRIMARY KEY,
    comportamento VARCHAR2(30),
    data_ent DATE,
    sexo char(1),
    data_nasc DATE,
    nome VARCHAR2(30),
    CHECK (sexo IN ('F', 'M')) -- checa se o valor inserido na coluna sexo é 'F' ou 'M' (tem que ser um dos dois) 
);

-- Criação da tabela Sentença
CREATE TABLE Sentenca (
    crime VARCHAR2(30),
    cpf_detento VARCHAR2(11),
    PRIMARY KEY (crime, cpf_detento),
    CONSTRAINT fk_malfeitor FOREIGN KEY (cpf_detento) REFERENCES Detento(cpf) -- constraint é uma restrição que impede a inserção de valores inválidos em uma coluna -> nesse caso, a coluna cpf_detento da tabela Sentenca só pode receber valores que existem na coluna cpf da tabela Detento
);

-- Criação da tabela Crime
CREATE TABLE Crime (
	id_crime NUMBER PRIMARY KEY,
    crime VARCHAR2(30),
	cpf_detento VARCHAR2(11),
    duracao NUMBER,
    CONSTRAINT fk_crime FOREIGN KEY (crime, cpf_detento) REFERENCES Sentenca(crime, cpf_detento),
    CHECK (duracao BETWEEN 1 AND 40) -- checa se a pena está entre 1 e 40 anos (máximo)
);

-- Criação da tabela Visitante -> entidade fraca pq depende de malfeitor (detento visitado) para existir
CREATE TABLE Visitante (
    nome VARCHAR2(30),
    sexo CHAR(1),
    data_nasc DATE,
    malfeitor VARCHAR2(11), -- detento visitado
    PRIMARY KEY (nome, malfeitor),
    CONSTRAINT fk_malfeitor_visitante FOREIGN KEY (malfeitor) REFERENCES Detento(cpf),
    CHECK (sexo IN ('F', 'M'))
);

-- Criação da tabela Tipo_Cela
CREATE TABLE Tipo_Cela (
    tipo_cela VARCHAR2(30) PRIMARY KEY,
    capacidade NUMBER,
    CHECK (capacidade BETWEEN 1 AND 10) -- checa se a capacidade da cela está entre 1 e 10 (máximo)
);

-- Criação da tabela Cela
CREATE TABLE Cela (
    id_cela NUMBER PRIMARY KEY,
    tipo VARCHAR2(15), 
    CONSTRAINT fk_tipo FOREIGN KEY (tipo) REFERENCES Tipo_Cela(tipo_cela),
    CHECK (tipo IN ('SOLITARIA', 'REGULAR')) -- checa se o tipo da cela é 'SOLITARIA' ou 'REGULAR'
);

-- Criação da tabela Endereço -> atributo composto
CREATE TABLE Endereco (
    cep VARCHAR2(10) PRIMARY KEY,
    rua VARCHAR2(30),
    numero NUMBER,
    bairro VARCHAR2(30)
);

-- Criação da tabela Funcionário
CREATE TABLE Funcionario (
    cpf VARCHAR2(11) PRIMARY KEY,
    nome VARCHAR2(30),
    data_nasc DATE,
    sexo CHAR(1),
    salario NUMBER,
    data_admi DATE,
    cep VARCHAR2(10),
    CONSTRAINT fk_endereco FOREIGN KEY (cep) REFERENCES Endereco(cep),
    CHECK (sexo IN ('F', 'M')) 
);

-- Criação da tabela Diretor
CREATE TABLE Diretor (
    cpf_f VARCHAR2(11), 
    codigo NUMBER PRIMARY KEY,
    data_inicio DATE,	
    CONSTRAINT unico_diretor FOREIGN KEY (cpf_f) REFERENCES Funcionario (cpf) -- especialização de funcionário
);

-- Criação da tabela Superintendente
CREATE TABLE Superintendente (
    cpf_f VARCHAR2(11)  PRIMARY KEY,
    bonificacao NUMBER,
    diretor NUMBER,
    CONSTRAINT fk_funcionario FOREIGN KEY (cpf_f) REFERENCES Funcionario(cpf), -- especialização de funcionário
    CONSTRAINT fk_diretor FOREIGN KEY (diretor) REFERENCES Diretor(codigo) -- diretor que coordena o superintendente
);

-- Criação da tabela Ala
CREATE TABLE Ala (
    id NUMBER PRIMARY KEY,
    tipo CHAR(1), 
    nivel_seg VARCHAR2(15), 
    autoridade VARCHAR2(11),
    CONSTRAINT fk_superintendente FOREIGN KEY (autoridade) REFERENCES Superintendente(cpf_f), -- superintendente responsável pela ala (administra)
    CHECK (tipo IN ('F', 'M')),
    CHECK (nivel_seg IN ('MAXIMA', 'MEDIA', 'PADRAO')) -- checa se o nível de segurança da ala é 'MAXIMA', 'MEDIA' ou 'PADRAO'
);

-- Criação da tabela Telefone -> atributo multivalorado
CREATE TABLE Telefone (
    id NUMBER PRIMARY KEY,
    telefone VARCHAR2(15),
    funcionario VARCHAR2(11),
    CONSTRAINT fk_funcionario_telefone FOREIGN KEY (funcionario) REFERENCES Funcionario(cpf) -- telefone de funcionário
);


-- Criação da tabela Guarda
CREATE TABLE Guarda (
    cpf_f VARCHAR2(11) PRIMARY KEY,
    turno VARCHAR2(11),
    supervisionado VARCHAR2(11),
    CONSTRAINT fk_funcionario_guarda FOREIGN KEY (cpf_f) REFERENCES Funcionario(cpf), -- especialização de funcionário
    CONSTRAINT fk_supervisionado FOREIGN KEY (supervisionado) REFERENCES Guarda(cpf_f), -- guarda que supervisiona outro guarda
    CHECK (turno IN ('NOTURNO', 'MATUTINO', 'VESPERTINO')) -- checagem ENUM
);


-- Criação da tabela Sala_visita
CREATE TABLE Sala_visita (
    id NUMBER PRIMARY KEY
);

-- Criação da tabela Visita -> relacionamento que virou entidade
CREATE TABLE Visita (
    motivo VARCHAR2(30),
    malfeitor VARCHAR2(11) PRIMARY KEY,
    data_hora DATE,
    visitante VARCHAR2(30),
    sala_visita NUMBER,
    CONSTRAINT fk_sala_visita FOREIGN KEY (sala_visita) REFERENCES Sala_visita(id), -- sala de visita usada
    CONSTRAINT fk_visitante FOREIGN KEY (visitante) REFERENCES Visitante(nome), -- visitante que visita
    CONSTRAINT fk_malfeitor_visita FOREIGN KEY (malfeitor) REFERENCES Detento(cpf), -- detento visitado
    CHECK (motivo IN ('Amigo(a)', 'Parente', 'Conjuge', 'Outro(a)'))
);

-- Criação da tabela Possui -> relacionamento triplo
CREATE TABLE Possui (
    malfeitor VARCHAR2(11) PRIMARY KEY,
    cela NUMBER,
    ala NUMBER,
    CONSTRAINT fk_malfeitor_possui FOREIGN KEY (malfeitor) REFERENCES Detento(cpf), -- detento que possui ala e cela
    CONSTRAINT fk_cela FOREIGN KEY (cela) REFERENCES Cela(id_cela), -- cela que o detento pertence e está em uma ala
    CONSTRAINT fk_ala FOREIGN KEY (ala) REFERENCES Ala(id) -- ala que o detento pertence e que contém a cela
);
