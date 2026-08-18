const express = require('express');
const cors = require('cors');
const { crearTicket, copiarTicket, anularTicket, pagarTicket } = require('./controllers/ventas.controller');

const app = express();
app.use(cors());
app.use(express.json());

// Ruta de estado
app.get('/', (req, res) => {
    res.json({ mensaje: "API de LoteApp Operativa" });
});

// Rutas de la API de Ventas y Tickets
app.post('/api/tickets/crear', crearTicket);
app.post('/api/tickets', crearTicket);
app.post('/api/tickets/copiar', copiarTicket);
app.post('/api/tickets/anular', anularTicket);
app.post('/api/tickets/pagar', pagarTicket);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`\n Servidor LoteApp corriendo en http://localhost:${PORT}`);
});