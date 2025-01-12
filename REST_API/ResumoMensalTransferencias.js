// Import required modules
const express = require('express');
const {MongoClient} = require('mongodb');

const { getNumeroTotalTransferenciasPorTipo } = require('./NumeroTotalTransferenciasPorTipo');
const { getNumeroTotalTransferenciasPorHospital } = require('./NumeroTotalTransferenciasPorHospital');
const { getNumeroTotalTransferenciasPorMotivo } = require('./NumeroTotalTransferenciasPorMotivo');

// MongoDB Atlas connection URI
const uri = 'mongodb+srv://luismorais14:luismorais1233@pei-project-2425.8ty5m.mongodb.net/'; // Replace with your connection string
const client = new MongoClient(uri);

async function getResumoMensalTransferencias(year, month) {
    try {
        await client.connect();
        const db = client.db('PEI_AC_2425');
        const collection = db.collection('Transferencias');

        const registos = await Promise.all([
            getNumeroTotalTransferenciasPorTipo(year, month),
            getNumeroTotalTransferenciasPorHospital(year, month),
            getNumeroTotalTransferenciasPorMotivo(year, month),
        ]);

        return {
            NumeroTotalTransferenciasPorTipo: registos[0],
            NumeroTotalTransferenciasPorHospital: registos[1],
            NumeroTotalTransferenciasPorMotivo: registos[2],
        };

    } finally {
        await client.close();
    }

}

module.exports = {
    getResumoMensalTransferencias
};
