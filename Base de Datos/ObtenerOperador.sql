CREATE FUNCTION dbo.ObtenerOperador (@inNumeroTelefono VARCHAR(16))
RETURNS INT
AS
BEGIN
    
	DECLARE @IDOperador INT;

	SELECT @IDOperador = O.ID
	FROM dbo.Operador O
	WHERE O.DigitoPrefijoPrincipal = SUBSTRING(@inNumeroTelefono, 1, 1) 
		OR O.DigitoPrefijoSecundario = SUBSTRING(@inNumeroTelefono, 1, 1)

	RETURN @IDOperador;

END;