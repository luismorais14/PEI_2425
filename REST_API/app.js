// Import required modules
const express = require('express');
const { MongoClient } = require('mongodb');
const { getListaPacientes } = require('./ListaPacientes');
const { getRegistoClinico } = require('./RegistoClinico');
const { getResumoMensalRegistoClinico } = require('./ResumoMensalRegistoClinico');
const { getRegistoTransferencias } = require('./RegistosTransferencias');
const { getResumoMensalTransferencias } = require('./ResumoMensalTransferencias');

// Initialize Express app
const app = express();
const port = process.env.PORT || 3000;

// Middleware to parse JSON request bodies
app.use(express.json());

// MongoDB Atlas connection URI
const uri = 'mongodb+srv://luismorais14:luismorais1233@pei-project-2425.8ty5m.mongodb.net/'; // Replace with your connection string
const client = new MongoClient(uri);

// Define the endpoint(s)
app.get('/RegistoClinico', async (req, res) => {
    try {
        // Get the "year" and "month" parameters from the query string
        const { month, year } = req.query;

        if (!month || !year) {
            return res.status(400).json({ error: "Informe o mês e ano (mes, ano) na query string." });
        }

        const startDate = new Date(parseInt(year, parseInt(month) - 1, 1));
        const endDate = new Date(parseInt(year), parseInt(month), 1);

        // Connect to the MongoDB Atlas cluster
        await client.connect();

        const [listaPacientes, registoClinico, resumoMensalRegistoClinico] = await Promise.all([
            getListaPacientes(year, month),
            getRegistoClinico(year, month),
            getResumoMensalRegistoClinico(year, month)
        ]);

        // Build the response
        const response = {
            listaPacientes,
            registoClinico,
            resumoMensalRegistoClinico,
        };

        if (!listaPacientes.length && !registoClinico.length && !Object.keys(resumoMensalRegistoClinico).length) {
            return res.status(404).json({
                error: `Nenhum registo encontrado para o mês '${month}' e ano '${year}'.`,
            });
        }

        // Send the found records as the response
        res.status(200).json(response);
    } catch (error) {
        console.error('Error fetching registo clinico:', error);
        res.status(500).json({ error: "Erro ao devolver o registo clinico.", details: error.message });
    } finally {
        // Close the database connection
        await client.close();
    }
});

app.get('/Transferencias', async (req, res) => {
    try {
        // Get the "year" and "month" parameters from the query string
        const { month, year } = req.query;

        if (!month || !year) {
            return res.status(400).json({ error: "Informe o mês e ano (mes, ano) na query string." });
        }

        const startDate = new Date(parseInt(year, parseInt(month) - 1, 1));
        const endDate = new Date(parseInt(year), parseInt(month), 1);


        // Connect to the MongoDB Atlas cluster
        await client.connect();

        const [registoTransferencias, resumoMensalTransferencias] = await Promise.all([
            getRegistoTransferencias(year, month),
            getResumoMensalTransferencias(year, month)
        ]);

        // Build the response
        const response = {
            registoTransferencias,
            resumoMensalTransferencias
        };

        // Send the found records as the response
        res.status(200).json(response);
    } catch (error) {
        console.error('Error fetching registo clinico:', error);
        res.status(500).json({ error: "Erro ao devolver o registo clinico.", details: error.message });
    } finally {
        // Close the database connection
        await client.close();
    }
});

// Start the Express server
app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});
