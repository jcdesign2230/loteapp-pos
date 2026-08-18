const { calcularComisionVenta } = require('./services/comisiones.service');
const { evaluarTicket } = require('./services/premiacion.service');

// 1. Probar comisión
const ventaTotal = 500.00;
const comision = calcularComisionVenta(ventaTotal, 5);
console.log(`\n=== PRUEBA DE COMISIÓN ===`);
console.log(`Venta: $${ventaTotal} | Comisión (5%): $${comision}`);

// 2. Probar evaluación de un ticket ganador de Palé y Quiniela
const jugadasTicket = [
    { id: 1, tipo: 'QUINIELA', numeros: '12', monto: 5.00 },
    { id: 2, tipo: 'PALE', numeros: '12-25', monto: 10.00 }
];

const resultadoOficial = { primero: '12', segundo: '25', tercero: '88' };

const resultado = evaluarTicket(jugadasTicket, resultadoOficial);
console.log(`\n=== PRUEBA DE PREMIACIÓN ===`);
console.log('Resultado del Ticket:', JSON.stringify(resultado, null, 2));