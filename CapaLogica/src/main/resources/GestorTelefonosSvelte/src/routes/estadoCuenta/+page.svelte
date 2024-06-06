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
            data = r[0]
        }) })
    }

    $: loadData();
</script>

<div class="main">
    <h1>Facturador de servicios telefónicos</h1>
    <h2>Estado cuenta para empresa: {empresa}</h2>

    <p>Total de minutos de llamadas entrantes: {data.minutosEntrantes}</p>
    <p>Total de minutos de llamadas salientes: {data.minutosSalientes}</p>
    <a href={`/listaLlamadasEmpresa?empresa=${empresa}`}>
        <button>Detalle de todas las llamadas</button>
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