require("dotenv").config();

const app = require("./app");

require("./config/database");

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {

    console.log("");

    console.log("===================================");

    console.log(" Sistema Gestión Usuarios ");

    console.log("===================================");

    console.log(`Servidor iniciado`);

    console.log(`Puerto: ${PORT}`);

    console.log("===================================");

});