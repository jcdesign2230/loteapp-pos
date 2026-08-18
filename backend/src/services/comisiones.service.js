/**
 * Calcula la comisión de una venta según el porcentaje asignado.
 * @param {number} totalVenta - Monto total consumido en el ticket.
 * @param {number} porcentajeComision - Porcentaje configurado (ej: 5 para 5%).
 * @returns {number} Monto ganado por comisión.
 */
function calcularComisionVenta(totalVenta, porcentajeComision) {
    if (!totalVenta || totalVenta <= 0) return 0;
    return parseFloat(((totalVenta * porcentajeComision) / 100).toFixed(2));
}

module.exports = { calcularComisionVenta };