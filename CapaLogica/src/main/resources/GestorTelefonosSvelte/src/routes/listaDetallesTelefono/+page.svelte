<script>
    import { page } from '$app/stores';

    let telefono = $page.url.searchParams.get('telefono');
    let fecha = $page.url.searchParams.get('fecha');
    let data = [];

    let loadData = async () => {
        await fetch('http://localhost:8080/api/getDetalleFacturaTelefono', {
            method: 'POST',
            body: JSON.stringify({telefono, fecha})
        })
        .then(res => { res.json().then(r => {
            data = r[0]
        }) })
    }

    $: loadData();
</script>

<div class="main">
    <h1>Facturador de servicios telefónicos</h1>
    <h2>Detalles del teléfono: {telefono} , para la factura del: {fecha}</h2>

    <p>Tarifa básica: {data.tarifaBase}</p>
    <p>Cantidad de minutos base: {data.minutosBase}</p>
    <p>Cantidad de minutos en exceso a tarifa básica: {data.minutosExceso}</p>
    <p>Cantidad de minutos de llamadas a familiares: {data.minutosFamiliares}</p>
    <p>Cantidad de gigas base: {data.gigasBase}</p>
    <p>Cantidad de gigas en exceso a tarifa básica: {data.gigasExceso}</p>
    <p>Cobro por llamadas al 911: {data.cobro911}</p>
    <p>Cobro por llamadas al 110: {data.cobro110}</p>
    <p>Cobro por llamadas a números 900: {data.cobro900}</p>
    <p>Cobro por llamadas a números 800:</p>
    <a href={`/listaLlamadasTelefono?telefono=${telefono}&fecha=${fecha}`}>
        <button>Detalle de todas las llamadas</button>
    </a>
    <br>
    <a href={`/listaUsoDatosTelefono?telefono=${telefono}&fecha=${fecha}`}>
        <button>Detalle de uso de datos</button>
    </a>

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

    p {
        font-family: 'Trebuchet MS';
    }

    button {
        background-color: #9DB2BF;
        font-size: 16px;
        border-radius: 4px;
        margin: 15px;
        padding: 5px 5px;
        transition-duration: 0.4s;
        cursor: pointer;
    }

    button:hover {
        background-color: #6f7e87;
    }

</style>