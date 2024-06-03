ALTER FUNCTION dbo.ObtenerMinutos (@inNumeroTelefono VARCHAR(16), @inFechaOperacion DATE)
RETURNS @Minutos TABLE (
      MinutosEntrantes INT
    , MinutosSalientes INT
)
AS
BEGIN
    DECLARE @minutosEntrantes INT;
    DECLARE @minutosSalientes INT;

    SELECT @minutosEntrantes = ISNULL(SUM(DATEDIFF(MINUTE, LI.HoraInicio, LI.HoraFin)), 0)
    FROM dbo.LlamadaInput LI
    WHERE CONVERT(DATE, LI.HoraInicio) = @inFechaOperacion
        AND LI.NumeroA = @inNumeroTelefono
        AND (dbo.ObtenerOperador(LI.NumeroA) != dbo.ObtenerOperador(LI.NumeroDesde));

    -- Calculate minutes for outgoing calls
    SELECT @minutosSalientes = ISNULL(SUM(DATEDIFF(MINUTE, LI.HoraInicio, LI.HoraFin)), 0)
    FROM dbo.LlamadaInput LI
    WHERE CONVERT(DATE, LI.HoraInicio) = @inFechaOperacion
        AND LI.NumeroDesde = @inNumeroTelefono
        AND (dbo.ObtenerOperador(LI.NumeroA) != dbo.ObtenerOperador(LI.NumeroDesde));

    INSERT INTO @Minutos (
          MinutosEntrantes
        , MinutosSalientes
    )
    VALUES (
          @minutosEntrantes
        , @minutosSalientes
    );

    RETURN;
END;
