const bcrypt = require("bcrypt");

const userModel = require("../models/userModel");

const getAllUsers = async () => {

    return await userModel.findAll();

};

const getUserById = async (id) => {

    return await userModel.findById(id);

};

const createUser = async (user) => {

    // Verificar si el email ya existe

    const existingUser = await userModel.findByEmail(user.email);

    if (existingUser) {

        throw new Error("El email ya se encuentra registrado");

    }

    // Encriptar contraseña

    const hashedPassword = await bcrypt.hash(

        user.password,

        10

    );

    user.password = hashedPassword;

    // Guardar usuario

    const result = await userModel.create(user);

    return {

        id: result.insertId,

        nombre: user.nombre,

        apellido: user.apellido,

        email: user.email

    };

};

const updateUser = async (id, user) => {

   // Verificar que exista

    const existingUser = await userModel.findById(id);

    if (!existingUser) {

        throw new Error("Usuario no encontrado");

    }

    // Verificar email duplicado

    const emailOwner = await userModel.findByEmail(user.email);

    if (emailOwner && emailOwner.id != id) {

        throw new Error("El email ya está registrado por otro usuario");

    }

    // Actualizar

    await userModel.update(id, user);

    return await userModel.findById(id);


};

const deactivateUser = async (id) => {

    // Verificar que exista

    const user = await userModel.findById(id);

    if (!user) {

        throw new Error("Usuario no encontrado");

    }

    // Verificar si ya está inactivo

    if (!user.activo) {

        throw new Error("El usuario ya está inactivo");

    }

    // Baja lógica

    await userModel.deactivate(id);

    return {

        message: "Usuario dado de baja correctamente"

    };

};

module.exports = {

    getAllUsers,

    getUserById,

    createUser,
    
    updateUser,
    
    deactivateUser

};