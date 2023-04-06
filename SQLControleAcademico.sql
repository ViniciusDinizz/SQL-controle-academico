CREATE DATABASE SituacaoEscolar;
GO

USE SituacaoEscolar;

CREATE TABLE Aluno (
    [ra] INT UNIQUE NOT NULL,
    [nome] VARCHAR(20) NOT NULL,
    [situacao] VARCHAR(10) NULL,
    [cpf] NUMERIC UNIQUE NOT NULL,
    [sexo] CHAR(1) NOT NULL,

    CONSTRAINT PK_Ra_Aluno PRIMARY KEY ([ra])
)
GO

CREATE TABLE Orientador (
    [cartUnic] NUMERIC UNIQUE NOT NULL,
    [nome] VARCHAR(20) NOT NULL,
    [cnpj] VARCHAR(30) NULL,

    CONSTRAINT PK_CartUnic_Ori PRIMARY KEY ([cartUnic]) 
)
GO

CREATE TABLE Disciplina (
    [materia] VARCHAR(20) NOT NULL,
    [cart_Uni] NUMERIC NOT NULL,
    [carga_Hora] INT NOT NULL,

    CONSTRAINT PK_materia_Disci PRIMARY KEY ([materia]),
    CONSTRAINT FK_Disciplina_Orientdor FOREIGN KEY ([cart_Uni]) REFERENCES Orientador([cartUnic])
)
GO

CREATE TABLE Matricula (
    [num_Mat] INT IDENTITY(1,1) NOT NULL,
    [mat_RaAluno] INT NOT NULL,
    [ano_Mat] INT NOT NULL,
    [semestre] INT NOT NULL,

    CONSTRAINT PK_NumMat_Mat PRIMARY KEY ([num_Mat]),
    CONSTRAINT FK_Matricula_Aluno FOREIGN KEY ([mat_RaAluno]) REFERENCES Aluno([ra]),
    CONSTRAINT UN_Matricula UNIQUE ([mat_RaAluno], [ano_Mat], [semestre])
)
GO

CREATE TABLE DadoMateria (
    [dado_NumMat]  INT NOT NULL,
    [dado_Materia] VARCHAR(20) NOT NULL,
    [faltas] INT NULL,
    [nota1] NUMERIC(4,2) NULL,
    [nota2] NUMERIC(4,2) NULL,
    [recuperacao] NUMERIC(4,2) NULL,
    [status] VARCHAR(19) NULL,

    CONSTRAINT PK_Dado_Materia PRIMARY KEY ([dado_NumMat], [dado_Materia]),
    CONSTRAINT FK_DadoMateria_Matricula FOREIGN KEY (dado_NumMat) REFERENCES Matricula ([num_Mat]),
    CONSTRAINT FK_DadoMateria_Materia FOREIGN KEY ([dado_Materia]) REFERENCES Disciplina([materia])
)

--POPULANDO TABELA COM DADOS PRINCIPAIS/INICIO
INSERT INTO Aluno VALUES (1, 'Vinicius Diniz', 'Matri.' ,43038448885, 'M')
GO

INSERT INTO Aluno VALUES (2, 'Josué', 'Matri.' ,55689562336, 'M')
GO

INSERT INTO Orientador VALUES (556212, 'Marcos Silva', '55913.6548975.231326.0001'), (661278, 'Leandro Ribeiro', '55913.6548975.231326.0001')
GO

INSERT INTO Disciplina VALUES ('Matemática', 556212, 80), ('História', 661278, 80)
GO

INSERT INTO Matricula (mat_RaAluno, ano_Mat, semestre) VALUES (1, 2023, 1), (2, 2023,1)
GO

select * FROM DadoMateria

INSERT INTO DadoMateria (dado_NumMat, dado_Materia) VALUES (2, 'Matemática')
GO

