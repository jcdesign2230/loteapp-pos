const { calcularComisionVenta } = require('../services/comisiones.service');

// Base de datos en memoria para pruebas en Codespaces
let ticketsBD = [
    {
        id: "21174",
        sucursal_id: 1,
        estado: "ACTIVO",
        monto_total: 26.00,
        hora_cierre_loteria: "23:59:50",
        jugadas: [
            { id: 1, tipo: 'QUINIELA', numeros: '12', monto: 5.00 }
        ]
    }
];
let contadorTicket = 21175;

/**
 * Endpoint: Crear Ticket de Venta Multilotería
 */
function crearTicket(req, res) {
    const { usuario_id, sucursal_id, loterias, jugadas, porcentaje_comision } = req.body;

    if (!loterias || loterias.length === 0) {
        return res.status(400).json({ error: "Debe seleccionar al menos una lotería." });
    }
    if (!jugadas || jugadas.length === 0) {
        return res.status(400).json({ error: "Debe agregar al menos una jugada." });
    }

    let subtotalJugadas = jugadas.reduce((sum, j) => sum + parseFloat(j.monto), 0);
    let montoTotal = subtotalJugadas * loterias.length;
    let comisionCalculada = calcularComisionVenta(montoTotal, porcentaje_comision || 5);

    const nuevoTicket = {
        id: (contadorTicket++).toString(),
        sucursal_id: sucursal_id || 1,
        usuario_id: usuario_id || 1,
        loterias: loterias,
        jugadas: jugadas,
        monto_total: montoTotal,
        comision: comisionCalculada,
        hora_cierre_loteria: "23:59:50",
        estado: "ACTIVO",
        creado_en: new Date().toISOString()
    };

    ticketsBD.push(nuevoTicket);

    return res.status(201).json({
        mensaje: "Ticket creado exitosamente",
        ticket: nuevoTicket
    });
}

/**
 * Endpoint: Copiar / Clonar Jugadas de un Ticket
 */
function copiarTicket(req, res) {
    const { ticketId, nuevasLoterias } = req.body;

    const ticketOriginal = ticketsBD.find(t => t.id === ticketId);
    if (!ticketOriginal) {
        return res.status(404).json({ error: "Ticket a copiar no encontrado." });
    }

    return res.json({
        mensaje: "Jugadas obtenidas para copiar",
        loteriasSugeridas: nuevasLoterias || ticketOriginal.loterias,
        jugadas: ticketOriginal.jugadas
    });
}

/**
 * Endpoint: Anular un Ticket
 */
function anularTicket(req, res) {
    const { ticketId, usuario } = req.body;

    if (!usuario || !usuario.permiso_anular) {
        return res.status(403).json({ error: "No tiene permisos de administrador para anular tickets." });
    }

    const ticket = ticketsBD.find(t => t.id === ticketId);
    if (!ticket) {
        return res.status(404).json({ error: "Ticket no encontrado." });
    }

    if (ticket.estado === "ANULADO") {
        return res.status(400).json({ error: "El ticket ya se encuentra anulado." });
    }

    const horaActual = new Date().toTimeString().split(' ')[0];
    if (horaActual > ticket.hora_cierre_loteria) {
        return res.status(400).json({ error: "No se puede anular: El sorteo de la lotería ya cerró." });
    }

    ticket.estado = "ANULADO";
    return res.json({ mensaje: "Ticket anulado con éxito", ticketId: ticket.id, estado: ticket.estado });
}

/**
 * Endpoint: Pagar un Ticket Premiado
 */
function pagarTicket(req, res) {
    const { ticketId } = req.body;

    const ticket = ticketsBD.find(t => t.id === ticketId);
    if (!ticket) {
        return res.status(404).json({ error: "Ticket no encontrado." });
    }

    if (ticket.estado === "ANULADO") {
        return res.status(400).json({ error: "No se puede pagar un ticket que está anulado." });
    }

    if (ticket.estado === "PAGADO") {
        return res.status(400).json({ error: "El ticket ya fue pagado previamente." });
    }

    ticket.estado = "PAGADO";
    return res.json({ mensaje: "Ticket pagado con éxito", ticketId: ticket.id, estado: ticket.estado });
}

module.exports = { crearTicket, copiarTicket, anularTicket, pagarTicket };