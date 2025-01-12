// Import required modules
const express = require('express');
const {MongoClient} = require('mongodb');
// MongoDB Atlas connection URI
const uri = 'mongodb+srv://luismorais14:luismorais1233@pei-project-2425.8ty5m.mongodb.net/'; // Replace with your connection string
const client = new MongoClient(uri);

async function getNumeroTotalTransferenciasPorMotivo(year, month) {
    try {
        await client.connect();
        const db = client.db('PEI_AC_2425');
        const collection = db.collection('Transferencias');

        // Create the start and end dates for the month
        const startDate = new Date(`${year}-${month.padStart(2, '0')}-01T00:00:00.000Z`);
        const endDate = new Date(year, parseInt(month), 0, 23, 59, 59, 999);

        const registos = await collection.aggregate([
            {
                $match: {
                    "Data_Transferencia": {
                        $gte: startDate,
                        $lte: endDate,
                    }
                }
            }, {
                $group:
                  /**
                   * _id: The id of the group.
                   * fieldN: The first field name.
                   */
                  {
                    _id: "$Motivo",
                    Total: {
                      $sum: 1
                    }
                  }
              },
              {
                $project:
                  /**
                   * specifications: The fields to
                   *   include or exclude.
                   */
                  {
                    _id: 0,
                    Motivo: "$_id",
                    Numero_Total: "$Total"
                  }
              }
        
        ]).toArray();


        return registos;


    } finally {
        await client.close();
    }
}

module.exports = {
    getNumeroTotalTransferenciasPorMotivo
};
