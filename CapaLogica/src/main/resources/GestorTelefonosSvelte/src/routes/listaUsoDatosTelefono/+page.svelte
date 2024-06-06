<script>
    import { page } from '$app/stores';

    let telefono = $page.url.searchParams.get('telefono');
    let fecha = $page.url.searchParams.get('fecha');
    let data = [];

    let loadData = async () => {
        await fetch('http://localhost:8080/api/getUsoDatosTelefono', {
            method: 'POST',
            body: JSON.stringify({telefono, fecha})
        })
        .then(res => { res.json().then(r => {
            data = r
        }) })
    }

    $: loadData();
</script>

<div class="main">
    <h1>Facturador de servicios telefónicos</h1>
    <h2>Uso de datos del teléfono: {telefono} , para la factura del: {fecha}</h2>

    <div class="lista" id="lista">
        <table>
            <tr>
                <th>Fecha</th>
                <th>Monto de gigas consumidos</th>
            </tr>
            {#each data as datos}
            <tr>
                <td>{datos.fecha}</td>
                <td>{datos.gigasConsumidos}</td>
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