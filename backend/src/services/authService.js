const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const userModel = require("../models/userModel");


const login = async (email, password) => {


    // Buscar usuario en la base de datos
    const user = await userModel.findByEmail(email);


    if (!user) {

        throw new Error("Credenciales incorrectas");

    }


    // Validar si el usuario está activo

    if (!user.activo) {

        throw new Error("Usuario inactivo");

    }


    // Comparar contraseña ingresada
    // contra hash almacenado

    const passwordValid = await bcrypt.compare(
        password,
        user.password
    );


    if (!passwordValid) {

        throw new Error("Credenciales incorrectas");

    }


    // Crear token JWT

    const token = jwt.sign(

        {
            id: user.id,
            email: user.email
        },

        process.env.JWT_SECRET,

        {
            expiresIn: "2h"
        }

    );


    return {

        token,

        usuario: {

            id: user.id,
            nombre: user.nombre,
            apellido: user.apellido,
            email: user.email

        }

    };


};


module.exports = {

    login

};