ALTER FUNCTION dbo.EsGratis (@inNumeroDesde VARCHAR(16), @inNumeroA VARCHAR(16))
RETURNS BIT
AS
BEGIN

	DECLARE @condicionGratis BIT = 0;
	DECLARE @IDClienteNumeroDesde INT;
	DECLARE @IDClienteNumeroA INT;

	IF (@inNumeroA LIKE '800%' AND LEN(@inNumeroA) = 11)
	BEGIN
		SET @condicionGratis = 1
	END
	ELSE
	BEGIN
		SELECT @IDClienteNumeroDesde = C.IDCliente
		FROM dbo.Contrato C
		WHERE C.NumeroTelefono = @inNumeroDesde;

		SELECT @IDClienteNumeroA = C.IDCliente
		FROM dbo.Contrato C
		WHERE C.NumeroTelefono = @inNumeroA;

		IF (EXISTS (SELECT 1 FROM dbo.Parentesco P WHERE P.IDCliente = @IDClienteNumeroDesde AND P.IDPariente = @IDClienteNumeroA)
			OR EXISTS (SELECT 1 FROM dbo.Parentesco P WHERE P.IDPariente = @IDClienteNumeroDesde AND P.IDCliente = @IDClienteNumeroA))
		BEGIN
			SET @condicionGratis = 1;
		END
	END

	RETURN @condicionGratis;

END;