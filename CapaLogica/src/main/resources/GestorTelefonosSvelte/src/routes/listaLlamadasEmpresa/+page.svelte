<script>
    import { page } from '$app/stores';

    let empresa = $page.url.searchParams.get('empresa');
    let llamadas = [];

    let loadData = async () => {
        await fetch('http://localhost:8080/api/getLlamadasEmpresa', {
            method: 'POST',
            body: JSON.stringify({empresa})
        })
        .then(res => { res.json().then(r => {
            llamadas = r
        }) })
    }

    $: loadData();
</script>

<div class="main">
    <h1>Facturador de servicios telefónicos</h1>
    <h2>Llamadas de la empresa: {empresa}</h2>

    <div class="lista" id="lista">
        <table>
            <tr>
                <th>Fecha</th>
                <th>Número que inicio la llamada</th>
                <th>Número que recibe la llamada</th>
                <th>Tipo de llamada</th>
                <th>Hora de inicio</th>
                <th>Hora de fin</th>
                <th>Cantidad minutos</th>
            </tr>
            {#each llamadas as llamada}
            <tr>
                <td>{llamada.fecha}</td>
                <td>{llamada.numeroOrigen}</td>
                <td>{llamada.numeroDestino}</td>
                <td>{llamada.condicion}</td>
                <td>{llamada.horaInicio}</td>
                <td>{llamada.horaFin}</td>
                <td>{llamada.duracion}</td>
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