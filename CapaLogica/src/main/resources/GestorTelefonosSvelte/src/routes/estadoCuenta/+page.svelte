<script>
    import { page } from '$app/stores';

    let empresa = $page.url.searchParams.get('empresa');
    let data = [];

    let loadData = async () => {
        await fetch('http://localhost:8080/api/getEstadoCuentaEmpresa', {
            method: 'POST',
            body: JSON.stringify({empresa})
        })
        .then(res => { res.json().then(r => {
            data = r
        }) })
    }

    $: loadData();
</script>

<div class="main">
    <h1>Facturador de servicios telefónicos</h1>
    <h2>Estado cuenta para empresa: {empresa}</h2>

    <table>
        <tr>
            <th>Fecha apertura</th>
            <th>Fecha cierre</th>
            <th>Minutos llamadas entrantes</th>
            <th>Minutos llamadas salientes</th>
            <th>Estado</th>
            <th></th>
        </tr>
        {#each data as plazo}
        <tr>
            <td>{plazo.fechaApertura}</td>
            <td>{plazo.fechaCierre}</td>
            <td>{plazo.minutosEntrantes}</td>
            <td>{plazo.minutosSalientes}</td>
            <td>{plazo.estado}</td>
            <td>
                <a href={`/listaLlamadasEmpresa?empresa=${empresa}&fechaCierre=${plazo.fechaCierre}`}>
                    <button>Detalle de todas las llamadas</button>
                </a>
            </td>
        </tr>
        {/each}
    </table>

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