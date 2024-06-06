<script>
    import { page } from '$app/stores';

    let telefono = $page.url.searchParams.get('telefono');
    let facturas = [];

    let loadData = async () => {
        await fetch('http://localhost:8080/api/getFacturasTelefono', {
            method: 'POST',
            body: JSON.stringify({telefono})
        })
        .then(res => { res.json().then(r => {
            facturas = r
        }) })
    }

    $: loadData();
</script>

<div class="main">
    <h1>Facturador de servicios telefónicos</h1>
    <h2>Facturas del teléfono: {telefono}</h2>

    <div class="lista" id="lista">
        <table>
            <tr>
                <th>Fecha</th>
                <th>Total antes IVA</th>
                <th>Total después IVA</th>
                <th>Multa por factura previa</th>
                <th>Total a pagar incluyendo multas</th>
                <th>Fecha de pago</th>
                <th>Estado</th>
                <th></th>
            </tr>
            {#each facturas as factura}
            <tr>
                <td>{factura.fechaFactura}</td>
                <td>{factura.montoAntesIVA}</td>
                <td>{factura.montoDespuesIVA}</td>
                <td>{factura.multa}</td>
                <td>{factura.total}</td>
                <td>{factura.fechaPago}</td>
                <td>{factura.estado}</td>
                <td>
                    <a href={`/listaDetallesTelefono?telefono=${telefono}&fecha=${factura.fechaFactura}`}>
                        <button>Consultar detalles factura</button>
                    </a>
                </td>
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