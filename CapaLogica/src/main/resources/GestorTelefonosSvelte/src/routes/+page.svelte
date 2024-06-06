<script>

    let inputTelefono;
    let inputEmpresa;
    let boolInputTelefono = false;
    let boolInputEmpresa = false;

    const showInputTelefono = () => {
        boolInputTelefono = true;
        boolInputEmpresa = false;
    }

    const showInputEmpresa = () => {
        boolInputEmpresa = true;
        boolInputTelefono = false;
    }

    const consultarTelefono = () => { 
        //...
    }

    const consultarEmpresa = () => {
        //...
    }
</script>

<div class="main">
    <h1>Facturador de servicios telefónicos</h1>
    <div class="botones">
        <button on:click={showInputTelefono}>Consultar número de teléfono</button>
        <div style="display: {boolInputTelefono ? "block" : "none"};">
            <input type="text" 
            name="inputTelefono" id="inputTelefono" 
            placeholder="Teléfono móvil"
            bind:value={inputTelefono}
            on:input={
                () => {
                    const regex = /[0-9]+/i;
                    if(regex.test(inputTelefono)) {
                        document.getElementById("inputTelefono").style.border = "";
                    } else {
                        document.getElementById("inputTelefono").style.border = "2px solid red";
                    }
                }
            }>
            <a href="/listaFacturasTelefono?telefono={inputTelefono}">
                <button on:click={consultarTelefono}>Procesar consulta</button>
            </a>
        </div>
        <button on:click={showInputEmpresa}>Consultar estado de cuenta de empresa</button>
        <div style="display: {boolInputEmpresa ? "block" : "none"};">
            <input type="text" 
            name="inputEmpresa" id="inputEmpresa" 
            placeholder="Nombre de empresa"
            bind:value={inputEmpresa}>
            <a href="/listaFacturasEmpresa?empresa={encodeURIComponent(inputEmpresa)}">
                <button on:click={consultarEmpresa}>Procesar consulta</button>
            </a>
        </div>
    </div>
</div>

<style>
    :global(body) {
        background-color: #DDE6ED;
    }

    h1 {
        text-align: center;
        font-family: 'Trebuchet MS';
        font-style: italic;
    }

    .botones {
        display: grid;
        justify-content: center;
    }

    .botones button {
        background-color: #9DB2BF;
        font-size: 16px;
        border-radius: 4px;
        margin: 15px;
        padding: 5px 5px;
        transition-duration: 0.4s;
        cursor: pointer;
    }

    .botones button:hover {
        background-color: #6f7e87;
    }
</style>