const mysql = require("mysql2");

require("dotenv").config();

const connection = mysql.createConnection({

    host: process.env.DB_HOST,

    port: process.env.DB_PORT,

    user: process.env.DB_USER,

    password: process.env.DB_PASSWORD,

    database: process.env.DB_DATABASE

});

connection.connect((error) => {

    if (error) {

        console.error("");

        console.error("ERROR CONECTANDO MYSQL");

        console.error(error);

        process.exit(1);

    }

    console.log("? MySQL conectado");

});

module.exports = connection;