--VIZUALIZAÇÃO
SELECT m.num_Mat'Matricula', a.nome'ALuno', a.ra, dm.faltas,d.materia,o.nome 'Professor', dm.nota1,dm.nota2,DM.recuperacao 'Sub',dm.status
    FROM Aluno a JOIN Matricula m ON a.ra = m.mat_RaAluno
    JOIN DadoMateria dm ON m.num_Mat = dm.dado_NumMat
    JOIN Disciplina d ON dm.dado_Materia = d.materia
    JOIN Orientador o ON d.cart_Uni = o.cartUnic

--POPULANDO NOTAS
UPDATE DadoMateria SET nota1 = 3, nota2 = 5
WHERE dado_NumMat = 1 AND dado_Materia = 'Matemática'
GO

UPDATE DadoMateria SET nota1 = 5, nota2 = 4
WHERE dado_NumMat = 2
GO   

UPDATE DadoMateria SET recuperacao = 4
WHERE dado_NumMat = 2 AND dado_Materia = 'Matemática'
GO

--INTEGRANDO REGRA DE NEGÓCIO PARA MÉDIA DE DOTAS
SELECT m.num_Mat'Matricula', a.nome'Aluno', a.ra, dm.faltas,d.materia,o.nome 'Professor', dm.nota1,dm.nota2,DM.recuperacao 'Sub',dm.status,

    CASE
        WHEN (recuperacao IS NULL) THEN (nota1 + nota2)/2
        WHEN ((nota1 + nota2) >= 10) THEN (nota1 + nota2)/2 
        WHEN (recuperacao > nota1) AND (nota1 < nota2)  THEN (recuperacao+nota2)/2 
        WHEN (recuperacao > nota2) AND (nota2 < nota1) THEN (recuperacao+nota1)/2
    END AS 'Media'
FROM Aluno a JOIN Matricula m ON a.ra = m.mat_RaAluno
    JOIN DadoMateria dm ON m.num_Mat = dm.dado_NumMat
    JOIN Disciplina d ON dm.dado_Materia = d.materia
    JOIN Orientador o ON d.cart_Uni = o.cartUnic

--VIZUALIZAÇÃO
SELECT m.num_Mat 'Matricula', a.nome 'Aluno', dm.dado_Materia 'Disciplina', dm.nota1 '1ª Nota', dm.nota2 '2ª Nota', dm.faltas 'Faltas',dm.status 'Situacao'
FROM Aluno a JOIN Matricula m ON a.ra = m.mat_RaAluno
             JOIN DadoMateria dm ON m.num_Mat = dm.dado_NumMat   

--POPULANDO STATUS/'SITUACAO' 
UPDATE DadoMateria SET [status] = 'Matri.'
WHERE dado_NumMat = 2
GO

UPDATE DadoMateria SET [faltas] = 15
WHERE dado_NumMat = 2 AND dado_Materia = 'Matemática'
GO

--REGRA DE NEGÓCIO PARA DEFINIR SITUACAO FINAL DE SEMESTRE
/*SELECT m.num_Mat 'Matricula', a.nome 'Aluno', dm.dado_Materia 'Disciplina', dm.nota1 '1ª Nota', dm.nota2 '2ª Nota', dm.recuperacao 'Sub.',dm.faltas 'Faltas', dm.Media 'Media',
    CASE
        WHEN (faltas > (carga_Hora * 0.25)) THEN 'Repr./ FALTA'
        WHEN ((nota1 + nota2) < 12) AND (nota1 < nota2) AND (((recuperacao + nota2) / 2) < 6) THEN 'Repr./ NOTA'
        WHEN ((nota1 + nota2) < 12) AND (nota1 > nota2) AND (((nota1 + recuperacao) / 2) < 6) THEN 'Repr./ NOTA'
        ELSE 'Aprov.'
    END AS 'Situacao'

FROM Aluno a JOIN Matricula m ON a.ra = m.mat_RaAluno
             JOIN DadoMateria dm ON m.num_Mat = dm.dado_NumMat
             JOIN Disciplina d ON dm.dado_Materia = d.materia   
*/
UPDATE DadoMateria SET nota1 = 3, nota2 = 5
WHERE dado_NumMat = 2 AND dado_Materia = 'História'
GO

SELECT * FROM DadoMateria
GO