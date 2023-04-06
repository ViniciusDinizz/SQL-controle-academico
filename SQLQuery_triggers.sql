CREATE OR ALTER TRIGGER TGR_Media_Insert ON DadoMateria AFTER UPDATE
AS
BEGIN
    IF(UPDATE (nota2))
    BEGIN
        DECLARE @dado_numMat INT, @dado_Materia VARCHAR(20), @nota1 NUMERIC(4,2), @nota2 NUMERIC (4,2), @media NUMERIC(4,2)

        SELECT @dado_numMat = dado_NumMat, @dado_Materia = dado_Materia, @nota1 = nota1, @nota2 = nota2 FROM inserted

        SET @media = (@nota1 + @nota2) /2

        UPDATE DadoMateria SET Media = @media WHERE dado_NumMat = @dado_numMat AND dado_Materia = @dado_Materia
    END
END;
GO

CREATE OR ALTER TRIGGER TGR_Situacao_Update ON DadoMateria AFTER UPDATE
AS 
BEGIN

    IF(UPDATE (Media))
    BEGIN
        DECLARE @dado_NumMat INT, @dado_Materia VARCHAR(20), @Media NUMERIC(4,2), @status VARCHAR(19)

        SELECT @dado_NumMat = dado_NumMat, @dado_Materia = dado_Materia, @Media = Media FROM inserted

        SELECT @status = CASE
                            WHEN (@Media >= 6) THEN 'Aprovado'
                            ELSE 'Repro./Notas'
                         END                    
    UPDATE DadoMateria SET [status] = @status WHERE dado_Materia = @dado_Materia AND dado_NumMat = @dado_NumMat
    END
END;
GO

CREATE OR ALTER TRIGGER TGR_Situacao_Faltas ON DadoMateria AFTER UPDATE
AS
BEGIN
    IF(UPDATE (faltas))
    BEGIN
        DECLARE @faltas INT, @status VARCHAR(19), @carga INT, @dado_NumMat INT, @dado_Materia VARCHAR(20) , @Media NUMERIC(4,2)
        SELECT @faltas = i.faltas, @dado_Materia = i.dado_Materia, @dado_NumMat = i.dado_NumMat, @status = i.[status], @Media = i.Media 
        FROM inserted i 
        SELECT @carga = D.carga_Hora FROM Disciplina D WHERE D.materia = @dado_Materia

        SET @status = CASE
            WHEN (@faltas > (@carga * 0.25)) 
                    THEN 'Repro./ Faltas'
            WHEN (@faltas < (@carga * 0.25)) AND (@status = 'Repro./ Faltas') AND (@Media = null)
                    THEN 'Matriculado'
            WHEN (@faltas < (@carga * 0.25)) AND (@status = 'Repro./ Faltas') AND (@Media < 6)
                    THEN 'Repro./Notas'
            ELSE 'Aprovado'
        END
        UPDATE DadoMateria SET [status] = @status WHERE dado_NumMat = @dado_NumMat AND dado_Materia = @dado_Materia
    END
END;
GO