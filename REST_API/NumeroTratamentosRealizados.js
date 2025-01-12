// Import required modules
const express = require('express');
const { MongoClient } = require('mongodb');
// MongoDB Atlas connection URI
const uri = 'mongodb+srv://luismorais14:luismorais1233@pei-project-2425.8ty5m.mongodb.net/'; // Replace with your connection string
const client = new MongoClient(uri);

async function getNumeroTratamentosRealizados(year, month) {
    try {
        // Connecting to database
        await client.connect();
        const db = client.db('PEI_AC_2425');
        const collection = db.collection('RegistoClinico');

        // Create the start and end dates for the month
        const startDate = new Date(`${year}-${month.padStart(2, '0')}-01T00:00:00.000Z`);
        const endDate = new Date(year, parseInt(month), 0, 23, 59, 59, 999);

        const registos = await collection.aggregate([
            {
                $match: {
                    "Data_Atendimento": {
                        $gte: startDate,
                        $lte: endDate,
                    }
                }
            },


            {
                $unwind: {
                    path: "$Tratamentos",
                    preserveNullAndEmptyArrays: false
                }
            },
            {
                $group: {
                    _id: "$Tratamentos.Realizado",
                    totalTratamentos: {
                        $sum: 1
                    }
                }
            },
            {
                $match:
                {
                    _id: "Sim"
                }
            },
            {
                $project: {
                    _id: 0,
                    totalTratamentos: 1
                }

            }

        ]).toArray();


        return registos;

    } finally {
        await client.close();
    }

}

module.exports = {
    getNumeroTratamentosRealizados
};
