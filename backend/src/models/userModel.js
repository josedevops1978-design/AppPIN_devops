const db = require("../config/database");


const findByEmail = (email) => {

    return new Promise((resolve, reject) => {

        const sql = `
            SELECT
                id,
                nombre,
                apellido,
                email,
                password,
                activo
            FROM usuarios
            WHERE email = ?
        `;


        db.query(sql, [email], (error, results) => {


            if(error){

                reject(error);
                return;

            }


            if(results.length === 0){

                resolve(null);
                return;

            }


            resolve(results[0]);

        });


    });

};


const findById = (id) => {

    return new Promise((resolve, reject) => {

        const sql = `
            SELECT
                id,
                nombre,
                apellido,
                fecha_nacimiento,
                sexo,
                direccion,
                telefono,
                email,
                provincia,
                nivel_educacion,
                activo
            FROM usuarios
            WHERE id = ?
        `;

        db.query(sql, [id], (error, results) => {

            if (error) {
                reject(error);
                return;
            }

            if (results.length === 0) {
                resolve(null);
                return;
            }

            resolve(results[0]);

        });

    });

};

const findAll = () => {

    return new Promise((resolve, reject) => {

        const sql = `
            SELECT
                id,
                nombre,
                apellido,
                fecha_nacimiento,
                sexo,
                direccion,
                telefono,
                email,
                provincia,
                nivel_educacion,
                activo
            FROM usuarios
            WHERE activo = 1
            ORDER BY apellido, nombre
        `;

        db.query(sql, (error, results) => {

            if (error) {
                reject(error);
                return;
            }

            resolve(results);

        });

    });

};

module.exports = {
    findByEmail,
    findById,
    findAll
};