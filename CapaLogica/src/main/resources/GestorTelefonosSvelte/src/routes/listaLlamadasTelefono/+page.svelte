<script>
    import { page } from '$app/stores';

    let telefono = $page.url.searchParams.get('telefono');
    let fecha = $page.url.searchParams.get('fecha');
    let facturas = [];

    let loadData = async () => {
        await fetch('http://localhost:8080/api/getLlamadasTelefono', {
            method: 'POST',
            body: JSON.stringify({telefono, fecha})
        })
        .then(res => { res.json().then(r => {
            facturas = r
        }) })
    }

    $: loadData();
</script>

<div class="main">
    <h1>Facturador de servicios telefónicos</h1>
    <h2>Llamadas del teléfono: {telefono} , para la factura del: {fecha}</h2>

    <div class="lista" id="lista">
        <table>
            <tr>
                <th>Fecha</th>
                <th>Hora Inicio</th>
                <th>Hora Fin</th>
                <th>Numero al que llamó</th>
                <th>Cantidad de minutos</th>
                <th>¿Gratis?</th>
            </tr>
            {#each facturas as factura}
            <tr>
                <td>{factura.fecha}</td>
                <td>{factura.horaInicio}</td>
                <td>{factura.horaFin}</td>
                <td>{factura.numeroDestino}</td>
                <td>{factura.duracion}</td>
                <td>{factura.condicion}</td>
            </tr>
            {/each}
        </table>
    </div>

</div>

<style>
    :global(body) {
        background-color: #DDE6ED;
    }

    h1, h2 {
        text-align: center;
        font-family: 'Trebuchet MS';
        font-style: italic;
    }

    table, th, td {
        margin-top: 15px;
        border: 1px solid black;
        border-collapse: collapse;
        padding: 10px;
    }

</style>