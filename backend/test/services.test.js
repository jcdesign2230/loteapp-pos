const assert = require('node:assert/strict');
const test = require('node:test');

const { calcularComisionVenta } = require('../src/services/comisiones.service');
const { evaluarTicket } = require('../src/services/premiacion.service');

test('calcula la comisión con dos decimales', () => {
    assert.equal(calcularComisionVenta(500, 5), 25);
    assert.equal(calcularComisionVenta(99.99, 5), 5);
});

test('rechaza una venta o porcentaje inválido', () => {
    assert.equal(calcularComisionVenta(0, 5), 0);
    assert.equal(calcularComisionVenta(-10, 5), 0);
    assert.equal(calcularComisionVenta(100, -5), 0);
    assert.equal(calcularComisionVenta(Number.NaN, 5), 0);
});

test('premia una quiniela según la posición del resultado', () => {
    const resultado = evaluarTicket(
        [{ id: 1, tipo: 'QUINIELA', numeros: '12', monto: 5 }],
        { primero: '12', segundo: '25', tercero: '88' }
    );

    assert.equal(resultado.totalPremio, 300);
    assert.equal(resultado.detallePremios.length, 1);
});

test('premia un pale cuando ambos números aparecen en el sorteo', () => {
    const resultado = evaluarTicket(
        [{ id: 2, tipo: 'PALE', numeros: '12-25', monto: 10 }],
        { primero: '12', segundo: '25', tercero: '88' }
    );

    assert.equal(resultado.totalPremio, 10000);
    assert.equal(resultado.detallePremios[0].premioGanado, 10000);
});
