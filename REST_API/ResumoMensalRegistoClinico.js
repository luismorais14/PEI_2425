// Import required modules
const express = require('express');
const { get } = require('http');
const {MongoClient} = require('mongodb');

const { getNumeroPacientesAtendidosGenero } = require('./NumeroPacientesAtendidosGenero');
const { getNumeroCondicoesCronicas } = require('./NumeroCondicoesCronicas');
const { getCasosPorEspecialidade } = require('./CasosPorEspecialidade');
const { getNumeroPacientesFaixaEtaria } = require('./NumeroPacientesFaixaEtaria');
const { getNumeroTratamentosRealizados } = require('./NumeroTratamentosRealizados');

// MongoDB Atlas connection URI
const uri = 'mongodb+srv://luismorais14:luismorais1233@pei-project-2425.8ty5m.mongodb.net/'; // Replace with your connection string
const client = new MongoClient(uri);

async function getResumoMensalRegistoClinico(year, month) {
    try {
        await client.connect();
        const db = client.db('PEI_AC_2425');
        const collection = db.collection('RegistoClinico');

        // Create the start and end dates for the month
        const startDate = new Date(`${year}-${month.padStart(2, '0')}-01T00:00:00.000Z`);
        const endDate = new Date(year, parseInt(month), 0, 23, 59, 59, 999);

        const registos = await Promise.all([
            getNumeroPacientesAtendidosGenero(year, month),
            getNumeroCondicoesCronicas(year, month),
            getCasosPorEspecialidade(year, month),
            getNumeroPacientesFaixaEtaria(year, month),
            getNumeroTratamentosRealizados(year, month)
        ]);

        return {
            numeroPacientesAtendidosGenero: registos[0],
            numeroCondicoesCronicas: registos[1],
            casosPorEspecialidade: registos[2],
            numeroPacientesFaixaEtaria: registos[3],
            numeroTratamentosRealizados: registos[4]
        };

    } finally {
        await client.close();
    }
}

module.exports = {
    getResumoMensalRegistoClinico
};

