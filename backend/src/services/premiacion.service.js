// Tablas de pago estándar por cada 1 UD apostada
const TABLA_PAGOS = {
    QUINIELA: { primera: 60, segunda: 8, tercera: 4 },
    PALE: { primera_segunda: 1000, primera_tercera: 1000, segunda_tercera: 100 },
    TRIPLETA: { tres_numeros: 20000, dos_numeros: 100 }
};

/**
 * Evalúa un ticket individual contra los resultados oficiales de un sorteo.
 * @param {Array} jugadas - Lista de jugadas del ticket [{id, tipo, numeros, monto}]
 * @param {Object} resultadoSorteo - Objeto con {primero, segundo, tercero} ('05', '12', '88')
 * @returns {Object} { totalPremio, detallePremios }
 */
function evaluarTicket(jugadas, resultadoSorteo) {
    let totalPremio = 0;
    const detallePremios = [];

    const { primero, segundo, tercero } = resultadoSorteo;

    jugadas.forEach((jugada) => {
        let premioJugada = 0;
        const num = jugada.numeros;
        const monto = parseFloat(jugada.monto);

        switch (jugada.tipo.toUpperCase()) {
            case 'QUINIELA':
                if (num === primero) {
                    premioJugada = monto * TABLA_PAGOS.QUINIELA.primera;
                } else if (num === segundo) {
                    premioJugada = monto * TABLA_PAGOS.QUINIELA.segunda;
                } else if (num === tercero) {
                    premioJugada = monto * TABLA_PAGOS.QUINIELA.tercera;
                }
                break;

            case 'PALE':
                const [p1, p2] = num.split('-');
                const coincide1 = [primero, segundo, tercero].includes(p1);
                const coincide2 = [primero, segundo, tercero].includes(p2);

                if (coincide1 && coincide2) {
                    if ((p1 === primero && p2 === segundo) || (p1 === segundo && p2 === primero)) {
                        premioJugada = monto * TABLA_PAGOS.PALE.primera_segunda;
                    } else if ((p1 === primero && p2 === tercero) || (p1 === tercero && p2 === primero)) {
                        premioJugada = monto * TABLA_PAGOS.PALE.primera_tercera;
                    } else {
                        premioJugada = monto * TABLA_PAGOS.PALE.segunda_tercera;
                    }
                }
                break;

            case 'TRIPLETA':
                const numsTripleta = num.split('-');
                const aciertos = numsTripleta.filter(n => [primero, segundo, tercero].includes(n)).length;

                if (aciertos === 3) {
                    premioJugada = monto * TABLA_PAGOS.TRIPLETA.tres_numeros;
                } else if (aciertos === 2) {
                    premioJugada = monto * TABLA_PAGOS.TRIPLETA.dos_numeros;
                }
                break;
        }

        if (premioJugada > 0) {
            totalPremio += premioJugada;
            detallePremios.push({
                jugada_id: jugada.id,
                tipo: jugada.tipo,
                numeros: jugada.numeros,
                montoApostado: monto,
                premioGanado: premioJugada
            });
        }
    });

    return { totalPremio, detallePremios };
}

module.exports = { evaluarTicket };