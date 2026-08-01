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

const create = (user) => {

    return new Promise((resolve, reject) => {

        const sql = `
            INSERT INTO usuarios
            (
                nombre,
                apellido,
                fecha_nacimiento,
                sexo,
                direccion,
                telefono,
                email,
                password,
                provincia,
                nivel_educacion,
                activo
            )
            VALUES
            (
                ?,?,?,?,?,?,?,?,?,?,?
            )
        `;

        db.query(

            sql,

            [

                user.nombre,
                user.apellido,
                user.fecha_nacimiento,
                user.sexo,
                user.direccion,
                user.telefono,
                user.email,
                user.password,
                user.provincia,
                user.nivel_educacion,
                1

            ],

            (error, result) => {

                if (error) {

                    reject(error);
                    return;

                }

                resolve(result);

            }

        );

    });

};

const update = (id, user) => {

    return new Promise((resolve, reject) => {

        const sql = `
            UPDATE usuarios
            SET
                nombre = ?,
                apellido = ?,
                fecha_nacimiento = ?,
                sexo = ?,
                direccion = ?,
                telefono = ?,
                email = ?,
                provincia = ?,
                nivel_educacion = ?
            WHERE id = ?
        `;

        db.query(
            sql,
            [
                user.nombre,
                user.apellido,
                user.fecha_nacimiento,
                user.sexo,
                user.direccion,
                user.telefono,
                user.email,
                user.provincia,
                user.nivel_educacion,
                id
            ],
            (error, result) => {

                if (error) {
                    return reject(error);
                }

                resolve(result);

            }
        );

    });

};

const deactivate = (id) => {

    return new Promise((resolve, reject) => {

        const sql = `
            UPDATE usuarios
            SET activo = 0
            WHERE id = ?
        `;

        db.query(sql, [id], (error, result) => {

            if (error) {
                reject(error);
                return;
            }

            resolve(result);

        });

    });

};

module.exports = {
    findByEmail,
    findById,
    findAll,
    create,
    update,
    deactivate
};